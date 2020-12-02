#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

apt-get -qq update
apt-get -qq -y install unzip >/dev/null

cd ${SCRIPT_DIR}
rm -rf /tmp/setup /etc/setup && mkdir -p /tmp/setup
unzip -qq ./setup.zip -d /tmp/setup/ && rm -f ./setup.zip
mv ./setup /etc/

find /etc/setup -type f -name '*.sh' -exec bash -c "sed -i 's/\\r//g' {}; chmod +x {}" \;
