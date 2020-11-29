#!/bin/bash

mkdir -p /etc/setup
cp -R /vagrant/hardway/* /etc/setup
find /vagrant/hardway -type f -name '*.sh' -exec chmod +x {} \;

/etc/setup/common/all.sh
/etc/setup/node/all.sh

chown -R vagrant:vagrant /home/vagrant
