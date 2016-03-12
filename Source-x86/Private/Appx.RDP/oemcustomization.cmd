REM OEM Customization Script file

REM Enable Administrator User
net user Administrator p@ssw0rd /active:yes

REM Enable Application Installation
call C:\Appinstall\AppInstall.bat

cd \

REM Cleaning up the install directory
rmdir /S /Q C:\Appinstall