FROM python:slim-bookworm

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
