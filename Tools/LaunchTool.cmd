@Echo off
REM 
REM  Call the DandISetEnv.bat
REM
IF /I %PROCESSOR_ARCHITECTURE%==x86 (
call "%ProgramFiles%\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
) ELSE IF /I %PROCESSOR_ARCHITECTURE%==amd64 (
call "%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
)

SET IOTADK_ROOT=%~dp0
REM Getting rid of the \Tools\ at the end
SET IOTADK_ROOT=%IOTADK_ROOT:~0,-7%
echo IOTADK_ROOT : %IOTADK_ROOT%
set PATH=%PATH%;%IOTADK_ROOT%\Tools;
TITLE IoTCoreShell
REM Change to Working directory
cd %IOTADK_ROOT%\Tools
call setOEM.cmd
echo OEM_NAME    : %OEM_NAME%
echo.
echo Set Environment for Architecture 
choice /C 12 /N /M "Choose 1 for ARM and 2 for x86"
echo.
if ERRORLEVEL 2 (
call setenv x86
)else if ERRORLEVEL 1 (
call setenv arm 
)

