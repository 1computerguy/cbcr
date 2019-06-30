#!/usr/bin/python3


import csv
import os

svc_cfg_file = "range_services.csv"
net_cfg_file = "range_network.csv"
net_svc_reader = csv.reader(open(svc_cfg_file))
net_net_reader = csv.reader(open(net_cfg_file))

net_write = open(os.environ["K8S_CONFIGS"] + "/01-bridge-nets.yml", "w+")

br_lst = []
net_attach_def = """
---
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: {network}
spec:
  config: '{{
      "cniVersion": "0.3.1",
      "type": "ovs",
      "bridge": "{network}",
      "vlan": 100
    }}'
"""
for row in net_svc_reader:
    if row[0] != 'svc_category':
        if row[3] not in br_lst:
            net_write.write(net_attach_def.format(network=row[3]))
            br_lst.append(row[3])

for row in net_net_reader:
    if row[0] != "k8s_pod_name":
        if row[1] not in br_lst:
            net_write.write(net_attach_def.format(network=row[1]))
            br_lst.append(row[1])

        if row[8] not in br_lst:
            net_write.write(net_attach_def.format(network=row[8]))
            br_lst.append(row[8])

net_write.close()
