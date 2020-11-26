#!/bin/bash

mkdir -p /etc/setup/common
cp /vagrant/bash/common/*.sh /etc/setup/common/
chmod a+x /etc/setup/common/*.sh
/etc/setup/common/all.sh

mkdir -p /etc/setup/controller
cp /vagrant/bash/controller/*.sh /etc/setup/controller/
chmod a+x /etc/setup/controller/*.sh
/etc/setup/controller/all.sh

chown -R vagrant:vagrant /home/vagrant
