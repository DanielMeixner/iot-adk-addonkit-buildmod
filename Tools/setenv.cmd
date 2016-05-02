@echo off
goto START

:Usage
echo Usage: setenv arch 
echo    arch....... Required, %SUPPORTED_ARCH% 
echo    [/?]........Displays this usage string. 
echo    Example:
echo        setenv arm 

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

set SUPPORTED_ARCH=arm x86 x64
echo.%SUPPORTED_ARCH% | findstr /C:"%1" >nul && (
	echo Configuring for %1 architecture
) || (
	echo.Error: %1 not supported
	goto Usage 
)

REM Environment configurations
dir /B /AD "%KITSROOT%CoreSystem" > %IOTADK_ROOT%\wdkversion.txt
SET /P WDK_VERSION=<%IOTADK_ROOT%\wdkversion.txt
echo WDK_VERSION : %WDK_VERSION%
del %IOTADK_ROOT%\wdkversion.txt

SET PATH=%KITSROOT%tools\bin\i386;%PATH%
SET AKROOT=%KITSROOT%
SET WPDKCONTENTROOT=%KITSROOT%
SET PKG_CONFIG_XML=%KITSROOT%Tools\bin\i386\pkggen.cfg.xml

SET BSP_ARCH=%1
if [%1] == [x64] ( SET BSP_ARCH=amd64 )
SET HIVE_ROOT=%KITSROOT%CoreSystem\%WDK_VERSION%\%BSP_ARCH%
SET WIM_ROOT=%KITSROOT%CoreSystem\%WDK_VERSION%\%BSP_ARCH%
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
SET PKGLOG_DIR=%PKGBLD_DIR%\logs
SET TOOLS_DIR=%IOTADK_ROOT%\Tools

if not exist %PKGLOG_DIR% ( mkdir %PKGLOG_DIR% )

call setversion.cmd

REM Get version number of the Corekit packages installed
for /F "skip=2 tokens=3" %%r in ('reg query "HKEY_CLASSES_ROOT\Installer\Dependencies\Microsoft.Windows.Windows_10_IoT_Core_%1_Packages.x86.10" /v Version') do (
	set KIT_VERSION=%%r 
)
REM echo KIT_VERSION : %KIT_VERSION%
for /f "tokens=3 delims=." %%r in ("%KIT_VERSION%") do ( set BUILD_NR=%%r )
echo BUILD_NR    : %BUILD_NR%

set PROMPT=IoTCore %BSP_ARCH% %BSP_VERSION%$_$P$G
TITLE IoTCoreShell %BSP_ARCH% %BSP_VERSION%

echo BSP_ARCH    : %BSP_ARCH%
echo BSP_VERSION : %BSP_VERSION%
echo.

exit /b 0
