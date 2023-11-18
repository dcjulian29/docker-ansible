#! /bin/bash
set -ex

pre_req () {
  apt-get update

  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ssh-client
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends vim
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends colordiff
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python3-virtualenv
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gpg
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends less

  curl -fsSL "https://baltocdn.com/helm/signing.asc" | \
    gpg --dearmor -o /usr/share/keyrings/helm.gpg

  echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/helm.gpg] \
    https://baltocdn.com/helm/stable/debian/ all main" \
    | tee /etc/apt/sources.list.d/helm.list > /dev/null

  apt-get update

  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends helm

  rm /etc/apt/sources.list.d/helm.list
  rm /usr/share/keyrings/helm.gpg

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
              netaddr \
              kubernetes

  rm -Rf ~/.cache
}

# If EUID == 0, this is running to install prerequistes.
# Otherwise, this script will do a user install of Ansible
if (( $EUID == 0 )); then
  pre_req
else
  install
fi
