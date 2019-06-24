# Example commands
Take a look at the below commands to get a feel for how to use the template file.

Standard deployment without mount path:
```
kuku render -s \
  name=some-pod-name,\
  image=master:5000/somecontainer,\
  replicas=1,\
  env='IP_ADDR LEN GATEWAY INT',\
  vals='1.2.3.4 8 1.0.0.1 net1',\
  netkey=k8s.v1.cni.cncf.io/networks,\
  netval="na-svc" .
```

Standard deployment using NFS volume mount:
```
kuku render -s \
  name=some-pod-name,\
  image=master:5000/somecontainer,\
  replicas=1,\
  env='IP_ADDR LEN GATEWAY INT',\
  vals='1.2.3.4 8 1.0.0.1 net1',\
  netkey=k8s.v1.cni.cncf.io/networks,\
  netval="na-svc",\
  volumeName=mount-some-pod-name,\
  mountPath='/some/container/path',\
  nfsPath='/configs/nfs/path',\
  nfsServer=nfs-server .
```

Deploy the VPN server which has init_containers:
```
kuku render -s \
  name=vpn-privatevpn-com,\
  image=master:5000/openvpn,\
  replicas=1,\
  env='IP_ADDR LEN GATEWAY INT OPEN_VPN_CMD',\
  vals='1.2.3.4 8 1.0.0.1 net1 ovpn_run',\
  netkey=k8s.v1.cni.cncf.io/networks,\
  netval="na-svc",\
  volumeName=mount-privatevpn-com,\
  mountPath='/etc/openvpn',\
  nfsPath='/configs/obfuscation/openvpn/privatevpn.com',\
  nfsServer=nfs-server,\
  vpn_init='genconfig initpki build-client get-client',\
  vpn_cmds=' ovpn_genconfig -u udp://vpn.privatevpn.com; ovpn_initpki nopass"; easyrsa build-client-full testuser nopass; ovpn_getclient testuser > /etc/openvpn/user/testuser.ovpn' .
```