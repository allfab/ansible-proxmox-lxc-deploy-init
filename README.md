<h1 align="center">
  <br>
  <a href="https://perfecthomelab.allfabox.fr/"><img src="https://github.com/allfab/docker-homeassistant-assist-stack/assets/1840185/a83bea0c-37be-4520-af3a-33a71da2deb2" alt="Perfect Homelab" width="200px"></a>
  <br>
  Infrastructure As Code
  <br>
  Ansible
  <br>
</h1>

<h4 align="center">Ce référentiel contient le code utilisé pour déployer et initialiser un conteneur LXC sur Proxmox.</h4>

<p align="center">
  <a href="https://perfecthomelab.allfabox.fr/" target="_blank"><img src="https://img.shields.io/badge/Perfect_Homelab-526CFE?style=for-the-badge&logo=MaterialForMkDocs&logoColor=white" /></a>
  <a href="https://www.ansible.com/" target="_blank"><img src="https://img.shields.io/badge/ansible-000000?style=for-the-badge&logo=ansible&logoColor=white" /></a>
</p>

<p align="center">
  <a href="#pourquoi-ce-dépôt-">Pourquoi ce dépôt ?</a> •
  <a href="#pré-requis">Pré-requis</a> •
  <a href="#variables-ansible">Variables Ansible</a> •
  <a href="#instructions-de-déploiement">Instructions de déploiement</a> •
  <a href="#coffre-fort-ansible">Coffre-fort Ansible</a> •
  <a href="#crédits">Crédits</a> •
  <a href="#license">License</a>
</p>

# Pourquoi ce dépôt ?

Ce dépôt contient une fraction du code que j'utilise pour déployer et gérer les conteneurs LXC de mon homelab qui tourne sous Proxmox.

J'utilise Ansible pour exécuter mon infrastructure et ce dépôt est ma contribution au mouvement `Infrastructure as Code`.


 # Pré-requis

 - Python 3,
 - Ansible,
 - [`just`](https://github.com/casey/just) :
    - Installation : `curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin`


# Variables Ansible

Les variables `secrètes` sont répertoriées ci-dessous dans le fichier `vars/vault.yml` :
```yaml
# vars/vault.yml
---
secret:
  ssh:
    port: "22"

  user:
    me:
      name: "myuser"
      password: "myuserpassword"
      uid: 1000
      gid: 1000
      group: "myuser"
      groups: "sudo"
      create_home: true
      home: "/home/myuser"
      system: false
      comment: "My Comment"
      ssh:
        pubkey: "my ssh pubkey"
    pve:
      ssh:
        user: "root"
        pam: "root@pam"
        password: "my_proxmox_root_password"
    lxc:
      ssh:
        user: "root"
        password: "my_container_root_password"
    
  proxmox:
    pve:
      api:
        node: "my_node"
        host: 192.168.100.100
        user: "root@pam"
        password: "my_proxmox_root_password%"
        token_id: "my_proxmox_token_id_user"
        token_secret: "my_proxmox_token_secret"

  github:
    api:
      user: my_github_user
      token: "my_github_token"
      token_name: "my_github_token_name"
      auth: yes
```

Elles sont surchargées dans les fichiers de variables de rôle `roles/deployment/defaults/main.yml` et `roles/setup/defaults/main.yml` :

```yaml
# roles/deployment/defaults/main.yml
---
ssh:
  port: "{{ secret.ssh.port }}"

user:
  me:
    name: "{{ secret.user.me.name }}"
    password: "{{ secret.user.me.password }}"
    uid: "{{ secret.user.me.uid }}"
    gid: "{{ secret.user.me.gid }}"
    group: "{{ secret.user.me.group }}"
    groups: "{{ secret.user.me.groups }}"
    create_home: true
    home: "{{ secret.user.me.home }}"
    system: false
    comment: "{{ secret.user.me.comment }}"
    ssh:
      pubkey: "{{ secret.user.me.ssh.pubkey }}"
  pve:
    ssh:
      user: "{{ secret.user.pve.ssh.user }}"
      pam: "{{ secret.user.pve.ssh.pam }}"
      password: "{{ secret.user.pve.ssh.password }}"
  lxc:
    ssh:
      user: "{{ secret.user.lxc.ssh.user }}"
      password: "{{ secret.user.lxc.ssh.user }}"
  
proxmox:
  pve:
    api:
      node: "{{ secret.proxmox.pve.api.node }}"
      host: "{{ secret.proxmox.pve.api.host }}"
      user: "{{ secret.proxmox.pve.api.user }}"
      password: "{{ secret.proxmox.pve.api.password }}"
      token_id: "{{ secret.proxmox.pve.api.token_id }}"
      token_secret: "{{ secret.proxmox.pve.api.token_secret }}"
  lxc:
    name: myctlxc
    vmid: 199
    cores: 2
    cpus: "1"
    cpuunits: "1000"
    disk: "local-zfs:8"       # pve-storage-name:size-of-volume(GO)
    nesting: 1
    keyctl: 0
    fuse: 0
    memory: 1024
    nameserver: 192.168.0.253
    ip: 192.168.10.99
    gw: 192.168.10.1
    unprivileged: false       # true | false
    onboot: true
    startup: "order=99"
    ostemplate: "iso:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
    password: "{{ secret.user.lxc.ssh.password }}"
    pubkey: "{{ secret.user.me.ssh.pubkey }}"
    storage: "local-zfs"
    storage_template: "iso"
    swap: "512"
    tags:
      - myctlxc
      - prod
    timezone: "{{ timezone }}"
    description: |
      <div align="center"><a href="https://perfecthomelab.allfabox.fr/" target="_blank" rel="noopener noreferrer"><img src="https://raw.githubusercontent.com/allfab/perfect-homelab/main/docs/assets/images/overview/logo-perfect-homelab-proxmox-thumbnail.png"/></a>

      # My LXC Container

      <a href="https://perfecthomelab.allfabox.fr/" target="_blank"><img src="https://img.shields.io/badge/Perfect_Homelab-526CFE?style=for-the-badge&logo=MaterialForMkDocs&logoColor=white" /></a><br />
      </div>
```

```yaml
# roles/setup/defaults/main.yml
---
locales:
    - "fr_FR.UTF-8"
    
# MOTD
figurine:  
  install_login_script: true
  font: "3d.flf"
  arch: amd64
```

# Instructions de déploiement

- `just init-infra` :
    - Installation de la libraire [`just`](https://github.com/casey/just),
    - Installation des rôles Ansible requis (requirements.yml),
    - Installation des collections Ansible requises (requirements.yml),
    - Installation d'un hook github pour éviter de partager sur le dépôt un fichier de coffre-fort non crypté [(en savoir +)](https://github.com/allfab/infrastructure/tree/main?tab=readme-ov-file#ma-gestion-des-secrets).

- `just myctlxc-deployment` :
    - Exécute la commande `aansible-playbook -i hosts.ini run.yml --limit myctlxc --tags deployment`
    - Ce playbook déploit un conteneur LXC sur un noeud Proxmox Virtual Environment :
        - `proxmox-lxc-deploy-init/deployment` : Déploiement du conteneur LXC avec l'ensemble des options spécifiées dans le fichier `defaults/main.yml`,
        - `proxmox-lxc-deploy-init/setup` : Installe et configure les différents logiciels et outils dont je me sers sur mes conteneur LXC pour leur administration.


# Coffre-fort Ansible

## Raccourcis

- `just encrypt` - Chiffre le coffre-fort Ansible :
  - Exécute la commande `ansible-vault encrypt --vault-password-file bw-vault.sh ./vars/vault.yml;`
- `just decrypt` - Décrypte le coffre-fort Ansible :
  - Exécute la commande `ansible-vault decrypt --vault-password-file bw-vault.sh ./vars/vault.yml;`

## PRÉREQUIS : `ansible-vault` - Chiffrement des fichiers vault.yml

### Qu'est-ce qu'Ansible Vault ?

Ansible `Vault` (coffre-fort en français) est une fonctionnalité d'Ansible qui nous permet de conserver des données sensibles telles que des mots de passe, des clés SSH, de certificats SSL, des jetons d'API et tout ce que vous ne voulez pas que le public découvre en parcourant votre dépôt Github, plutôt que de les stocker sous un format brut dans des playbooks ou des rôles.

Il est courant de stocker de telles configurations dans un contrôleur de version tel que git. Nous avons donc besoin d'un moyen de stocker ces données secrètes en toute sécurité.

Le `Vault` est la réponse à notre besoin, puisqu'il permet de chiffrer n'importe quoi à l'intérieur de nos fichiers YAML. Ces données de Vault peuvent ensuite être distribuées ou placées dans le contrôle de code source tel que `git`.

[**➕ En savoir + sur les principales commandes `ansible-vault`**](docs/ansible/ansible-vault.md)


### Ma gestion des secrets

Dans ce projet, j'ai combiné l'utilisation de plusieurs outils pour ma gestion des secrets :
- [`Ansible Vault`](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html),
- [`Bitwarden command-line interface (CLI)`](https://bitwarden.com/help/cli/), qui est l'outil en ligne de commande de [`Bitwarden`](https://bitwarden.com/) qui s'intègre très bien avec l'implémentation alternative de l'API du serveur Bitwarden - [`Vaultwarden`](https://github.com/dani-garcia/vaultwarden) - parfaite pour un déploiement auto-hébergé,
- les `hooks GIT` (notamment avec les hooks de `pre-commit`) afin de ne pas commiter mes fichiers `vault.yml` en clair sur ce dépôt,
- le script `ansible-vault-helper.sh` qui va me permettre de crypter et/ou de décryper les fichiers `vault.yml` présents dans le projet.

[**➕ En savoir +**](docs/ansible/ansible-vault-strategy.md)

# Crédits

Ce dépôt n'existerait pas sans le partage des infrastructures d'[IronicBadger/AlexKTZ](https://github.com/ironicbadger/infra) et de [FuzzyMistborn](https://github.com/FuzzyMistborn/infra). J'ai beaucoup appris en fouillant dans ces dépôts et certaines choses sont copiées directement à partir de ces sources et je les en remercie pour le partage de leur savoir-faire et expérimentation.

Pour finir, un clin d'oeil à [@GuiPoM](https://www.youtube.com/@GuiPoM) sans qui je n'aurais jamais sauté le pas pour construie mon NAS, notamment grâce à sa playlist [G. installé un NAS](https://www.youtube.com/playlist?list=PLMYMkXlcQmZA2TTeyT13eykkc-aM8kU3t).

# Licence

À définir