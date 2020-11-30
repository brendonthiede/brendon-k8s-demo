#!/bin/bash

mkdir -p /etc/setup
cp -R /vagrant/kubernetes-setup/* /etc/setup
find /vagrant/kubernetes-setup -type f -name '*.sh' -exec bash -c "sed -i 's/\\r//g' {} && chmod +x {}" \;

/etc/setup/common/all.sh
/etc/setup/node/all.sh

chown -R vagrant:vagrant /home/vagrant
