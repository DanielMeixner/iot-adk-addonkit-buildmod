@echo off

goto START

:Usage
echo Usage: createpkg [CompName.SubCompName]/[packagefile.pkg.xml] [version]
echo    packagefile.pkg.xml....... Package definition XML file
echo    CompName.SubCompName...... Package ComponentName.SubComponent Name
echo        Either one of the above should be specified
echo    [version]................. Optional, Package version. If not specified, it uses BSP_VERSION 
echo    [/?]...................... Displays this usage string. 
echo    Example:
echo        createpkg sample.pkg.xml
echo        createpkg sample.pkg.xml 10.0.1.0
echo        createpkg Appx.Main

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

if [%~x1] == [.xml] (
    set INPUT_FILE=%~nx1
    cd %~dp1
) else (
    set INPUT_FILE=%1.pkg.xml
    if exist "%SRC_DIR%\Packages\%1\%1.pkg.xml" (
        cd "%SRC_DIR%\Packages\%1"
    ) else if exist "%COMMON_DIR%\Packages\%1\%1.pkg.xml" (
        cd "%COMMON_DIR%\Packages\%1"        
    ) else (
        echo Error : %1.pkg.xml package not found
        goto Usage
    )
)

if not defined PRODUCT (
	set PRODUCT=SampleA
)

echo Creating %INPUT_FILE% Package with version %PKG_VER% for %PRODUCT%

call pkggen.exe "%INPUT_FILE%" /config:"%PKG_CONFIG_XML%" /output:"%PKGBLD_DIR%" /version:%PKG_VER% /build:fre /cpu:%BSP_ARCH% /variables:"HIVE_ROOT=%HIVE_ROOT%;WIM_ROOT=%WIM_ROOT%;_RELEASEDIR=%BLD_DIR%\;PROD=%PRODUCT%;PRJDIR=%SRC_DIR%;COMDIR=%COMMON_DIR%;BSPVER=%PKG_VER%;OEMNAME=%OEM_NAME%"

if errorlevel 0 (
	REM remove unused .spkg files
	del %PKGBLD_DIR%\*.spkg
	echo Package creation completed
) else (
	echo Package creation failed with error %ERRORLEVEL%
	goto :Error
)
popd
endlocal
exit /b 0

:Error
popd
endlocal
exit /b -1
