@echo off
setlocal

pushd %~dp0

for /f "delims=" %%x in (version) do set ANSIBLE_VERSION=%%x

docker build --progress plain --pull --build-arg ANSIBLE_VERSION=%ANSIBLE_VERSION% -t dcjulian29/ansible:%ANSIBLE_VERSION% .

if %errorlevel% neq 0 goto FIN

echo.

goreleaser release --skip publish,validate --clean

:FIN

popd

endlocal
