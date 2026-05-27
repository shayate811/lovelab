variable "proxmox_endpoint" { type = string }
variable "proxmox_username" { type = string }
variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "proxmox_host_ip" {
  description = "Proxmox ホストの IP（テンプレート作成用 SSH 接続先）"
  type        = string
}

variable "proxmox_ssh_key" {
  description = "Proxmox ホストへの SSH 秘密鍵パス"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ssh_public_key" { type = string }

variable "nodes" {
  type = map(object({
    vm_id = number
    ip    = string
    role  = string
  }))
  default = {
    node-01 = { vm_id = 101, ip = "192.168.1.101", role = "control_plane" }
    node-02 = { vm_id = 102, ip = "192.168.1.102", role = "worker" }
    node-03 = { vm_id = 103, ip = "192.168.1.103", role = "worker" }
  }
}

variable "gateway"     { default = "192.168.1.1" }
variable "nameserver"  { default = "1.1.1.1" }
variable "storage"     { default = "local-lvm" }
variable "template_id" { default = 9000 }
