# Container-Based Cyber Range running in Kubernetes
This is a repository for a Container based Cyber Range that runs in 3 Virtual Machines, or on a 4 node Raspberry Pi cluster.


## Initial VM Build Instructions
### Current configuration includes 3 VMs
- Build each VM with the following settings:
  - Master
    - CPU: 2 vCPUs
    - RAM: 4GB
    - Disk: 60GB
    - Hostname: master
    - 4 NICS (minimum):
      - IPs:
      - 192.168.1.10/24 (GW/DNS on this network interface)
      - 10.10.0.10/24
      - 10.10.1.10/24
      - 10.10.2.10/24
  - Worker(01 and 02)
    - CPU: 2 vCPUs
    - RAM: 4GB
    - Disk: 40GB
    - Hostname: worker01 / worker02
    - 4 NICS (minimum)
      - IPs:
        - 192.168.1.11/24 (GW/DNS on this network interface)
        - 10.10.0.(11-12)/24
        - 10.10.1.(11-12)/24
        - 10.10.2.(11-12)/24
- Install Ubuntu 18.04 Server using the settings above
  

### AFTER OS Install:
- Add the entries below to the hosts file of each node (master and 2 workers)
```
192.168.1.10	master
10.10.0.10	storage
10.10.1.10	network
10.10.2.10	external
192.168.1.11	worker01
192.168.1.12	worker01
```
- Update Ubuntu and install the following applications on the `MASTER` node only:
  - git
  - docker.io
  - docker-compose
  - kubernetes
  - python-docker
  - python-ruamel.yaml
  - pv
  - pip3
  - golang
  - kubeadm
  - kubelet
  - kubectl
  - gnupg2
  - pass
  - openvswitch

- Setup `MASTER` node for NFS Share:
  - Enable the nfs/nfsd drivers
  - Add nfs/nfsd drivers to /etc/modules for persistence
- Change Docker driver from cgroupfs to systemd for K8s compatibility
- Make config directory for NFS share

- Pull and build DANM CNI for Kubernetes overlay network
- Setup Kubernetes cluster
  - Initialize master
  - Install network CNIs
    - Install flannel first
    - Install Multus
    - Install ovs-cni
  - Join workers to cluster
- Or, you can just copy/paste the below commands:
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt install -y docker.io python-docker python-ruamel.yaml pv \
                    git python-pip kubeadm kubelet kubectl geoipupdate \
                    docker-compose gnupg2 pass openvswitch-switch nfs-common

pip install dnspython
pip install geoip2

gpg2 --full-generate-key
gpg2 -k
pass init "Use the really long number beginning with 21 and ending in 77 below"
############################################
#
# pub   rsa3072 2019-06-09 [SC]
#       2100576B16F240E9977D5D66CFFE2842F2B5E777
# uid                      Bryan Scarbrough <bryan.scarbrough@gmail.com>
# sub   rsa3072 2019-06-09 [E]
#
###############################################################

sudo swapoff -a
sudo sed -i '$s|/swap|\#/swap|' /etc/fstab

sudo modprobe nfs
sudo modprobe nfsd

sudo tee -a /etc/modules <<EOF
nfs
nfsd
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

sudo mkdir -p /range/{infrastructure,environment,stats}
sudo mkdir -p /range/infrastructure/{geoip,rancher,registry,ca}
sudo mkdir -p /range/infrastructure/ca/{root-ca,intermed-ca}
sudo mkdir -p /range/environment/{attack,monitor,service,traffic,network,vulnerable}
sudo chown -R greyadmin:greyadmin /range

openssl req  -newkey rsa:4096 -nodes -sha256 -keyout /range/infrastructure/registry/domain.key  -x509 -days 365 -out /range/infrastructure/registry/domain.crt -subj "/CN=master"
mkdir -p /etc/docker/certs.d/master:5000
cp /range/infrastructure/registry/domain.crt /etc/docker/certs.d/master:5000/ca.crt

# ON WORKERS
sudo su -
sed -i '$s|/swap|\#/swap|' /etc/fstab
mkdir -p /etc/docker/certs.d
echo "storage:/certs       /etc/docker/certs.d      nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
mount -a

```
- Clone this repository and cd into the `cyber-range-k8s/infrastructure` folder
- To add the `range` command to your path, copy it into the `/usr/local/bin` directory and ensure it is executable
```
sudo mkdir /range
sudo chown -R greyadmin:greyadmin /range

cd cyber-range-k8s/infrastructure
sudo cp range /usr/local/bin/
sudo chmod +x /usr/local/bin/range
```

#TODO:
- Write scirpt to automate cluster configuration and deployment
