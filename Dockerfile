FROM python:slim-bullseye

ARG ANSIBLE_VERSION

ENV ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV PATH="/root/ansible/bin:/root/.local/bin:$PATH"

RUN mkdir /etc/ansible /root/.ssh /root/.azure /root/.aws \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y vim colordiff \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y gcc libkrb5-dev \
  && python -m venv /root/ansible --upgrade --system-site-packages \
  && /root/ansible/bin/python -m pip install --upgrade pip \
  && /root/ansible/bin/pip install cffi PyYAML packaging jinja2 cryptography \
  && /root/ansible/bin/pip install paramiko docker molecule toml \
  && /root/ansible/bin/pip install jmespath requests passlib[bcrypt] \
  && /root/ansible/bin/pip install pywinrm pywinrm[credssp] \
  && /root/ansible/bin/pip install kerberos pywinrm[kerberos] \
  && /root/ansible/bin/pip install ansible==${ANSIBLE_VERSION} \
  && /root/ansible/bin/pip install ansible-lint[yamllint] \
  && rm -Rf /root/.cache

COPY ansible-galaxy.yml /root/ansible/ansible-galaxy.yml

RUN ansible-galaxy collection install -p /root/ansible/lib/python3.*/site-packages/ansible_collections \
    -r /root/ansible/ansible-galaxy.yml \
  && /root/ansible/bin/pip install proxmoxer \
  && /root/ansible/bin/pip install -r /root/ansible/lib/python3.*/site-packages/ansible_collections/azure/azcollection/requirements-azure.txt \
  && /root/ansible/bin/pip install -r /root/ansible/lib/python3.*/site-packages/ansible_collections/amazon/aws/requirements.txt \
  && rm -Rf /root/.cache

VOLUME [ "/etc/ansible" ]
VOLUME [ "/root/.ssh" ]
VOLUME [ "/root/.azure" ]
VOLUME [ "/root/.aws" ]

WORKDIR /etc/ansible

ENTRYPOINT [ "/bin/bash" ]
