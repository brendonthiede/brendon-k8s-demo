#!/bin/bash

mkdir -p /etc/setup
cp -R /vagrant/multi-node/hardway/kubernetes-setup/* /etc/setup
cp -R /vagrant/app /etc/setup
find /vagrant/multi-node/hardway/kubernetes-setup -type f -name '*.sh' -exec bash -c "sed -i 's/\\r//g' {}; chmod +x {}" \;

/etc/setup/common/all.sh
/etc/setup/controller/all.sh

chown -R vagrant:vagrant /home/vagrant
