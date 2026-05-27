#!/bin/bash
set -euo pipefail

TEMPLATE_ID=${1:-9000}
STORAGE=${2:-local-lvm}
IMAGE="noble-server-cloudimg-amd64.img"
IMAGE_URL="https://cloud-images.ubuntu.com/noble/current/${IMAGE}"

# 冪等チェック：テンプレートが既存なら終了
if qm status "${TEMPLATE_ID}" &>/dev/null; then
  echo "Template ${TEMPLATE_ID} already exists. Skipping."
  exit 0
fi

echo "Creating Ubuntu 24.04 template (VM ID: ${TEMPLATE_ID})..."

wget -q "${IMAGE_URL}" -O "/tmp/${IMAGE}"

qm create "${TEMPLATE_ID}" \
  --name ubuntu-2404-template \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-pci \
  --ostype l26

qm importdisk "${TEMPLATE_ID}" "/tmp/${IMAGE}" "${STORAGE}"
qm set "${TEMPLATE_ID}" \
  --scsi0 "${STORAGE}:vm-${TEMPLATE_ID}-disk-0,cache=writeback,discard=on"

qm set "${TEMPLATE_ID}" --ide2 "${STORAGE}:cloudinit"
qm set "${TEMPLATE_ID}" --boot order=scsi0
qm set "${TEMPLATE_ID}" --serial0 socket --vga serial0
qm set "${TEMPLATE_ID}" --agent enabled=1

qm template "${TEMPLATE_ID}"

rm -f "/tmp/${IMAGE}"

echo "Template ${TEMPLATE_ID} created successfully."
