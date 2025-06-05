FROM python:3.13.4-slim-bookworm

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
