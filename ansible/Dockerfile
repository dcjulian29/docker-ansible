FROM python:slim-bullseye

ARG ANSIBLE_VERSION

ENV ANSIBLE_VERSION=${ANSIBLE_VERSION}
ENV VIRTUAL_ENV=/opt/ansible

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN mkdir /etc/ansible /root/.ssh \
  && python -m venv $VIRTUAL_ENV --system-site-packages \
  && pip install cffi PyYAML packaging jinja2 cryptography
  
  #pyparsing, MarkupSafe, resolvelib, 

RUN pip install ansible==${ANSIBLE_VERSION}

RUN pip install ansible-lint[yamllint] paramiko docker molecule toml

RUN pip install pywinrm pywinrm[credssp]

VOLUME [ "/etc/ansible" ]
VOLUME [ "/root/.ssh" ]

WORKDIR /etc/ansible

ENTRYPOINT [ "/bin/bash" ]
