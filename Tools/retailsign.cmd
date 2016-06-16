@echo off

goto :START

:Usage
echo Usage: retailsign [On/Off]
echo    On ................... Enables Cross Cert for signing
echo    Off................... Disables Cross Cert for signing and enables OEM Test Signing
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        retailsign On
echo        retailsign Off

exit /b 1

:START

REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if /i [%1] == [On] (
    REM set the cross cert information in the env variables
    call setsignature.cmd
    REM enable sign with timestamp
    set SIGN_WITH_TIMESTAMP=1
    echo Retail Signing enabled
	set PROMPT=IoTCore %BSP_ARCH% %BSP_VERSION% Retail$_$P$G
	TITLE IoTCoreShell %BSP_ARCH% %BSP_VERSION% Retail
) else (
    if /i [%1] == [Off] (
        REM remove cross cert information in the env variables
        set SIGN_WITH_TIMESTAMP=0
        set SIGNTOOL_OEM_SIGN=
        echo Retail Signing disabled
		set PROMPT=IoTCore %BSP_ARCH% %BSP_VERSION%$_$P$G
		TITLE IoTCoreShell %BSP_ARCH% %BSP_VERSION%
    ) else goto Usage
)

exit /b 0