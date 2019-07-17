# Container-Based Cyber Range running in Kubernetes
This is a repository for a Container based Cyber Range that runs in 3 Virtual Machines.


## Prep the Infrastructure environment:
#### Requires 4 virtual switch port groups (can segregate these with VLANs, but not a requirement) – NOTE: If using a product like VMware Workstation, LAN Segments are useful for the Cluster storage, Cluster overlay, and External NICs. If using something like VirtualBox, then connect NIC to a separate network, and ensure the management network has Internet connectivity.
- 1 – management connection with Internet connectivity
- 1 – Cluster storage network for NFS share for container data distribution
- 1 – Cluster overlay network for OVS VXLAN network across Pods
- 1 – External port group for connections from outside the cluster

#### Create 3 Ubuntu 18.04 Server VMs (NOTE: Internet connection required for the initial build, once the range is set up, can, and probably should operate disconnected):
- Hostnames: master, worker01, worker02
- 4 CPU (the more, the better) 
- 6GB RAM (the more, the better) 
- 60GB Disk
- 4 vNIC
  - mgmt (has Internet)
  - storage
  - internal overlay
  - external connect

#### Install Ubuntu 18.04 Server, using the following
- Configure static IP for the first NIC on all 3 nodes
- Common Ubuntu NIC names for different hypervisors
  - eth0 for Xenserver
  - ens160 for VMware esxi
  - ens33 for VMware Workstation
  - enp0s3 for VirtualBox
- Remember the address and gateway used as they will be used in a configuration file later 
- Set hostnames according to step 2a above
- Create the same username and password across all three nodes
- Select defaults for all other configuration settings
- Install OpenSSH Server
- Do not install any meta-packages (the options at the end)

#### Install VM Tools
After reboot:
- Install git - `sudo apt install git -y`
- Instructions below for Xenserver tools install
  - In the XenCenter management console select the desired VM’s console tab
  - Select VM > Install XenServer Tools...
  - Click inside the VM console
  - Run the `lsblk -f` command and look for the device with Xenserver Tools iso mounted (mine was sr0)
  - Mount sr0: `sudo mount /dev/sr0 /mnt`
  - Navigate to the /mnt/Linux directory: `cd /mnt/Linux`
  - Run the installer: `sudo ./install.sh`
  - Unmount disk: `cd ~/ && sudo umount /mnt`
- Power off after installing tools and take a snapshot: `sudo poweroff`

#### Take a snapshot of all 3 VMs while they are powered off
- VERY helpful in the event something goes wrong with the deployment scripts
- Often easier to troubleshoot by starting over
- Kubernetes can be finicky at times and redeployment can sometimes work better than trying to troubleshoot endlessly 

#### Build Cluster
From Master VM (after reboot):
- Clone git repo: `git clone https://github.com/1computerguy/cbcr.git`
- Navigate to the cbcr/build/cluster directory: `cd cbcr/build/cluster`
- Modify the `cluster_cfg.csv` file to match your network IP/hostname configuration
- Csv file structure: hostname,mgmt_ip,mgmt_gateway,storage_ip,overlay_ip
  - Hostname – for compatibility, do not change hostnames from those configured in step 3a(iii) and those mentioned in step 2a
  - Management IP: static address configured in OS install
  - Management Gateway: address used in OS install
    - For Internet access during setup
    - Recommended to remove this when using the range, or better yet, disconnect it from the Internet completely after setup
  - Storage IP: Static address with no gateway for NFS connections
  - Internal overlay network IP: Static address with no gateway for the container-based network interconnections

##### NOTE: Packages are updated and installed during cluster initialization. If a prompt appears stating "Restart services during package upgrades without asking?”, select “Yes”.

- Run the build_cluster.sh file on the MASTER node (if your password has special characters, make sure to enclose it in quotes):
  - `sudo ./build_cluster.sh -u <current username> -p “<worker ssh password>” -f <cluster config file>`
  - If you see an error like the one below, wait 3-5 minutes and try again. It seems that Ubuntu checks for updates on boot and locks the update file.
    -	E: Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)
    -	E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
    - OR, you can manually stop the process by using `ps aux | grep apt`, then use a `sudo pkill -9 <proc id>`
- Once the script gets to the "...Waiting for all Worker nodes to report a ready status..." prompt:
  - Open a terminal to worker01
    - Run the worker01.sh script in the home folder
    - `sudo ./worker01.sh`
    - Log out of the node and log back in - (this is necessary to populate environment variables for use in other deployment scripts)
  - Open a terminal to worker02
    - Run the worker02.sh script in the home folder
    - `sudo ./worker02.sh`
    - Log out of the node and log back in - (this is necessary to populate environment variables for use in other deployment scripts)
- After running worker scripts on each worker, go back to the master and, check the status of the "...Waiting..." Prompt - should be finishing up soon.
  - If the Warning prompt that it has been "600" seconds pops up, check out the deployment's status manually
  - Here's a couple of commands to run from the master node to help troubleshoot:
  - Use this to get the high-level view of node status
    - `kubectl get nodes`
  - Looking at pod status to see if all are in a "Running" state
    - `kubectl get pods --all-namespaces`
  - You can also run this to get detailed information on a pod that is not running
    - `kubectl describe pod <pod name> -n kube-system`
  - Detailed node status. Looking for any errors in node status or deployment
    - `kubectl describe nodes`
  - To help troubleshoot from the worker nodes:
    - Verify the docker service is running
      - `sudo systemctl status docker`
    - Verify the Kubernetes service is running properly
      - `sudo systemctl status kubelet`
      - Run this if the kubelet service is not running. Look for kubelet start processes and error messages to Google for assistance.
        - `journalctl -xe`
      - If the kubelet service is not running and there is an error concerning the cgroup driver
        - Modify kubeadm cgroup driver in `/var/lib/kubelet/kubeadm-flags.env`
        - `sudo nano /var/lib/kubelet/kubeadm-flags.env`
        - Change cgroup driver to systemd, save and exit
          - `restart kubelet service`
          - `sudo systemctl restart kubelet`
  - If none of that works, sometimes, it is easiest to revert to snapshot (assuming you took one in the pre-setup stage)

#### Now, with a working cluster, navigate to the ~/cbcr/build/management directory:
- `cd ~/cbcr/build/management`
- FIRST, run pre_build_management.sh
  - `./pre_build_management.sh`
- SECOND, Log out of the system, and log back in. This process sets environment variables used throughout the remainder of the set up. If you skip this step, things will not work correctly, and you will spend a LOT of time troubleshooting...
- THIRD, after you log back in, navigate back to the $REPO_HOME/build/management directory and run the following commands
  - `cd $REPO_HOME/build/management`
  - `./build_management.sh -u <username>`
    - This name is the username setup for each node during install
  - Log into each worker and update mount by running the below command:
    - `sudo mount -a`
- Once management completes, go to the $REPO_HOME/build/range directory and run the following:
  - `cd ../range`
  - `./build_range_all.sh -u <username> -p <password>`
    - Enter the username and password of your nodes
- Once complete, log into each worker and run the following commands to verify completion
  - `sudo ovs-vsctl show`
  - You are looking for a list of OpenVswitch bridges, and, inspect the bridge named bgp for the bro0 internal interface (this is the Bro IDS mirror interface)
- Once the environment is built, and the underlying structure is in place, you are ready to run your range environment. It is currently static, but I am working toward a dynamic configuration model.
  - To startup all the range services run the following:
  - `kubectl create -f $K8S_CONFIGS`
  - This process will start the range with the services outlined in the `range_services.csv` file and the router network described in the `range_network.csv` file

##### NOTE: Initial creation of this environment will take approximately 10-15+ minutes depending on hardware, and the VPN servers can take up to 20+ minutes depending on how long it takes the init-containers to generate secure keys. Use some of the same troubleshooting commands above if there are startup issues.

#### To access the environment
- Build a Virtual machine and connect it to the port group created for the “external” NIC on the Master node
  - Configure it with an IP in the 167.2.127.xxx/24, a gateway of 167.2.127.1, and DNS of 8.8.8.8 or 9.9.9.9 
- To access the Kibana dashboard, use a system with management network access to navigate to the management IP address port 30001.
  - `http://<mgmt ip>:30001`
  - Select Management in the left-hand navigation pane
  - Select Index Patterns
    - If it tells you “No data found” or “No data captured” or something along those lines, wait a little bit, or generate some data from your connected VM by navigating to a couple of websites or pinging some IPs in the network, then refresh the page
    - Sites/IPs to use for testing:
      - https://www.google.com
      - https://www.yandex.ru
      - https://www.microsoft.com
      - 167.2.127.1
      - 167.2.126.1
      - 8.8.8.8
      - 41.0.0.1
    - For a listing of more sites/IPs, check out the `$REPO_HOME/build/range/range_services.csv` file
  - In the Index Pattern section type “logstash-*” and select Next Step
  - If you wish to use the pre-configured dashboard, follow the steps below:
    - Download the following file and save it to your local disk:
    - `https://raw.githubusercontent.com/1computerguy/cbcr/master/resources/kibana_dashboard/cbcr-kibana-export.json`
    - `http://<mgmt ip>:30001`
    - Select Management in the left-hand navigation pane
    - Select Saved Objects
    - In the top right of the window, select Import
    - In the window that opens, select the cbcr-kibana-export.json file downloaded previously
    - Select Yes, overwrite all
    - After import:
      - In the left-hand pane, select Dashboard
      - Then select the item called Dashboard in the center of the window
      - If performed correctly, you should see something like the below window

##### NOTE: If you just set up your range, it may not look like the one below. This environment has been running for some time.
