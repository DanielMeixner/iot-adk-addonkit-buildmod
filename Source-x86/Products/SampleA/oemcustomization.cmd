REM OEM Customization Script file

REM Enable Administrator User
net user Administrator p@ssw0rd /active:yes

REM Enable Application Installation
call C:\Appinstall\AppInstall.bat

REM Cleanup Application Installation Files
cd \
rmdir /S /Q C:\AppInstall
