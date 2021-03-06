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
                cont_name = row[1].replace('.', '-')
                command = "docker run --rm -i --init -d -e "
                command += "URL={dom} -u root ".format(dom=row[1])
                command += "--cap-add=SYS_ADMIN -v {mnt}:/web/output ".format(mnt=os.environ["CONFIG_HOME"] + "/web")
                command += "-v {scrape_dir}:/data --name get-{dom} master:5000/site-downloader ".format(scrape_dir=os.environ["REPO_HOME"] + "/build/range/scraper",dom=cont_name)
                command += "node /data/scrape.js"
                
                os.system(command)
                #print(command)