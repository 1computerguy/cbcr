# Container-Based Cyber Range running in Kubernetes
This is a repository for a Container based Cyber Range that runs in 3 Virtual Machines. If you are interested in this one, you may also like my `container-range-k8s-rpi` that runs a smaller version of this container-based range on a 4 node RaspberryPi cluster.


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
  - kubernetes
  - python-docker
  - python-ruamel.yaml
  - pv
  - golang-cfssl
  - pip3
  - sshpass
- Setup `MASTER` node for NFS Share:
  - Enable the nfs/nfsd drivers
  - Add nfs/nfsd drivers to /etc/modules for persistence
- Change Docker driver from cgroupfs to systemd for K8s compatibility
- Make config directory for NFS share
- Or, you can just copy/paste the below commands:
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt install -y docker.io python-docker python-ruamel.yaml pv \
                    git golang-cfssl python3-pip kubeadm kubelet \
                    kubectl

pip3 install cfssl

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

sudo systemctl enable docker
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo usermod -aG docker greyadmin

sudo mkdir /range
sudo chown -R greyadmin:greyadmin /range
```

- Clone this repository and cd into the `cyber-range-k8s-vms` folder
- To add the `range` command to your path, copy it into the `/usr/local/bin` directory and ensure it is executable
```
cd cyber-range-k8s-vms
sudo cp range /usr/local/bin/
sudo chmod +x /usr/local/bin/range
```

#TODO:
- Write scirpt to automate cluster configuration and deployment
