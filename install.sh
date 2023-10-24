#! /bin/bash
set -ex

pre_req () {
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y vim colordiff git
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3-pip
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3-virtualenv

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

  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
  apt-get autoremove
  rm -rf /var/lib/apt/lists/*
  apt-get clean
}

install () {
  echo "Installing Ansible version '$ANSIBLE_VERSION'..."

  virtualenv ~/.local/ansible --system-site-packages

  source ~/.local/ansible/bin/activate

  pip install ansible==${ANSIBLE_VERSION} \
              ansible-lint \
              docker \
              molecule \
              toml \
              httpx \
              proxmoxer \
              pywinrm \
              pywinrm[credssp] \
              passlib \
              netaddr

  export PATH="$PATH:~/.local/ansible/bin"

  echo "export PATH=\$PATH:~/.local/ansible/bin" >> ~/.bashrc

  rm -Rf ~/.cache
}

# If EUID == 0, this is running to install prerequistes.
# Otherwise, this script will do a user install of Ansible
if (( $EUID == 0 )); then
  pre_req
else
  install
fi
