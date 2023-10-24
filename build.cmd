@echo off
setlocal

pushd %~dp0

for /f "delims=" %%x in (version) do set ANSIBLE_VERSION=%%x

docker build --no-cache --build-arg ANSIBLE_VERSION=%ANSIBLE_VERSION% ^
  --pull --progress plain -t dcjulian29/ansible:%ANSIBLE_VERSION% .

if %errorlevel% neq 0 goto FIN

docker tag dcjulian29/ansible:%ANSIBLE_VERSION% dcjulian29/ansible:latest

echo.

goreleaser release --skip-validate --skip-publish --clean

:FIN

popd

endlocal
