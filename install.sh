#! /bin/bash

# If EUID == 0, this is running to install prerequistes.
# Otherwise, this script will do a user install of Ansible

if (( $EUID == 0 )); then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y vim colordiff git
  useradd -u 1000 -m -U ansible
  mkdir /home/ansible/.ssh
  chown ansible:ansible /home/ansible/.ssh
  chmod 700 /home/ansible/.ssh
  echo '#!/bin/bash\n\nDIR=/docker-entrypoint.d\nif [[ -d "$DIR" ]]; then\n  /bin/run-parts "$DIR"\nfi\n\nif [[ ! -z "$@" ]]; then\n  eval "$*"\nelse\n  /bin/bash\nfi\n' > /docker-entrypoint.sh
  chmod 755 /docker-entrypoint.sh
  mkdir /docker-entrypoint.d
  echo '#! /bin/bash\n\ncp -r /ssh/* ~/.ssh\nchmod 600 ~/.ssh/*\n' > /docker-entrypoint.d/00_ssh_keys_import
  chmod 755 /docker-entrypoint.d/00_ssh_keys_import
else
  pip install ansible==${ANSIBLE_VERSION} \
                  ansible-lint \
                  paramiko \
                  docker \
                  molecule[lint,docker] \
                  toml \
                  proxmoxer \
                  pywinrm \
                  pywinrm[credssp]
  ansible-galaxy collection install ansible.posix \
                                    community.docker \
                                    community.digitalocean \
                                    community.general
  rm -Rf ~/.cache
fi
