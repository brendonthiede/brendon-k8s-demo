#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Installing HAProxy"
apt-get -qq update >/dev/null
apt-get -qq install haproxy >/dev/null || fail "Failed to install HAProxy."

# Configure haproxy
cat >/etc/default/haproxy <<EOF
ENABLED=1
EOF

_bind_ip=$(jq -r '.[] | select(.name == "k8s-controller") | .ipv4[]' /etc/setup/vm-list.json)

cat >/etc/haproxy/haproxy.cfg <<EOF
global
    daemon
    maxconn 256

defaults
    mode http
    retries 3
    option redispatch
    timeout connect 5s
    timeout client 50s
    timeout server 50s
EOF

cat >>/etc/haproxy/haproxy.cfg <<EOF

frontend http-in
    bind ${_bind_ip}:80
    default_backend http

backend http
    balance roundrobin
    option httpchk
    option forwardfor
    option http-server-close
EOF

_index=0
for _ipv4 in $(jq -r '.[] | select(.name | test("node-")) | .ipv4[]' ${SETUP_DIR}/vm-list.json); do
    ((_index += 1))
    cat <<EOF >>/etc/haproxy/haproxy.cfg
    server http${_index} ${_ipv4}:80 maxconn 32 check
EOF
done

cat >>/etc/haproxy/haproxy.cfg <<EOF

frontend https-in
    bind ${_bind_ip}:443
    default_backend https

backend https
    balance roundrobin
    option httpchk
    option forwardfor
    option http-server-close
EOF
_index=0
for _ipv4 in $(jq -r '.[] | select(.name | test("node-")) | .ipv4[]' ${SETUP_DIR}/vm-list.json); do
    ((_index += 1))
    cat <<EOF >>/etc/haproxy/haproxy.cfg
    server https${_index} ${_ipv4}:443 maxconn 32 check
EOF
done

write_info "Starting HAProxy"
systemctl start haproxy || fail "Failed to start HAProxy."
