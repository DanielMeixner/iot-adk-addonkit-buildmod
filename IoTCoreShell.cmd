@echo off
set cmdstring="Start-Process 'cmd.exe' -ArgumentList '/k \"%~dp0\Tools\LaunchTool.cmd\" arm & echo hello & c:\iot-adk-addonkit\Tools\appx2pkg.cmd %1 %2' -Verb runAs  "
echo %cmdstring%
powershell -Command %cmdstring%
echo trycopy c:\iot-adk-addonkit\Templates\AppInstall\AppInstall.cmd  %3
copy c:\iot-adk-addonkit\Templates\AppInstall\AppInstall.cmd  %3

REM powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"%~dp0\Tools\LaunchTool.cmd\" arm & echo hello & c:\iot-adk-addonkit\Tools\appx2pkg.cmd c:\agent\mypacker2\AppInstall\BlankUWP_1.0.0.0_ARM_Debug.appx dmx.uwpiotBUILD' -Verb runAs  "

 