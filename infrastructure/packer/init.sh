#!/bin/bash

set -x

echo "Start prepare environment"

sudo yum update -y
# Install JDK 8
sudo yum install -y java-1.8.0-openjdk-devel
sudo alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk/bin/java
sudo yum install -y htop
echo 'export JAVA_HOME="/usr/lib/jvm/jre-1.8.0-openjdk"' >> ~/.bashrc
echo 'PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source .bashrc
rm -rf jdk-8u191-linux-x64.rpm

# Install AWS Logs
sudo yum install -y awslogs
echo 'sudo systemctl start awslogsd' >> .bashrc
sudo systemctl enable awslogsd.service

echo "Finish prepare environment"