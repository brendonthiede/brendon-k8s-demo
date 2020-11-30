#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/_common.sh"

write_info "Installing HAProxy"
apt-get -qq update >/dev/null
apt-get -qq install haproxy >/dev/null

# Configure haproxy
cat >/etc/default/haproxy <<EOF
ENABLED=1
EOF

cat >/etc/haproxy/haproxy.cfg <<EOF
global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

listen admin
    bind *:8080
    stats enable

frontend http-in
    bind *:80
    default_backend http

backend http
    balance roundrobin
    option httpchk
    option forwardfor
    option http-server-close
    server http1 10.0.0.11:80 maxconn 32 check
    server http2 10.0.0.12:80 maxconn 32 check

frontend https-in
    bind *:443
    default_backend https

backend https
    balance roundrobin
    option httpchk
    option forwardfor
    option http-server-close
    server https1 10.0.0.11:443 maxconn 32 check
    server https2 10.0.0.12:443 maxconn 32 check
EOF

write_info "Starting HAProxy"
systemctl start haproxy
