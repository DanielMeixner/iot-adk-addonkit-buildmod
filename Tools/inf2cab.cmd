:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new package
@echo off

goto START

:Usage
echo Usage: inf2cab filename.inf [CompName.SubCompName]
echo    filename.inf............ Required, input .inf file
echo    CompName.SubCompName.... Optional, default is Drivers.filename 
echo    [/?].................... Displays this usage string. 
echo    Example:
echo        inf2cab C:\test\testdriver.inf
exit /b 1

:START

if NOT DEFINED SRC_DIR (
	echo Environment not defined. Call setenv
	exit /b -1
)

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

set FILE_NAME=%~n1
set FILE_PATH=%~dp1
if [%2] == [] (
	set COMP_NAME=Drivers
	set SUB_NAME=%FILE_NAME%
) else (
	for /f "tokens=1,2 delims=." %%i in ("%2") do ( 
		set COMP_NAME=%%i
		set SUB_NAME=%%j
	)
)

call inf2pkg.cmd %1 %COMP_NAME%.%SUB_NAME%

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

