:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new package
@echo off

goto START

:Usage
echo Usage: inf2cab filename.inf 
echo    filename.inf..... Required, input .inf file; expects filename.sys file in the same location 
echo    [/?]............. Displays this usage string. 
echo    Example:
echo        inf2cab C:\test\testdriver.inf
exit /b 1

:START

if NOT DEFINED SRC_DIR (
	echo Environment not defined. Call setenv
	exit /b -1
)

setlocal

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

set PKG_TYPE=%~x1
set FILE_NAME=%~n1
set FILE_PATH=%~dp1

if [%PKG_TYPE%] ==[.inf] (
	set COMP_NAME=Drivers
	set SUB_NAME=%FILE_NAME%
) else ( goto Usage )


:: Start processing command

echo. Authoring %COMP_NAME%.%SUB_NAME%.pkg.xml
:: Create Driver package using template files
powershell -Command "(gc %IOTADK_ROOT%\Templates\DrvTemplate.pkg.xml) -replace 'COMPNAME', '%COMP_NAME%' -replace 'SUBNAME', '%SUB_NAME%' -replace 'DRIVER_NAME', '%FILE_NAME%' -replace 'PLFNAME', '%BSP_ARCH%' | Out-File %FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml -Encoding utf8"

echo. Processing %COMP_NAME%.%SUB_NAME%.pkg.xml 
set PKGBLD_DIR=%FILE_PATH%\
call createpkg %FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml > %FILE_PATH%%COMP_NAME%.%SUB_NAME%.pkg.log
if not errorlevel 0 ( echo. Error : Failed to create package. See %FILE_PATH%%COMP_NAME%.%SUB_NAME%.pkg.log 
) else (echo. Package created. See %FILE_PATH%%OEM_NAME%.%COMP_NAME%.%SUB_NAME%.cab )

goto End

:Error
endlocal
echo "inf2cab %1 " failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
