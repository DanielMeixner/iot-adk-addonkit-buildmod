@echo off
powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"%~dp0LaunchTool.cmd\"' -Verb runAs"
