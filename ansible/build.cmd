@echo off
setlocal
set ANSIBLE_VERSION=5.2.0

pushd %~dp0

docker build --build-arg ANSIBLE_VERSION=%ANSIBLE_VERSION% --progress plain ^
  -t dcjulian29/ansible:%ANSIBLE_VERSION% .

popd

docker tag dcjulian29/ansible:%ANSIBLE_VERSION% dcjulian29/ansible:latest

if "%1" == "" GOTO :EOF

echo --------------------------------------------------------------------------

docker push dcjulian29/ansible --all-tags
