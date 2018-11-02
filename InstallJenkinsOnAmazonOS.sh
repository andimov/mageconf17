#!/bin/bash
yum update –y
yum install java -y
yum install -y docker
service docker start
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
yum install jenkins -y
usermod -a -G docker ec2-user
usermod -a -G docker jenkins
curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose
usermod -a -G ec2-user jenkins
systemctl enable docker


cd /var/lib/jenkins/ && curl -k -O https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-3.1.tgz 
tar zxf apache-jmeter-3.1.tgz
curl -k -O https://jmeter-plugins.org/files/packages/jpgc-json-2.6.zip /var/lib/jenkins/
/var/lib/jenkins/apache-jmeter-3.1/bin/jmeter -v
unzip /var/lib/jenkins/jpgc-json-2.6.zip -d /var/lib/jenkins/apache-jmeter-3.1
cd /var/lib/jenkins/apache-jmeter-3.1/bin/
curl -k -O https://raw.githubusercontent.com/andimov/mageconf18/master/benchmark.jmx
mkdir /var/lib/jenkins/apache-jmeter-3.1/bin/files
cd /var/lib/jenkins/apache-jmeter-3.1/bin/files
curl -k -O https://raw.githubusercontent.com/magento/magento2/2.2/setup/performance-toolkit/files/search_terms.csv
chown jenkins:jenkins -R /var/lib/jenkins  

service jenkins start
curl ipecho.net/plain ; echo :8080/ 
sleep 10 && sudo cat /var/lib/jenkins/secrets/initialAdminPassword
