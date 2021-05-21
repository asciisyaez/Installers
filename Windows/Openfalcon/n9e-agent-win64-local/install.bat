@echo off
SETLOCAL ENABLEEXTENSIONS
SETLOCAL DISABLEDELAYEDEXPANSION

:check_Permissions
    echo Administrative permissions required. Detecting permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
    ) else (
        echo Failure: Current permissions inadequate, please run as administrator.
        goto endofbatch
    )
cd /d "%~dp0"
echo Stop and remove existing n9e-agent service if applicable..
echo -------Removing, you may ignore the errors------
nssm stop n9e-agent
nssm remove n9e-agent confirm
echo -------Done------
echo -------Starting installation----
set endpointName=%2
echo %~dp0
if "%endpointName%"=="" (
set /p endpointName=The endpoint name, it will be shown on n9e[Computer Name of this machine if leave blank ]:
)

if "%endpointName%"=="" (
call BatchSubstitute.bat "ENDPOINT_NAME" %COMPUTERNAME% etc\win-collector.yml.tpl > etc\win-collector.yml
) else (
call BatchSubstitute.bat "ENDPOINT_NAME" %endpointName% etc\win-collector.yml.tpl > etc\win-collector.yml
)

nssm install n9e-agent "%~dp0win-collector.exe"
nssm start n9e-agent

:endofbatch
timeout 60