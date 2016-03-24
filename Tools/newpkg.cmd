:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new product
:: usage : newpkg <pkgtype> <comp name> <sub-comp name>
@echo off
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if /I NOT [%1] == [pkgAppx] ( if /I NOT [%1] == [pkgDrv] (if /I NOT [%1] == [pkgFile] goto Usage ))
if [%2] == [] goto Usage
if [%3] == [] goto Usage

if NOT DEFINED SRC_DIR (
	echo Environment not defined. Call setenv
	goto End
)
:: Error Checks

if /i EXIST %SRC_DIR%\Packages\%2.%3 (
	echo Error : %2.%3 already exists; 
	goto End
)
:: Start processing command
echo Creating %2.%3 package
SET PKGSRC_DIR=%SRC_DIR%\Packages\%2.%3

mkdir "%PKGSRC_DIR%"

if [%1] ==[pkgAppx] (
mkdir "%PKGSRC_DIR%\AppInstall"
copy "%IOTADK_ROOT%\Templates\AppInstall\*.cmd" "%PKGSRC_DIR%\AppInstall"
powershell -Command "(gc %IOTADK_ROOT%\Templates\AppxTemplate.pkg.xml) -replace 'COMPNAME', '%2' -replace 'SUBNAME', '%3' -replace 'PLFNAME', '%BSP_ARCH%' | Out-File %PKGSRC_DIR%\%2.%3.pkg.xml -Encoding utf8"
)
if [%1] ==[pkgDrv] (
powershell -Command "(gc %IOTADK_ROOT%\Templates\DrvTemplate.pkg.xml) -replace 'COMPNAME', '%2' -replace 'SUBNAME', '%3' -replace 'PLFNAME', '%BSP_ARCH%' | Out-File %PKGSRC_DIR%\%2.%3.pkg.xml -Encoding utf8"
)
if [%1] ==[pkgFile] (
powershell -Command "(gc %IOTADK_ROOT%\Templates\FileTemplate.pkg.xml) -replace 'COMPNAME', '%2' -replace 'SUBNAME', '%3' -replace 'PLFNAME', '%BSP_ARCH%' | Out-File %PKGSRC_DIR%\%2.%3.pkg.xml -Encoding utf8"
)

echo %PKGSRC_DIR% ready
goto End

:Usage
echo Usage: newpkg pkgtype comp-name sub-comp-name 
echo    pkgtype......... Required, Type of the package created (pkgAppx/pkgDrv/pkgFile)
echo    comp-name....... Required, Component Name for the package
echo    sub-comp-name... Required, Sub-Component Name for the package 
echo    [/?].............. Displays this usage string. 
echo    Example:
echo        newpkg pkgAppx Appx Blinky
echo        newpkg pkgDrv Drivers SDIO 
echo Existing packages are
dir /b /AD %SRC_DIR%\Packages

exit /b 1

:Error
echo "newpkg %1 %2 %3 " failed with error %ERRORLEVEL%
exit /b 1

:End
exit /b 0
