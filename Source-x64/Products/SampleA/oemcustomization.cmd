@echo off
REM OEM Customization Script file
REM This script if included in the image, is called everytime the system boots.

if exist C:\OEMTools\InstallAppx.cmd (
    REM Run the Appx Installer. This will install the appx present in C:\OEMApps\
    call C:\OEMTools\InstallAppx.cmd
)
