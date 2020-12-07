#!/bin/bash
set -e

# Create pip config file with repository and Artifactory credentials set
mkdir -p ~/.config/pip
cat > ~/.config/pip/pip.conf <<_EOF
[global]
index-url = https://pypi.org/simple
trusted-host =  pypi.org
_EOF