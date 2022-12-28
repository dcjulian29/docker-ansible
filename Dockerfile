FROM python:slim-bullseye

ARG ANSIBLE_VERSION

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y vim colordiff git \
  && useradd -u 1000 -m -U ansible \
  && mkdir /home/ansible/.ssh \
  && chown ansible:ansible /home/ansible/.ssh \
  && chmod 700 /home/ansible/.ssh \
  && echo '#!/bin/bash\n\nDIR=/docker-entrypoint.d\nif [[ -d "$DIR" ]]; then\n  /bin/run-parts "$DIR"\nfi\n\n[[ ! -z "$@" ]] && exec "$@" || /bin/bash' > /docker-entrypoint.sh \
  && chmod 755 /docker-entrypoint.sh \
  && mkdir /docker-entrypoint.d \
  && echo '#! /bin/bash\n\ncp -r /ssh/* ~/.ssh\nchmod 600 ~/.ssh/*\n' > /docker-entrypoint.d/00_ssh_keys_import \
  && chmod 755 /docker-entrypoint.d/00_ssh_keys_import

USER ansible:ansible

ENV PATH="/home/ansible/.local/bin:$PATH" \
    ANSIBLE_CONFIG="/home/ansible/data/ansible.cfg" \
    ANSIBLE_VERSION=${ANSIBLE_VERSION}

RUN pip install ansible==${ANSIBLE_VERSION} ansible-lint paramiko docker molecule \
      toml proxmoxer pywinrm pywinrm[credssp] \
  &&  ansible-galaxy collection install community.docker community.digitalocean \
      community.general \
  && rm -Rf /home/ansible/.cache

VOLUME [ "/home/ansible/data", "/ssh" ]

WORKDIR /home/ansible/data

ENTRYPOINT [ "/docker-entrypoint.sh" ]
