# Recettes
@default:
  just --list

init-infra:
  @./init-infra.sh

myctlxc-deployment:
  ansible-playbook -i hosts.ini run.yml --limit myctlxc --tags deployment

myctlxc-setup:
  ansible-playbook -i hosts.ini run.yml --user allfab --private-key ~/.ssh/allfab --limit myctlxc --tags setup

# Ansible Vault Encrypt
encrypt:
  @if (grep --quiet "vault_password_file" ansible.cfg); then ansible-vault encrypt ./vars/vault.yml; else ansible-vault encrypt --vault-password-file bw-vault.sh ./vars/vault.yml; fi

# Ansible Vault Decrypt
decrypt:
  @if (grep --quiet "vault_password_file" ansible.cfg); then ansible-vault decrypt ./vars/vault.yml; else ansible-vault decrypt --vault-password-file bw-vault.sh ./vars/vault.yml; fi

yamllint:
  yamllint -s .

ansible-lint: yamllint
  #!/usr/bin/env bash
  ansible-lint .
  ansible-playbook run.yml --syntax-check
