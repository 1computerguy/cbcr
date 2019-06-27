#!/bin/bash


# Create default range directories
# TODO: Make this user configurable
sudo mkdir -p /range/{infrastructure,environment,stats}
sudo mkdir -p /range/infrastructure/{geoip,rancher,registry,pki}
sudo mkdir -p /range/infrastructure/pki/{root-ca,intermed-ca}
sudo mkdir -p /range/environment/{attack,monitor,service,traffic,network,vulnerable}
sudo chown -R greyadmin:greyadmin /range