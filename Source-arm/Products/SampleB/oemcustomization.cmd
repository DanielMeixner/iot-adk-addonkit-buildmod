REM OEM Customization Script file

REM Enable Administrator User
net user Administrator p@ssw0rd /active:yes

REM Applying Provisioning packages in order
provtool C:\OEMInstall\Provisioning\ProvSetA.ppkg
provtool C:\OEMInstall\Provisioning\ProvSetB.ppkg

REM Enable Application Installation
call C:\Appinstall\AppInstall.bat

REM Cleanup Application Installation Files
cd \
rmdir /S /Q C:\AppInstall

REM Cleaning up Provisioning folder
rmdir /S /Q C:\OEMInstall