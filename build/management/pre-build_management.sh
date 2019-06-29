#!/bin/bash

echo "------------------------------------------------"
echo "Setting environment variables and making sure they persist..."
echo "------------------------------------------------"
echo ""
# Set Environment Variables for use with other scripts and environment validation
export RANGE_HOME=/range
export REPO_HOME=~/cbcr
export MGMT_HOME=/range/mgmt
export CONFIG_HOME=/range/configs
export PKI_HOME=/range/mgmt/pki
export TEMPLATE_DIR=$REPO_HOME/build/range/deployments
export K8S_CONFIGS=$REPO_HOME/k8s_configs

# Copy .env file to home directory for use with .bashrc to load variables on login
cp .env ~/.env

cat >> ~/.bashrc <<ENV
set -a
    [ -f ~/.env ] && . ~/.env
set +a
ENV

echo "------------------------------------------------------------------"
echo "!       Please log out of the terminal and log back in           !"
echo "!    BEFORE continuing. These settings must be in effect         !"
echo "!             for the setup to work properly.                    !"
echo "!                                                                !"
echo "!   When you log back in, come back to this directory and run    !"
echo "!                 the build_managment.sh script                  !"
echo "------------------------------------------------------------------"

exit 0