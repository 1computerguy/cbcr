#!/bin/bash

usage() {
    echo ""
    echo "Please make sure all the systems you are configuring have a common username and password."
    echo "Add the password to the command to automate the deployment of OVS to the worker nodes."
    echo ""
    echo " ----"
    echo -e "    Example: $0 -p <password>"
    echo " ----"
    echo ""
    echo ""
}

# Set arguments as IP variables
if [ $# -gt 1 ]
then
    while [ "$1" != "" ]
    do
        case $1 in
            -p | --password )
                shift
                export SSHPASS="$1"
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

# Build website scraper and start scraping sites
echo "---------------------------------------------------------"
echo "|  Building the website scraper. This will be used to   |"
echo "|  pull download web content and populate sites for     |"
echo "|  deployment to the nginx servers"
echo "---------------------------------------------------------"
echo ""
cd scraper
./build.sh
cd ..

echo "-----------------------------------------------------------"
echo "|  Scraping / Downloading websites listed in the          |"
echo "|  range_services.csv file. This process will run in the  |"
echo "|  backbround and can take between 30-45 min.             |"
echo "|                                                         |"
echo "|  Use the docker ps -a command to see if there are any   |"
echo "|    remaining web scrapers after about 30 or so minutes  |"
echo "|    I have found that any still running after this amount|"
echo "|    of time can be safely stopped without causing major  |"
echo "|    problems."
echo "-----------------------------------------------------------"
echo ""
python3 build_web.py

echo "---------------------------------------------------------"
echo "|  Building all containers required for environment     |"
echo "|                                                       |"
echo "---------------------------------------------------------"
echo ""
cd $REPO_HOME/range_svcs
./build_all.sh

# Call build_range_helper.py script to ingest range_services.csv file and build and
# deploy the remaining configurations
echo "---------------------------------------------------------"
echo "|  Building the Kubernetes yaml configuration files     |"
echo "|  This process can take up to 3-5 minutes to complete  |"
echo "---------------------------------------------------------"
echo ""
python3 build_k8s_deps.py

# Build Router Configs
echo "-----------------------------------------------------------"
echo "|  Building the router configuration files zebra.conf and |"
echo "|  bgpd.conf and copying necessary daemons files to the   |"
echo "|  appropriate locations.                                 |"
echo "-----------------------------------------------------------"
echo ""
python3 build_rtr_cfgs.py

# Build DNS
echo "-----------------------------------------------------------"
echo "|  Generating authoritative DNS entries based on          |"
echo "|  range_services.csv entries. These will serve as the    |"
echo "|  in-range DNS entries.                                  |"
echo "-----------------------------------------------------------"
echo ""
python3 build_dns.py

# Build OVS Bridges for overlay network
echo "------------------------------------------------------------"
echo "|  Building OpenVswitch bridges for overlay network        |"
echo "|                                                          |"
echo "| This will run on worker nodes too, make sure to check    |"
echo "| for completion using the following command on each node: |"
echo "|   sudo ovs-vsctl show                                    |"
echo "------------------------------------------------------------"
echo ""

sudo ./build_ovs_links.sh -l bgp rtr1-svc rtr2-svc rtr3-svc rtr4-svc rtr5-svc rtr6-svc external

sshpass -e scp -o StrictHostKeyChecking=no build_ovs_links.sh worker01:~/build_ovs_links.sh
echo $SSHPASS | sshpass -e ssh -o StrictHostKeyChecking=no worker01 cat \| sudo --prompt="" -S -- ./build_ovs_links.sh -l bgp rtr1-svc rtr2-svc rtr3-svc rtr4-svc rtr5-svc rtr6-svc external

sshpass -e scp -o StrictHostKeyChecking=no build_ovs_links.sh worker02:~/build_ovs_links.sh
echo $SSHPASS | sshpass -e ssh -o StrictHostKeyChecking=no worker02 cat \| sudo --prompt="" -S -- ./build_ovs_links.sh -l bgp rtr1-svc rtr2-svc rtr3-svc rtr4-svc rtr5-svc rtr6-svc external


# Build external access network namespace and configure for network
echo "-----------------------------------------------------------"
echo "|  Building Mirror ports for Bro IDS Logging              |"
echo "|                                                         |"
echo "|  Use Kibana to view logged data at the master mgmt IP   |"
echo "|  port 30001                                             |"
echo "-----------------------------------------------------------"
echo ""
if [ $HOSTNAME == 'master' ]
then
    sudo ./build_mirror.sh external m0 bro0
else
    sshpass -e scp -o StrictHostKeyChecking=no build_mirror.sh worker01:~/build_mirror.sh
    echo $SSHPASS | sshpass -e ssh -o StrictHostKeyChecking=no worker01 cat \| sudo --prompt="" -S -- ./build_mirror.sh bgp m0 bro0

    sshpass -e scp -o StrictHostKeyChecking=no build_mirror.sh worker02:~/build_mirror.sh
    echo $SSHPASS | sshpass -e ssh -o StrictHostKeyChecking=no worker02 cat \| sudo --prompt="" -S -- ./build_mirror.sh bgp m0 bro0
fi


# Build external access network namespace and configure for network
echo "-----------------------------------------------------------"
echo "|  Creating/configuring external connection namespace     |"
echo "|                                                         |"
echo "-----------------------------------------------------------"
echo ""
sudo ovs-vsctl add-port external ext-con -- set Interface ext-con type=internal
sudo ip netns add ext-con-ns
sudo ip link set ext-con netns ext-con-ns
sudo ip netns exec ext-con-ns ip addr add 167.2.126.2/24 dev ext-con
sudo ip netns exec ext-con-ns ip link set ext-con up
sudo ip link set eth3 netns ext-con-ns
sudo ip netns exec ext-con-ns ip addr add 167.2.127.1/24 dev eth3
sudo ip netns exec ext-con-ns ip link set eth3 up
sudo ip netns exec ext-con-ns ip route add default via 167.2.126.1


echo ""
echo "------------------------------------------------------------"
echo "|    ************  CONGRATULATIONS!!  *************        |"
echo "|                                                          |"
echo "|  Your environment is setup and almost ready to go!       |"
echo "|  You will need to wait until the web scraper is finished |"
echo "|  which can take quite a while. Go ahead, take a break    |"
echo "|  go get a nice cup of coffee, or spend some time with    |"
echo "|  friends or family while waiting. Once it is complete,   |"
echo "|  you can come back to it and play around. In the mean    |"
echo "|  you might as well have some fun.                        |"
echo "|                                                          |"
echo "|                                                          |"
echo "|  Once you come back, run the command below and all the   |"
echo "|  K8s systems will run and you can play in your new test  |"
echo "|  environment!                                            |"
echo '|    kubectl create -f $K8s_CONFIGS                        |'
echo "|                                                          |"
echo "|  To interact with the environment, connect a VM to the   |"
echo "|  port-group you used for your 'External' bridge.         |"
echo "|  Use the IP information below to route into the range    |"
echo "|  and you can use any of the resources listed in the      |"
echo "|  range_services.csv file.                                |"
echo "|                                                          |"
echo "|   External Network: 167.2.127.0/24                       |"
echo "|                                                          |"
echo "|  OVPN config files are in the $CONFIG_PATH/vpn. Use the  |"
echo "|  OpenVPN client to connect and VPN services within the   |"
echo "|  range for kicks and giggles - and to see VPN traffic    |"
echo "|  because it's realistic and fun to see if you can learn  |"
echo "|  about the encryption algorithms used, etc.              |"
echo "|                                                          |"
echo "------------------------------------------------------------"
echo ""
