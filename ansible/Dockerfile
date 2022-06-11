FROM python:slim-bullseye

ARG ANSIBLE_VERSION

ENV ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV PATH="/root/ansible/bin:/root/.local/bin:$PATH"

#5 ~350MB
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
  && rm -Rf /root/.cache

#6 ~500MB
RUN /root/ansible/bin/pip install ansible==${ANSIBLE_VERSION} \
  && rm -Rf /root/.cache

#7 ~500MB Azure
RUN /root/ansible/bin/pip install ansible-lint[yamllint] \
  && ansible-galaxy collection install azure.azcollection \
  && /root/ansible/bin/pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt \
  && rm -Rf /root/.cache

#8 ~125MB AWS
RUN /root/ansible/bin/pip install awscli \
  && ansible-galaxy collection install amazon.aws \
  && /root/ansible/bin/pip install -r ~/.ansible/collections/ansible_collections/amazon/aws/requirements.txt \
  && rm -Rf /root/.cache

VOLUME [ "/etc/ansible" ]
VOLUME [ "/root/.ssh" ]
VOLUME [ "/root/.azure" ]
VOLUME [ "/root/.aws" ]

#WORKDIR /root/ansible

ENTRYPOINT [ "/bin/bash" ]
