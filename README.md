# Cyber-Range-K8s

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
- Or, you can just copy/paste the below commands:
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt install -y docker.io python-docker python-ruamel.yaml pv \
                    git golang-cfssl python-pip3 kubeadm kubelet \
                    kubectl
pip3 install cfssl
```
- Clone this repository and cd into the `cyber-range-k8s-vms` folder
- Copy the `range` script into the `/usr/local/bin` directory and ensure it is executable
```
cd cyber-range-k8s-vms
sudo cp range /usr/local/bin/
sudo chmod +x /usr/local/bin/range
```

#TODO:
- Write scirpt to automate cluster configuration and deployment
