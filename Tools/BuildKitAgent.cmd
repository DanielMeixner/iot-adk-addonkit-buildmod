@echo off

REM This script builds FFUs for all OEMInputSamples in Core Kit package

call %~dp0\LaunchTool.cmd arm

REM call setenv arm
echo Building arm sample FFUs
call BuildKitSamples.cmd Test
call BuildKitSamples.cmd Retail

call setenv x86
echo Building x86 sample FFUs
call BuildKitSamples.cmd Test
call BuildKitSamples.cmd Retail

exit /b 0
