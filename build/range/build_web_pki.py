#!/usr/bin/python3

import csv
import os

svc_cfg_file = "range_services.csv"
web_reader = csv.reader(open(svc_cfg_file))

command = ''
cont_name = ''
for row in web_reader:
    if row[0] != 'svc_category':
        if row[4] == 'web':
            if row[5] == 'http' or row[5] == 'https':
                command = "./sign_cert.sh -s {dom}".format(dom=row[1])
                
                os.system(command)