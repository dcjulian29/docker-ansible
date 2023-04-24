@echo off
setlocal

pushd %~dp0

for /f "delims=" %%x in (version) do set ANSIBLE_VERSION=%%x

docker build --build-arg ANSIBLE_VERSION=%ANSIBLE_VERSION% --progress plain ^
  -t dcjulian29/ansible:%ANSIBLE_VERSION% .

if %errorlevel% neq 0 popd;exit /b %errorlevel%

popd

docker tag dcjulian29/ansible:%ANSIBLE_VERSION% dcjulian29/ansible:latest

goreleaser --snapshot --skip-publish --clean
