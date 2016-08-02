@echo off
:: This script builds FFUs for all OEMInputSamples under the Addon Kit directory

call %~dp0\LaunchTool.cmd arm

echo.
echo.Build Start Time : %TIME%
echo.
echo.Building arm packages
call buildpkg all
echo.Building arm products
call buildimage all
echo.
call setenv x86
echo.Building x86 packages
call buildpkg all
echo.Building x86 products
call buildimage all
echo.
call setenv x64
echo.Building x64 packages
call buildpkg all
echo.Building x64 products
call buildimage all
echo.
echo.Build End Time : %TIME%
echo.All Builds done