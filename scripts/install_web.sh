#!/bin/bash

yum update -y
sudo yum -y install docker
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chmod 666 /var/run/docker.sock
sudo systemctl daemon-reexec
docker-compose -f /home/ec2-user/deployment/docker-compose.yml up -d