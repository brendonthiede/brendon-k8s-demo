export DEBIAN_FRONTEND=noninteractive
export SETUP_DIR="/etc/setup"
export TMP_DIR="${SETUP_DIR}/tmp"
export OS_VERSION=$(lsb_release -cs)
export DOCKER_VERSION="5:19.03.14~3-0~ubuntu-${OS_VERSION}"
export KUBERNETES_VERSION="v1.19.4"
export HOSTNAME="$(hostname -s | sed 's/ //g')"
export POD_CIDR="10.244.0.0/16"
export DEFAULT_USER="ubuntu"

write_info() {
    echo >&2 -e "\e[32m[INFO]\e[0m ${HOSTNAME} $(date '+%Y-%m-%d %H:%M:%S') ${1}"
}

write_error() {
    echo >&2 -e "\e[31m[ERROR]\e[0m ${HOSTNAME} $(date '+%Y-%m-%d %H:%M:%S') ${1}"
}

fail() {
    [[ -n "${1}" ]] && write_error "${1}"
    popd >/dev/null 2>&1
    exit 1
}
