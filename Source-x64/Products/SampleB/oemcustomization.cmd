@echo off
REM OEM Customization Script file
REM This script if included in the image, is called everytime the system boots.

REM Enable Administrator User
net user Administrator p@ssw0rd /active:yes

if exist C:\OEMTools\InstallAppx.cmd (
    REM Run the Appx Installer. This will install the appx present in C:\OEMApps\
    call C:\OEMTools\InstallAppx.cmd
)


