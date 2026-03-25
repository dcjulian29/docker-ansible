@echo off
setlocal

pushd %~dp0

for /f "delims=" %%x in (version) do set IMAGE_VERSION=%%x

docker build --progress plain --build-arg ANSIBLE_VERSION=%IMAGE_VERSION% -t dcjulian29/ansible:%IMAGE_VERSION% .

if %errorlevel% neq 0 goto FINAL

docker tag dcjulian29/ansible:%IMAGE_VERSION% dcjulian29/ansible:latest

:FINAL

goreleaser --snapshot --clean

popd

endlocal
