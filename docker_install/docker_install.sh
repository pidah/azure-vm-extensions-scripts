#!/bin/bash

# Installing Docker for Centos/Red-Hat 7x
if [ -f /etc/redhat-release ]; then
  if grep 'release 7' /etc/redhat-release >/dev/null; then
    sudo yum update -y
    # sudo yum install -y epel-release
    sudo yum install -y yum-utils

    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce
    sudo systemctl enable docker

    sudo yum install -y epel-release
    sudo yum install -y python-pip
  fi
fi

# Installing Docker for Ubuntu
if [ -f /etc/lsb-release ]; then
  sudo apt-get remove docker docker-engine -y
  sudo apt-get update -y
  sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

  sudo apt-get update -y
  sudo apt-get install python-pip -y

  curl -fsSL https://get.docker.com/ | sh

fi

# Installing docker-compose
sudo pip install docker-compose

# Tune manager user
[ -n "$1" ] && sudo usermod -aG docker $1 || true

# Marking the territory for Ansible
sudo mkdir -p /etc/ansible/facts.d
sudo chmod 755 /etc/ansible/facts.d
for tool in docker docker-compose
do
  ${tool} | sed 's/,//g' | awk '{print "{\"version\": \""$3"\", \"build\": \""$5"\"}"}' | sudo tee /etc/ansible/facts.d/${tool}.fact
done

which docker && which docker-compose && exit 0 || exit 1