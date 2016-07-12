:: This script builds FFUs for all OEMInputSamples in Core Kit package

@echo off

call %~dp0\LaunchTool.cmd arm

REM call setenv arm
echo Building arm sample FFUs
call BuildKitSamples.cmd

call setenv x86
echo Building x86 sample FFUs
call BuildKitSamples.cmd

call setenv x64
echo Building x64 sample FFUs
call BuildKitSamples.cmd

exit /b 0
