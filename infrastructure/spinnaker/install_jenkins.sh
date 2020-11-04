#!/bin/bash

# Update
sudo yum update -y

# Install npm
curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -
sudo yum install -y nodejs

# Variables
JENKINS_PASSWORD=$1

# Install Java
sudo yum install -y java-1.8.0-openjdk-devel
sudo alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java

# Add environment variables
echo 'export JAVA_HOME="/usr/lib/jvm/jre-1.8.0-openjdk.x86_64"' >> .bashrc
echo 'PATH=$JAVA_HOME/bin:$PATH' >> .bashrc

# Apply added environment variables
source .bashrc

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install jenkins-2.204-1.1 --nogpgcheck -y
sudo service jenkins start
sudo systemctl enable jenkins.service

# Install AWS create repo
sudo yum install createrepo -y

# Login to Jenkins
echo "Waiting for Jenkins to start"
until $(curl --output /dev/null --silent --head --fail http://localhost:8080/login); do
    printf '.'
    sleep 5
done
curl http://localhost:8080/jnlpJars/jenkins-cli.jar --output "./jenkins-cli.jar"
sudo mv jenkins.yaml /var/lib/jenkins/
export JENKINS_USER_ID=admin
export JENKINS_API_TOKEN=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
export JENKINS_URL=http://localhost:8080

# Create user
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jenkins\", \"${JENKINS_PASSWORD}\")" |
java -jar jenkins-cli.jar -s "$JENKINS_URL" groovy =

# Install plugins
plugins=(allure-jenkins-plugin github aws-java-sdk authentication-tokens cloudbees-bitbucket-branch-source blueocean-bitbucket-pipeline blueocean blueocean-bitbucket-pipeline blueocean-core-js blueocean-pipeline-editor aws-credentials blueocean-commons blueocean-config credentials jenkins-design-language blueocean-dashboard blueocean-display-url docker-commons docker-workflow blueocean-events external-monitor-job favorite blueocean-git-pipeline blueocean-github-pipeline greenballs newrelic-deployment-notifier Office-365-Connector blueocean-personalization pubsub-light sse-gateway simple-theme-plugin ssh-agent variant blueocean-web handy-uri-templates-2-api htmlpublisher blueocean-i18n jaxb jira blueocean-jira blueocean-jwt locale mapdb-api timestamper build-timeout strict-crumb-issuer lockable-resources)
for plugin in "${plugins[@]}"
do
  java -jar jenkins-cli.jar -s "$JENKINS_URL" install-plugin "$plugin" -deploy
done
# Should be installed last
java -jar jenkins-cli.jar -s "$JENKINS_URL" install-plugin configuration-as-code -deploy

# Create Jobs
java -jar jenkins-cli.jar -s "$JENKINS_URL" create-job spring-petclinic-publish-rpm < spring_petclinic_publish_rpm.xml

# Restart Jenkins
sudo systemctl restart jenkins
