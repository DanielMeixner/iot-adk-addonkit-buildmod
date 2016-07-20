@echo off
powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"%~dp0\Tools\BuildAgent.cmd\"' -Verb runAs"
