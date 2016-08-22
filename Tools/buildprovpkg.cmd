@echo off

goto START

:Usage
echo Usage: buildprovpkg [CompName.SubCompName]/[All]/Clean
echo    CompName.SubCompName...... Package ComponentName.SubComponent Name
echo    All....................... All prov packages under \Packages directory are built
echo    Clean..................... Removes all ppkg files
echo        One of the above should be specified
echo    [version]................. Optional, Package version. If not specified, it uses BSP_VERSION
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildprovpkg Provisioning.Enroll
echo        buildpkg All

exit /b 1

:START
setlocal
pushd

set COMMON_PKG=%COMMON_DIR%\Packages
set PRODUCTS_DIR=%SRC_DIR%\Products

if not exist %PKGLOG_DIR% ( mkdir %PKGLOG_DIR% )
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if /I [%1] == [All] (
    echo Creating all provisioning packages under %COMMON_PKG%
    cd %COMMON_PKG%
    dir Provisioning.* /b /AD  > %PKGLOG_DIR%\commonprovlist.txt
    for /f "delims=" %%i in (%PKGLOG_DIR%\commonprovlist.txt) do (
        call :SUB_PROCESSLIST %%i
    )
    echo Creating all provisioning packages under %PRODUCTS_DIR%
    cd %PRODUCTS_DIR%
    dir /b /AD  > %PKGLOG_DIR%\commonprovlist.txt
    for /f "delims=" %%i in (%PKGLOG_DIR%\commonprovlist.txt) do (
        if exist "%PRODUCTS_DIR%\%%i\prov\customizations.xml" (
            echo. Processing %%i
            call createprovpkg.cmd %PRODUCTS_DIR%\%%i\prov\customizations.xml %PRODUCTS_DIR%\%%i\prov\%%iProv.ppkg > %PKGLOG_DIR%\%%i.prov.log
        ) else (
            echo. Skipping %%i
        )
    )
    del %PKGLOG_DIR%\commonprovlist.txt
) else if /I [%1] == [Clean] (
	del %COMMON_DIR%\*.ppkg /S /Q
	del %SRC_DIR%\*.ppkg /S /Q
) else (
    call :SUB_PROCESSLIST %%i
)
popd
endlocal
exit /b

:SUB_PROCESSLIST
if exist "%COMMON_PKG%\%1\customizations.xml" (
    echo. Processing %1
    cd %COMMON_PKG%\%1
    call createprovpkg.cmd customizations.xml %1.ppkg > %PKGLOG_DIR%\%1.prov.log
    if not errorlevel 0 ( echo. Error : Failed to create provisioning package. See %PKGLOG_DIR%\%1.prov.log )
) else (
    echo. Skipping %1
)
exit /b