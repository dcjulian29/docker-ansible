FROM alpine:latest

RUN apk update \
    && apk add g++ python3-dev build-base libffi-dev openssl-dev krb5-dev \
    && apk add python3 ca-certificates openssh-client sshpass git cargo \
    && apk add py3-setuptools py3-pip py3-wheel py3-paramiko \
    && rm -rf /var/cache/apk/*

RUN mkdir /etc/ansible \
    && mkdir ~/.ssh \
    && pip install -U pip \
    && pip install -U wheel \
    && pip install -U setuptools-rust \
    && pip install -U cffi \
    && pip install -U cryptography \
    && pip install -U paramiko \
    && pip install -U jinja2 MarkupSafe \
    && pip install -U pyparsing pycparser packaging  \
    && pip install -U pyOpenSSL pyYAML \
    && pip install -U six --ignore-installed \
    && pip install pywinrm pywinrm[kerberos] pywinrm[credssp] \
    && pip install ansible-core ansible==4.0.0 ansible-lint \
    && pip install -U ansible-merge-vars ansible2puml ansible-netbox-inventory \
    && pip install -U argcomplete docker molecule

ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_SSH_PIPELINING true

VOLUME [ "/etc/ansible" ]
VOLUME [ "~/.ssh" ]

WORKDIR /etc/ansible

ENTRYPOINT ["/bin/ash"]
