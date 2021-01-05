#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Invalid number of parameters"
	echo "Ex: ./docker_install.sh ubuntu" 
	exit
fi

LINUX_DISTRIB=$1

### Install packages to allow apt to use a repository over HTTPS
sudo apt-get update && sudo apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2

# Add Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/$LINUX_DISTRIB/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

# Add the Docker apt repository:
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$LINUX_DISTRIB \
  $(lsb_release -cs) \
  stable"

sudo apt-get update && sudo apt-get install -y \
  containerd.io \
  docker-ce \
  docker-ce-cli

echo "Docker-ce installed."

sudo apt-mark hold docker-ce

# Set up the Docker daemon
`
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
`
echo "Docker daemon set up."

# Create /etc/systemd/system/docker.service.d
sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
echo "Docker restarted."

# Enable docker service to start on boot
sudo systemctl enable docker

