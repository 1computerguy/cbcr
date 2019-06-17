#!/bin/bash

###############################
#
#  Placeholder for automated build script
#
###############################

usage() {
    echo ""
    echo "Please make sure all the systems you are configuring have a common username and password."
    echo "Add the password, and the csv configuration file to build the cluster."
    echo ""
    echo " ----"
    echo -e "    Example: $0 -p <password> -f <configfile.csv>"
    echo " ----"
    echo ""
    echo "CSV file contains the following columns:"
    echo -e "   - hostname"
    echo -e "   - management IP"
    echo -e "   - storage IP"
    echo -e "   - OVS Overlay IP"
    echo ""
    echo "----"
    echo "Example of configfile.csv file:"
    echo -e "    master,192.168.1.10,10.10.1.10,10.10.2.10,10.10.3.10,192.168.1.1"
    echo -e "    worker01,192.168.1.11,10.10.1.11,10.10.2.11,10.10.3.11,192.168.1.1"
    echo -e "    worker02,192.168.1.12,10.10.1.12,10.10.2.12,10.10.3.12,192.168.1.1"
    echo "----"
    echo ""
}

# Set arguments as IP variables
if [ $# -gt 1 ]
then
    count=0
    while [ "$1" != "" ]
    do
        case $1 in
            -p | --password )
                shift
                export SSHPASS="$1"
                ;;
            -f | --filename )
                shift
                filename="$1"
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

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt install -y docker.io python-docker python-ruamel.yaml pv \
                    git python-pip kubeadm kubelet kubectl geoipupdate \
                    docker-compose openvswitch-switch nfs-common

pip install dnspython
pip install geoip2

sudo swapoff -a
sudo sed -i '$s|/swap|\#/swap|' /etc/fstab

sudo modprobe nfs
sudo modprobe nfsd

sudo tee -a /etc/modules <<EOF
nfs
nfsd
EOF

cat >> /etc/hosts <<EOF
${master[1]}      ${master[0]}
${master[2]}      storage
${master[3]}      network
${worker01[1]}      ${worker01[0]}
${worker02[1]}      ${worker02[0]}
EOF

# Change Docker manager to systemd, not cgroup
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl restart docker

sudo usermod -aG docker greyadmin

# Create default range directories
# TODO: Make this user configurable
sudo mkdir -p /range/{infrastructure,environment,stats}
sudo mkdir -p /range/infrastructure/{geoip,rancher,registry,pki}
sudo mkdir -p /range/infrastructure/pki/{root-ca,intermed-ca}
sudo mkdir -p /range/environment/{attack,monitor,service,traffic,network,vulnerable}
sudo chown -R greyadmin:greyadmin /range

openssl req  -newkey rsa:4096 -nodes -sha256 -keyout /range/infrastructure/registry/domain.key  -x509 -days 365 -out /range/infrastructure/registry/domain.crt -subj "/CN=master"
sudo mkdir -p /etc/docker/certs.d/master:5000
sudo cp /range/infrastructure/registry/domain.crt /etc/docker/certs.d/master:5000/ca.crt

echo -e "--------"
echo -e "Initializing Kubernetes..."
echo -e "--------"
echo ""
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 > cluster-init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown greyadmin:greyadmin $HOME/.kube/config

kubectl apply -f cni/flannel.yml

while [ "$(kubectl get nodes | awk '{if (NR!=1) {print $2}}')" != "Ready" ]
do
    echo "...Waiting for Primary CNI to load and cluster node to be Ready..."
    sleep 2
done

echo "Installing Multus-CNI..."
kubectl apply -f cni/multus.yml

while [ "$(kubectl get pods --all-namespaces | grep multus | awk '{print $4}')" != "Running" ]
do
    echo "...Waiting for Multus CNI to load properly..."
    sleep 2
done

echo "Now installing OVS CNI"
kubectl apply -f cni/ovs.yml

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

cat > worker01.sh <<EOL
#!/bin/bash

usage() {
    echo "----------------------------------------------------------"
    echo "* This script requres a -p <password> option to work properly"
    echo "* This option is used to run the sudo command without continuous"
    echo "* interaction from the administrator"
    echo "* If you prefer not to run the script this way, then remove the"
    echo "* lines of this script marked in the comments."
    exit
}

#############################################################################
#  Begin commenting/removing here - if you don't want want use the automated
#  password entry
#############################################################################
fi [ $# -gt 1 ]
then
    case $1 in
        -p | --password )
            shift
            export SSHPASS="$1"
            ;;
        * )
            usage
            ;;
else
    usage
fi

#############################################################################
#  END REMOVAL
#############################################################################

sudo cat > /etc/netplan/50-cloud-init.yaml <<NET
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  ethernets:
    ens160:
      addresses: [ ${worker01[1]} ]
      gateway4: ${worker01[5]}
      nameservers:
        addresses:
        - 1.1.1.1
        - 8.8.8.8
      dhcpv4: false
    ens192:
      addresses: [ ${worker01[2]} ]
      dhcp4: false
    ens224:
      addresses: [ ${worker01[3]} ]
      dhcp4: false
NET

sudo netplan apply

# Reload
sysctl -p /etc/sysctl.conf

# Add kubernetes repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# Install Updates
sudo apt update
sudo apt upgrade -y

# Install packages
sudo apt install sshpass docker.io kubeadm kubelet kubectl openvswitch-switch curl nfs-common -y

sudo cat > /etc/hosts <<EOF
$hosts
EOF

# Disable swap (incompatible with K8s 1.7+)
sudo swapoff -a
sudo sed -i '$s|/swap|\#/swap|' /etc/fstab

# Enable IP forwarding for some later functionality
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf

# Change Docker manager to systemd, not cgroup
sudo cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload

# Start and Enable Docker
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker greyadmin

sudo `grep -A 2 "kubeadm join" init-file`

EOL

echo "*--------------------------------"
echo "*"
echo -e "*  Writing Worker02 configuration to worker02.sh..."
echo "*"
echo "*--------------------------------"

cat > worker02.sh <<EOL
#!/bin/bash

usage() {
    echo "----------------------------------------------------------"
    echo "* This script requres a -p <password> option to work properly"
    echo "* This option is used to run the sudo command without continuous"
    echo "* interaction from the administrator"
    echo "* If you prefer not to run the script this way, then remove the"
    echo "* lines of this script marked in the comments."
    exit
}

#############################################################################
#  Begin commenting/removing here - if you don't want want use the automated
#  password entry
#############################################################################
fi [ $# -gt 1 ]
then
    case $1 in
        -p | --password )
            shift
            export SSHPASS="$1"
            ;;
        * )
            usage
            ;;
else
    usage
fi

#############################################################################
#  END REMOVAL
#############################################################################

sudo cat > /etc/netplan/50-cloud-init.yaml <<NET
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  ethernets:
    ens160:
      addresses: [ ${worker02[1]} ]
      gateway4: ${worker02[5]}
      nameservers:
        addresses:
        - 1.1.1.1
        - 8.8.8.8
      dhcpv4: false
    ens192:
      addresses: [ ${worker02[2]} ]
      dhcp4: false
    ens224:
      addresses: [ ${worker02[3]} ]
      dhcp4: false
NET

sudo netplan apply

# Reload
sysctl -p /etc/sysctl.conf

# Add kubernetes repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# Install Updates
sudo apt update
sudo apt upgrade -y

# Install packages
sudo apt install sshpass docker.io kubeadm kubelet kubectl openvswitch-switch curl nfs-common -y

sudo cat > /etc/hosts <<EOF
$hosts
EOF

# Disable swap (incompatible with K8s 1.7+)
sudo swapoff -a
sudo sed -i '$s|/swap|\#/swap|' /etc/fstab

# Enable IP forwarding for some later functionality
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf

# Change Docker manager to systemd, not cgroup
sudo cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload

# Start and Enable Docker
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker greyadmin

sudo `grep -A 2 "kubeadm join" init-file`

EOL


chmod +x worker01.sh
chmod +x worker02.sh

sshpass -e scp -o StrictHostKeyChecking=no worker01.sh greyadmin@worker01:~/worker01.sh
sshpass -e ssh -o StrictHostKeyChecking=no greyadmin@worker01 sudo ./worker01.sh -p "P@55w0rd!"

sshpass -e scp -o StrictHostKeyChecking=no worker02.sh greyadmin@worker02:~/worker02.sh
sshpass -e ssh -o StrictHostKeyChecking=no greyadmin@worker02 sudo ./worker02.sh -p "P@55w0rd!"

testcount=0
while [ "$(kubectl get nodes | awk -v cnt="2" '{if (NR>cnt) {print $2}}')" != "Ready" ]
do
    echo "...Waiting for all Worker nodes to report a ready status..."
    sleep 2
    let testcount=$testcount+1
    if [ $testcount -eq 30 ]
    then
	    echo "|--------------------------------------------------------------------------------"
	    echo "|"
	    echo "| It has been 60 seconds since the last worker was added to the cluster..."
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
        echo "| feel free to raise an Issue on my github repo for this environment:"
        echo "|"
        echo "|     https://github.com/1computerguy/container-range-k8s.git"
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
echo "| to raise an Issue on my github repo for this environment:"
echo "|"
echo "|     https://github.com/1computerguy/container-range-k8s.git"
echo "|"
echo "|--------------------------------------------------------------------------"