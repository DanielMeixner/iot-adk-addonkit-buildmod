@echo off

goto START

:Usage
echo Usage: createpkg packagefile.pkg.xml [version]
echo    packagefile.pkg.xml....... Required, Package definition XML file
echo    [version]................. Optional, Package version. If not specified, it uses BSP_VERSION 
echo    [/?]...................... Displays this usage string. 
echo    Example:
echo        createpkg sample.pkg.xml
echo        createpkg sample.pkg.xml 10.0.1.0

exit /b 1

:START
if not defined PKGBLD_DIR (
	echo Environment not defined. Call setenv
	exit /b 1
)
setlocal
pushd
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] (
	REM Using version info set in BSP_VERSION
	set PKG_VER=%BSP_VERSION%
) else (
	REM Use the version provided in the paramter
	REM TODO validate version format
	set PKG_VER=%2
)

cd %~dp1
if NOT DEFINED PRODUCT (
	set PRODUCT=SampleA
)

echo Creating %~nx1 Package with version %PKG_VER% for %PRODUCT%

call pkggen.exe "%~nx1" /config:"%PKG_CONFIG_XML%" /output:"%PKGBLD_DIR%" /version:%PKG_VER% /build:fre /cpu:%BSP_ARCH% /variables:"HIVE_ROOT=%HIVE_ROOT%;WIM_ROOT=%WIM_ROOT%;_RELEASEDIR=%BLD_DIR%\;PROD=%PRODUCT%;PRJDIR=%SRC_DIR%;COMDIR=%COMMON_DIR%;BSPVER=%PKG_VER%;OEMNAME=%OEM_NAME%"

if errorlevel 0 (
	REM remove unused .spkg files
	del %PKGBLD_DIR%\*.spkg
	echo Package creation completed
	set RETVAL=0
) else (
	echo Package creation failed with error %ERRORLEVEL%
	set RETVAL=1
)
popd
endlocal
exit /b %RETVAL%