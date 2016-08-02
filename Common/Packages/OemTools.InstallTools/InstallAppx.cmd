@echo off
REM This script installs the OEM Apps present in the C:\OEMApps folder.
pushd

if exist C:\OEMApps (
    cd C:\OEMApps
    dir C:\OEMApps /AD /B > C:\OEMApps\applist.txt
    for /f "delims=" %%i in (C:\OEMApps\applist.txt) do (
      if exist C:\OEMApps\%%i\AppxConfig.cmd (
        echo. Processing C:\OEMApps\%%i
        call C:\OemTools\AppxInstaller.cmd  C:\OEMApps\%%i > %temp%\%%i_AppxInstallerLog.txt
      )
    )
    cd \
    rmdir /S /Q C:\OEMApps
)
popd

