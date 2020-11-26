#!/bin/bash

mkdir -p /etc/setup/common
cp /vagrant/bash/common/*.sh /etc/setup/common/
chmod a+x /etc/setup/common/*.sh
/etc/setup/common/all.sh

mkdir -p /etc/setup/node
cp /vagrant/bash/node/*.sh /etc/setup/node/
chmod a+x /etc/setup/node/*.sh
/etc/setup/node/all.sh

chown -R vagrant:vagrant /home/vagrant
