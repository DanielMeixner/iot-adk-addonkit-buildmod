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

setlocal
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

if NOT DEFINED PKGBLD_DIR (
	echo Environment not defined. Call setenv
	goto End
)

if NOT DEFINED PRODUCT (
	echo PRODUCT set to default:SampleA
	set PRODUCT=SampleA
)

echo Creating %1 Package with version %PKG_VER%
echo.
call pkggen.exe "%1" /config:"%PKG_CONFIG_XML%" /output:"%PKGBLD_DIR%" /version:%PKG_VER% /build:fre /cpu:%BSP_ARCH% /variables:"HIVE_ROOT=%HIVE_ROOT%;WIM_ROOT=%WIM_ROOT%;_RELEASEDIR=%BLD_DIR%\;PROD=%PRODUCT%;PRJDIR=%SRC_DIR%;COMDIR=%COMMON_DIR%;BSPVER=%PKG_VER%;OEMNAME=%OEM_NAME%" 

if errorlevel 1 goto Error

REM remove unused .spkg files
del %PKGBLD_DIR%\*.spkg

echo Package creation completed
goto End


:Error
endlocal
echo "createpkg %1" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0