REM OEM Customization Script file

REM Enable Administrator User
net user Administrator p@ssw0rd /active:yes

REM Enable Application Installation
REM call C:\Appinstall\AppInstall.cmd

REM Cleanup Application Installation Files. Change dir to root so that the dirs can be deleted
REM cd \
REM rmdir /S /Q C:\AppInstall
