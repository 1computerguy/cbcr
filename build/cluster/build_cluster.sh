#!/bin/bash
set -e

usage() {
    echo ""
    echo "Please make sure all the systems you are configuring have a common username and password."
    echo "Add the username, password, and the csv configuration file to build the cluster."
    echo ""
    echo " ----"
    echo -e "    Example: $0 -u <username> -p <password> -f <configfile.csv>"
    echo " ----"
    echo ""
    echo "CSV file contains the following columns:"
    echo -e "   - hostname"
    echo -e "   - management IP"
    echo -e "   - default gateway IP"
    echo -e "   - storage IP"
    echo -e "   - OVS Overlay IP"
    echo ""
    echo "----"
    echo "Example of configfile.csv file:"
    echo -e "    master,192.168.1.10,192.168.1.1,10.10.1.10,10.10.2.10"
    echo -e "    worker01,192.168.1.11,192.168.1.1,10.10.1.11,10.10.2.11"
    echo -e "    worker02,192.168.1.12,192.168.1.1,10.10.1.12,10.10.2.12"
    echo "----"
    echo ""
}

SSHPASS=""
user=""
password=""

# Set arguments as IP variables
if [ $# -gt 1 ]
then
    count=0
    while [ "$1" != "" ]
    do
        case $1 in
            -p | --password )
                shift
                SSHPASS="$1"
                export SSHPASS=$SSHPASS
                ;;
            -f | --filename )
                shift
                filename="$1"
                ;;
            -u | --username )
                shift
                user="$1"
                ;;
            -h | --help )
                usage
                exit
                ;;
            * )
                usage
                exit 1
                ;;
        esac
        shift
    done
else
    usage
    exit 1
fi

if [ "$filename" == "" ] || [ "$SSHPASS" == "" ] || [ "$user" == "" ]
then
  usage
  exit 1
fi



echo "-----------------------------------------------------------"
echo "|  Importing CSV data into local variables                |"
echo "-----------------------------------------------------------"
echo ""
# Parse input CSV and create master, worker01, and worker02 arrays
OLDIFS="$IFS"
IFS=','
while read hostname mgmtip gateway storageip overlayip
do
  if [ "$hostname" ]
  then
    eval "$hostname=($mgmtip $gateway $storageip $overlayip)"
  fi
done < "$filename"
IFS="$OLDIFS"

echo "--------------------------------------------------------"
echo "| Pulling the latest K8s repo data for installation    |"
echo "--------------------------------------------------------"
echo ""
# Add K8s key and repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

echo "--------------------------------------------------------"
echo "| Installing packages...                               |"
echo "--------------------------------------------------------"
echo ""
# Install necessary packages
DEBIAN_FRONTEND=noninteractive apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y docker.io python-docker pv python-pip kubeadm kubelet kubectl \
                    geoipupdate docker-compose openvswitch-switch nfs-common \
                    python3-pip sshpass expect

# Disable rpcbind (service added from nfs-common install) so we can share nfs from our nfs container
systemctl stop rpcbind
systemctl disable rpcbind

echo "--------------------------------------------------------"
echo "| Installing some Python pip packages for use later    |"
echo "--------------------------------------------------------"
echo ""
sudo -u $user pip install dnspython
sudo -u $user pip install geoip2
sudo -u $user pip3 install kuku

echo "----------------------------------------------------------"
echo "|  Writing and applying network configuration            |"
echo "----------------------------------------------------------"
echo ""
# Create static netplan configuration file for static IP addresses
cat > /etc/netplan/50-cloud-init.yaml <<NET
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  ethernets:
    eth0:
      addresses: [ ${master[0]}/24 ]
      gateway4: ${master[1]}
      nameservers:
        addresses:
        - 8.8.8.8
      dhcp4: false
    eth1:
      addresses: [ ${master[2]}/24 ]
      dhcp4: false
    eth2:
      addresses: [ ${master[3]}/24 ]
      dhcp4: false
    eth3:
      dhcp4: false
NET

netplan apply

echo "--------------------------------------------------------"
echo "| Enabling IP forwarding for the router containers     |"
echo "--------------------------------------------------------"
echo ""
# Enable IP forwarding for some later functionality
echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | tee -a /etc/sysctl.conf
sysctl -p

echo "--------------------------------------------------------"
echo "| Disable swap and enable NFS                          |"
echo "--------------------------------------------------------"
echo ""
swapoff -a
sed -i '$s|/swap|\#/swap|' /etc/fstab

modprobe nfs
modprobe nfsd

tee -a /etc/modules <<MOD
nfs
nfsd
MOD

echo "---------------------------------------------------------"
echo "| Writing /etc/hosts file for named access to resoruces |"
echo "---------------------------------------------------------"
echo ""
cat >> /etc/hosts <<EOF
${master[0]}      master
${master[2]}      storage
${master[3]}      network
${worker01[0]}      worker01
${worker02[0]}      worker02
${worker01[3]}      network01
${worker02[3]}      network02
EOF

echo "--------------------------------------------------------"
echo "| Configuring systemd cgroupdriver for Docker          |"
echo "--------------------------------------------------------"
echo ""
# Change Docker manager to systemd, not cgroup
tee /etc/docker/daemon.json <<DOC
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
DOC

mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl enable docker
systemctl restart docker

usermod -aG docker $user

echo "--------------------------------------------------------"
echo "| Initializing Kubernetes Cluster!                     |"
echo "|  I can take a couple of minutes, please be patient...|"
echo "--------------------------------------------------------"
echo ""

home_dir="/home/$user/"
kubeadm init --pod-network-cidr=10.244.0.0/16 > cluster-init
sudo -u $user mkdir -p $home_dir/.kube
cp -i /etc/kubernetes/admin.conf $home_dir/.kube/config
chown $user:$user $home_dir/.kube/config

sudo -u $user kubectl apply -f cni/flannel.yml

while [ "$(kubectl get nodes | awk '{if (NR!=1) {print $2}}')" != "Ready" ]
do
    echo "...Waiting for Primary CNI to load and cluster node to be Ready..."
    sleep 2
done

echo "Installing Multus-CNI..."
sudo -u $user kubectl apply -f cni/multus.yml

while [ "$(kubectl get pods --all-namespaces | grep multus | awk '{print $4}')" != "Running" ]
do
    echo "...Waiting for Multus CNI to load properly..."
    sleep 2
done

echo "Now installing OVS CNI"
sudo -u $user kubectl apply -f cni/ovs.yml

while [ "$(kubectl get pods --all-namespaces | grep ovs | awk '{print $4}')" != "Running" ]
do
    echo "...Waiting for OVS CNI to load properly..."
    sleep 2
done

echo "*--------------------------------"
echo "*"
echo -e "*  Writing Worker01 configuration to worker01.sh..."
echo "*"
echo "*--------------------------------"

hosts=`cat /etc/hosts`

sudo -u $user cat > worker01.sh <<WK1
#!/bin/bash
set -e

echo "--------------------------------------------------------"
echo "| Installing packages...                               |"
echo "--------------------------------------------------------"
echo ""
# Add kubernetes repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# Install Updates
DEBIAN_FRONTEND=noninteractive apt update && apt upgrade -y

# Install packages
DEBIAN_FRONTEND=noninteractive apt install -y sshpass docker.io kubeadm kubelet kubectl openvswitch-switch curl nfs-common

echo "----------------------------------------------------------"
echo "|  Writing and applying network configuration            |"
echo "----------------------------------------------------------"
echo ""
cat > /etc/netplan/50-cloud-init.yaml <<NET
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  ethernets:
    eth0:
      addresses: [ ${worker01[0]}/24 ]
      gateway4: ${worker01[1]}
      nameservers:
        addresses:
        - 8.8.8.8
      dhcp4: false
    eth1:
      addresses: [ ${worker01[2]}/24 ]
      dhcp4: false
    eth2:
      addresses: [ ${worker01[3]}/24 ]
      dhcp4: false
    eth3:
      dhcp4: false
NET

netplan apply

cat > /etc/hosts <<EOF
$hosts
EOF

cat > ~/.env <<EOF
WORK01_NET=`host network01 | grep "has address" | awk '{print $4}'`
WORK02_NET=`host network02 | grep "has address" | awk '{print $4}'`
MSTR_NET=`host network | grep "has address" | awk '{print $4}'`
EOF

cat >> ~/.bashrc <<ENV
set -a
    [ -f ~/.env ] && . ~/.env
set +a
ENV

# Disable swap (incompatible with K8s 1.7+) and add NFS share mount for internal Docker registry
swapoff -a
sed -i '$s|/swap|\#/swap|' /etc/fstab
echo "storage:/certs       /etc/docker/certs.d      nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab

# Enable IP forwarding for some later functionality
echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | tee -a /etc/sysctl.conf

# Reload
sysctl -p /etc/sysctl.conf

# Change Docker manager to systemd, not cgroup
echo "--------------------------------------------------------"
echo "| Configuring systemd cgroupdriver for Docker          |"
echo "--------------------------------------------------------"
echo ""
# Change Docker manager to systemd, not cgroup
tee /etc/docker/daemon.json <<DOC
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
DOC

mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl enable docker
systemctl restart docker

mkdir -p /etc/docker/certs.d

# Sleep to ensure docker process is started fully and that cgroup driver is loaded properly
echo -e "Please wait while we do some things..."
sleep 15

usermod -aG docker greyadmin

echo "--------------------------------------------------------"
echo "| Initializing Kubernetes Cluster!                     |"
echo "|  I can take a couple of minutes, please be patient...|"
echo "--------------------------------------------------------"
echo ""
`grep -A 2 "kubeadm join" cluster-init`

WK1


echo "*--------------------------------"
echo "*"
echo -e "*  Writing Worker02 configuration to worker02.sh..."
echo "*"
echo "*--------------------------------"

sudo -u $user cat > worker02.sh <<WK2
#!/bin/bash
set -e

echo "--------------------------------------------------------"
echo "| Installing packages...                               |"
echo "--------------------------------------------------------"
echo ""
# Add kubernetes repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# Install Updates
DEBIAN_FRONTEND=noninteractive apt update && apt upgrade -y

# Install packages
DEBIAN_FRONTEND=noninteractive apt install -y sshpass docker.io kubeadm kubelet kubectl openvswitch-switch curl nfs-common

echo "----------------------------------------------------------"
echo "|  Writing and applying network configuration            |"
echo "----------------------------------------------------------"
echo ""
cat > /etc/netplan/50-cloud-init.yaml <<NET
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  ethernets:
    eth0:
      addresses: [ ${worker02[0]}/24 ]
      gateway4: ${worker02[1]}
      nameservers:
        addresses:
        - 8.8.8.8
      dhcp4: false
    eth1:
      addresses: [ ${worker02[2]}/24 ]
      dhcp4: false
    eth2:
      addresses: [ ${worker02[3]}/24 ]
      dhcp4: false
    eth3:
      dhcp4: false
NET

netplan apply

cat > /etc/hosts <<EOF
$hosts
EOF

cat > ~/.env <<EOF
WORK01_NET=`host network01 | grep "has address" | awk '{print $4}'`
WORK02_NET=`host network02 | grep "has address" | awk '{print $4}'`
MSTR_NET=`host network | grep "has address" | awk '{print $4}'`
EOF

cat >> ~/.bashrc <<ENV
set -a
    [ -f ~/.env ] && . ~/.env
set +a
ENV

# Disable swap (incompatible with K8s 1.7+) and add NFS share mount for internal Docker registry
swapoff -a
sed -i '\$s|/swap|\#/swap|' /etc/fstab
echo "storage:/certs       /etc/docker/certs.d      nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab

# Enable IP forwarding for some later functionality
echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | tee -a /etc/sysctl.conf

# Reload
sysctl -p /etc/sysctl.conf

echo "--------------------------------------------------------"
echo "| Configuring systemd cgroupdriver for Docker          |"
echo "--------------------------------------------------------"
echo ""
# Change Docker manager to systemd, not cgroup
tee /etc/docker/daemon.json <<DOC
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
DOC

mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl enable docker
systemctl restart docker

mkdir -p /etc/docker/certs.d

# Sleep to ensure docker process is started fully and that cgroup driver is loaded properly
echo -e "Please wait while we do some things..."
sleep 15

usermod -aG docker greyadmin

echo "--------------------------------------------------------"
echo "| Initializing Kubernetes Cluster!                     |"
echo "|  I can take a couple of minutes, please be patient...|"
echo "--------------------------------------------------------"
echo ""
`grep -A 2 "kubeadm join" cluster-init`

WK2


chmod +x worker01.sh
chmod +x worker02.sh

sshpass -e scp -o StrictHostKeyChecking=no worker01.sh $user@worker01:~/worker01.sh
echo $SSHPASS | sshpass -e ssh -o StrictHostKeyChecking=no $user@worker01 cat \| sudo --prompt="" -S -- ./worker01.sh

sshpass -e scp -o StrictHostKeyChecking=no worker02.sh $user@worker02:~/worker02.sh
echo $SSHPASS | sshpass -e ssh -o StrictHostKeyChecking=no $user@worker02 cat \| sudo --prompt="" -S -- ./worker02.sh

testcount=0
while [ "$(kubectl get nodes | awk -v cnt="2" '{if (NR>cnt) {print $2}}')" != "Ready" ]
do
    echo "...Waiting for all Worker nodes to report a ready status..."
    sleep 10
    let testcount=$testcount+1
    if [ $testcount -eq 60 ]
    then
	    echo "|--------------------------------------------------------------------------------"
	    echo "|"
	    echo "| It has been 600 seconds since the last worker was added to the cluster..."
	    echo "|"
	    echo "| There may be a problem with your cluster. Please log into the worker nodes"
	    echo "| manually to check the status of the kubelet and/or docker processes and the"
	    echo "| output of the /var/log/syslog file to troubleshoot this potential issue."
	    echo "| NOTE: here may not be any problems other than network delays in pulling the"
	    echo "| docker containers required to run the cluster."
	    echo "|"
	    echo "| You can feel free to wait a little longer, or begin troubleshooting now, it's up"
	    echo "| to you..."
	    echo "|"
	    echo "| To check the status of the nodes use the commands below"
	    echo "|	- kubectl get nodes"
	    echo "|	- kubectl describe nodes <node name>"
      echo "|"
      echo "| If you have any questions, comments, or concerns, about this range, please"
      echo "| feel free to raise an Issue on my github:"
      echo "|"
      echo "|     https://github.com/1computerguy/cbcr"
      echo "|"
	    echo "|---------------------------------------------------------------------------------"

	    exit 1
     fi
done

echo "|-------------------------------------------------------------------------"
echo "|"
echo "| Your Kubernetes cluster is now configured and ready to use."
echo "|"
echo "| Make sure the 'range' command is somewhere in your executable path"
echo "| and run that command with the -h or --help option to see what you can"
echo "| do inside this range environment. Of course, you are welcome to do"
echo "| whatever you wish with this cluster, and even use this config, simply as"
echo "| a means of automating the build of a K8s cluster - that's totally your"
echo "| perogative. However, to use this as the Cyber-Range environment it was"
echo "| intended for, check out the 'range' command and play around"
echo "| If you have any questions, comments, or concerns, please feel free"
echo "| to raise an Issue on my github:"
echo "|"
echo "|     https://github.com/1computerguy/cbcr"
echo "|"
echo "|--------------------------------------------------------------------------"

exit 0
