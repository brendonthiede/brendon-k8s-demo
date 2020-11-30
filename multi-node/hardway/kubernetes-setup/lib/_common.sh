export TMP_DIR=/vagrant/tmp
export KUBERNETES_VERSION=v1.18.12
export instance=$(hostname -s)
export INTERNAL_IP="$(hostname -I | awk '{print $2}')"
export VAGRANT_NICS="$(hostname -I | sed 's/ $//; s/ /,/g'),127.0.0.1"
export KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
export KUBERNETES_PUBLIC_ADDRESS=10.0.0.10
export POD_CIDR=10.244.0.0/16

write_info() {
    echo >&2 -e "\e[32m[INFO]\e[0m $(date '+%Y-%m-%d %H:%M:%S') ${1}"
}

write_error() {
    echo >&2 -e "\e[31m[ERROR]\e[0m $(date '+%Y-%m-%d %H:%M:%S') ${1}"
}

fail() {
    [[ -n "${1}" ]] && write_error "${1}"
    popd >/dev/null 2>&1
    exit 1
}

assert_file_exists() {
    for _file in $@; do
        [[ -f "${_file}" ]] || fail "File ${_file} does not exist"
    done
}
