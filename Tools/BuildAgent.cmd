@echo off

call %~dp0\LaunchTool.cmd arm

echo.
echo.Build Start Time : %TIME%
echo.
echo.Building arm packages
call buildpkg all
REM echo.Building arm products
REM call buildimage all
echo.
call setenv x86
echo.Building x86 packages
call buildpkg all
REM echo.Building x86 products
REM call buildimage all
echo.
call setenv x64
echo.Building x64 packages
call buildpkg all
REM echo.Building x64 products
REM call buildimage all
echo.
echo.Build End Time : %TIME%
echo.All Builds done