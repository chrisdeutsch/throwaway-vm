#!/usr/bin/env bash
VM_NAME="throwaway-vm"
OS_VARIANT="ubuntu22.04"
CLOUD_IMAGE="/var/lib/libvirt/images/jammy-server-cloudimg-amd64.img"
DISK_SIZE_GB=10

DIR=$(dirname -- "$0")
USER_DATA="$(readlink -e "${DIR}/user.yaml")"
if [ ! -f "${USER_DATA}" ]; then
    exit 1;
fi

function print_usage {
    echo "usage: throwaway-vm.sh (start|stop)" >&2
}

function start {
    virt-install \
        --name "${VM_NAME}" \
        --vcpus 2 \
        --memory 2048 \
        --os-variant "${OS_VARIANT}" \
        --network bridge=virbr0 \
        --nographics \
        --disk size="${DISK_SIZE_GB},backing_store=${CLOUD_IMAGE}" \
        --cloud-init user-data="${USER_DATA}" \
        --noautoconsole
}

function stop {
    virsh destroy "${VM_NAME}"
    virsh undefine --remove-all-storage "${VM_NAME}"
}

if (( $# != 1 )); then
    print_usage
    exit 1
fi

case "$1" in
    start)
        start;;
    stop)
        stop;;
    *)
        print_usage
        exit 1;;
esac
