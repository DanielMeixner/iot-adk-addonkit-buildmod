:: OEM Customization Script file

REM Enable Administrator User
net user Administrator p@ssw0rd /active:yes

REM Authoring Headless Configuration
REM call reg add HKEY_LOCAL_MACHINE\SYSTEM\currentcontrolset\control\wininit /v Headless /t REG_DWORD /d 1 /f

REM Configure Crash Dump Settings
REM call reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl /v AutoReboot /t REG_DWORD /d 1 /f
REM call reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl /v CrashDumpEnabled /t REG_DWORD /d 1 /f
REM call reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl /v DedicatedDumpFile /t REG_SZ /d c:\1.sys /f
REM call reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl /v DumpFile /t REG_EXPAND_SZ /d c:\1.dmp /f
REM call reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl /v DumpFileSize /t REG_DWORD /d 600 /f

REM Enable Application Installation
call C:\AppInstall\AppInstall.bat

REM Cleaning up the Application Installation files
rmdir /s /q C:\Appinstall
