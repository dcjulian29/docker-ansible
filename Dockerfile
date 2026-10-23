# Held at Python 3.14: ansible-core 2.21 patches dataclasses._is_type at
# startup, and Python 3.15 removed it, so every Ansible tool fails on 3.15.
# Dependabot ignores 3.15 until an ansible-core release supports it.
FROM python:3.14.8-slim-bookworm

LABEL org.opencontainers.image.source="https://github.com/dcjulian29/docker-ansible"
LABEL org.opencontainers.image.description="A Docker Container and execution tool for Ansible"

ARG ANSIBLE_VERSION

COPY install.sh /install.sh

RUN bash /install.sh

USER ansible:ansible

ENV PATH="/home/ansible/.local/bin:$PATH" \
    ANSIBLE_CONFIG="/home/ansible/data/ansible.cfg" \
    ANSIBLE_VERSION=${ANSIBLE_VERSION}

RUN bash /install.sh

VOLUME [ "/home/ansible/data", "/ssh" ]

WORKDIR /home/ansible/data

ENTRYPOINT [ "/docker-entrypoint.sh" ]
