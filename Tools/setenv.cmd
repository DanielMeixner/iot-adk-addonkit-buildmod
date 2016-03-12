@echo off
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if NOT [%1] == [arm] ( if NOT [%1] == [x86] (
 echo Error: %1 not supported
 goto Usage 
)
)

REM Environment configurations
dir /B /AD "%KITSROOT%CoreSystem" > %IOTADK_ROOT%\coreversion.txt
SET /P KIT_VERSION=<%IOTADK_ROOT%\coreversion.txt
echo KIT_VERSION : %KIT_VERSION%
del %IOTADK_ROOT%\coreversion.txt
REM SET KIT_VERSION=10.0.10586.0

SET PATH=%KITSROOT%tools\bin\i386;%PATH%
SET AKROOT=%KITSROOT%
SET WPDKCONTENTROOT=%KITSROOT%
SET PKG_CONFIG_XML=%KITSROOT%Tools\bin\i386\pkggen.cfg.xml

SET BSP_ARCH=%1
SET HIVE_ROOT=%KITSROOT%CoreSystem\%KIT_VERSION%\%BSP_ARCH%
SET WIM_ROOT=%KITSROOT%CoreSystem\%KIT_VERSION%\%BSP_ARCH%
REM The following variables ensure the package is appropriately signed
SET SIGN_OEM=1
SET SIGN_WITH_TIMESTAMP=0


REM Local project settings
SET COMMON_DIR=%IOTADK_ROOT%\Common
SET SRC_DIR=%IOTADK_ROOT%\Source-%1
SET PKGSRC_DIR=%SRC_DIR%\Packages
SET PKGUPD_DIR=%SRC_DIR%\Updates
SET BLD_DIR=%IOTADK_ROOT%\Build\%BSP_ARCH%
SET PKGBLD_DIR=%BLD_DIR%\pkgs
SET TOOLS_DIR=%IOTADK_ROOT%\Tools

call setversion.cmd

set PROMPT=IoTCore %BSP_ARCH% %BSP_VERSION%$_$P$G
TITLE IoTCoreShell %BSP_ARCH% %BSP_VERSION%

echo BSP_ARCH    : %BSP_ARCH%
echo BSP_VERSION : %BSP_VERSION%
echo.
goto End

:Usage
echo Usage: setenv arch 
echo    arch....... Required, arm/x86 
echo    [/?]........Displays this usage string. 
echo    Example:
echo        setenv arm 

exit /b 1

:End
exit /b 0
