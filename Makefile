.PHONY: all vm k8s ping destroy

default: all

all: vm k8s

vm:
	cd terraform && terraform init -upgrade && terraform apply -auto-approve

k8s:
	cd ansible && ansible-playbook -i inventory/hosts.yml site.yml

ping:
	cd ansible && ansible -i inventory/hosts.yml all -m ping

destroy:
	cd terraform && terraform destroy -auto-approve
