#!/bin/bash

green=$'\e[0;32m'
red=$'\e[0;31m'
reset=$'\e[0m'

echo "VÉRIFICATION DU SYSTEME D'EXPLOITATION"
os=$(uname)

if [ "$os" == "Linux" ]; then
    echo "Nous sommes bien sur Linux";
fi

echo "INSTALLATION DES PAQUETS PRÉ-REQUIS"
if [[ -f /etc/redhat-release ]]; then
    pkg_manager=dnf
elif [[ -f /etc/debian_version ]]; then
    pkg_manager=apt
fi

if [ $pkg_manager == "dnf" ]; then
    sudo dnf install -y yamllint ansible-lint sshpass
elif [ $pkg_manager == "apt" ]; then
    sudo apt install -y yamllint ansible-lint sshpass
elif [ "$os" == "Darwin" ]; then
  echo "Nous sommes sur un Mac"
else
  echo "OS non supporté"
  exit 1
fi

if (test -f /usr/local/bin/just); then
    echo "${green}La librairie « just » est déjà installée !${reset}"
else
    sudo curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin
fi

echo "INSTALLATION DES RÔLES Ansible"
ansible-galaxy role install -r requirements.yml --force

echo "INSTALLATION DES COLLECTIONS Ansible"
ansible-galaxy collection install -r requirements.yml

echo "INSTALLATION DU HOOK GIT DE PRÉ-COMMIT Ansible Vault"
./git-init.sh