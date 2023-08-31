#! /bin/bash

# If EUID == 0, this is running to install prerequistes.
# Otherwise, this script will do a user install of Ansible

if (( $EUID == 0 )); then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y vim colordiff git
  if [ -z "$(getent passwd 1000)" ]; then
    useradd -u 1000 -m -U ansible

    mkdir /home/ansible/.ssh /home/ansible/data
    chown ansible:ansible /home/ansible/.ssh
    chmod 700 /home/ansible/.ssh

    cat > /docker-entrypoint.sh << EOF
#!/bin/bash

git config --global --add safe.directory /home/ansible/data

DIR=/docker-entrypoint.d

if [[ -d "\$DIR" ]]; then
  /bin/run-parts "\$DIR"
fi

if [[ ! -z "\$@" ]]; then
  eval "\$*"
else
  /bin/bash
fi
EOF

    chmod 755 /docker-entrypoint.sh

    mkdir /docker-entrypoint.d

    cat > /docker-entrypoint.d/00_ssh_keys_import << EOF
#! /bin/bash

cp -r /ssh/* ~/.ssh
chmod 600 ~/.ssh/*
EOF

    chmod 755 /docker-entrypoint.d/00_ssh_keys_import
    cat /docker-entrypoint.sh
    dir /docker-entrypoint.d/
    cat /docker-entrypoint.d/00_ssh_keys_import
  fi
else
  pip install ansible==${ANSIBLE_VERSION} \
              ansible-lint \
              paramiko \
              docker \
              molecule[lint,docker] \
              toml \
              proxmoxer \
              pywinrm \
              pywinrm[credssp] \
              passlib

  rm -Rf ~/.cache
fi
