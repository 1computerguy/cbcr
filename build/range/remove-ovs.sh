#!/bin/bash

for br in `sudo ovs-vsctl list-br`
do
    sudo ovs-vsctl del-br $br
done