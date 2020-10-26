#!/bin/bash

# Installs the stable branch of nginx on a ubuntu server

echo "Installing curl gnupg2 ca-certificates lsb-release"
sudo apt install curl gnupg2 ca-certificates lsb-release

echo "adding the apt repo for nginx"
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

echo "adding the nginx signing key"
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -

echo "update and install nginx"
sudo apt update
sudo apt install nginx