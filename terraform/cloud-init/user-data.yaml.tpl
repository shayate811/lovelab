#cloud-config
hostname: ${hostname}
manage_etc_hosts: true
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
