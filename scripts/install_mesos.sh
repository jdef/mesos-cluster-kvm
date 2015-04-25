#!/bin/bash

set -x

trap 'trap_errors' ERR

trap_errors() {
    echo "Error occured, abort." >&2
    exit 1
}

apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | \
      sudo tee /etc/apt/sources.list.d/mesosphere.list

apt-get -y update
apt-get -y install mesos marathon haproxy curl

# Docker support
echo 'docker,mesos' > /etc/mesos-slave/containerizers
echo '5mins' > /etc/mesos-slave/executor_registration_timeout

curl -s -LO https://raw.githubusercontent.com/mesosphere/marathon/v0.8.1/bin/haproxy-marathon-bridge
chmod +x haproxy-marathon-bridge
./haproxy-marathon-bridge install_haproxy_system localhost:8080 && rm -f haproxy-marathon-bridge
