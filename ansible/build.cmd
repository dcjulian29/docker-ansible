@echo off
setlocal
set VERSION=4.1.0

docker build --pull --no-cache --progress plain -t dcjulian29/ansible:%VERSION% .
docker tag dcjulian29/ansible:%VERSION% dcjulian29/ansible:latest
docker push dcjulian29/ansible --all-tags
