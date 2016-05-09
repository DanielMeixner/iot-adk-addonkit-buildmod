@echo off

::
:: Ensure we execute batch script from the folder that contains the batch script
::
pushd %~dp0
SETLOCAL

if exist %systemdrive%\windows\system32\mindeployappx.exe (
	echo Mindeployappx.exe found. Using older install script
	if exist AppInstall_TH.cmd (call AppInstall_TH.cmd )
	exit /b %errorlevel%
)

REM New Install Mechanism
if not exist %systemdrive%\windows\system32\deployappx.exe ( 
	echo deployappx.exe not found. exiting. 
	exit /b 1
)

call AppxConfig.cmd

set AppxID=%defaultappxid% 
set AppxName=%defaultappx%.appx
echo Appx Name :%AppxName%

if not defined forceinstall (set forceinstall=0)
if not exist .\logs ( mkdir logs )

REM Get AppxVer
for /f "tokens=2 delims=_" %%A in ("%AppxName%") do ( set "AppxVer=%%A" )
echo Appx Ver : %AppxVer%
REM Get AppxGuid
for /f "tokens=1 delims=_" %%A in ("%AppxID%") do ( set "AppxGuid=%%A" )
echo Appx Guid : %AppxGuid%

REM Get the list of installed packages
deployappx.exe getpackages > .\logs\installed_packages.txt
REM Check if the AppxGuid is already installed, if so get full package name

findstr /l "%AppxGuid%" .\logs\installed_packages.txt > .\logs\fullpackagename.txt
if %errorlevel%==0 (
	REM Appx is installed.
	set /P CurrentAppxID=<.\logs\fullpackagename.txt
)
if defined CurrentAppxID (
	REM Get CurrentAppxVer
	for /f "tokens=2 delims=_" %%A in ("%CurrentAppxID%") do ( set "CurrentAppxVer=%%A" )
)
if defined CurrentAppxVer (
	echo Installed Appx Ver : %CurrentAppxVer%
	REM If same version, then do nothing. 

	if /i "%AppxVer%" EQU "%CurrentAppxVer%" ( 
		echo Same version already installed
		goto :CLEANUP
	)
	REM If higher version already installed,  	
	if /i "%AppxVer%" LSS "%CurrentAppxVer%" (
		if %forceinstall%==1 (
			REM downgrade requested, proceed with uninstall and then continue with install
			call deployappx.exe uninstall %CurrentAppxID%
		) else (
			echo Higher version already installed
			goto :CLEANUP
		)
	)
)
REM
REM Add AllowAllTrustedApps Reg Key
REM
echo Adding AllowAllTrustedApps Reg Key.
reg add "HKLM\Software\Policies\Microsoft\Windows\Appx" /v AllowAllTrustedApps /t REG_DWORD /d 1 /f
call :SUB_CHECKERROR "Failed to add AllowAllTrustedApps"

REM
REM Add all dependency appx
REM
echo Installing dependency appx packages
for %%d in (%dependencylist%) do (
	echo Installing %%d
    deployappx.exe install .\%%d.appx >> .\logs\dependency_result.txt
)

REM
REM Install the Main Appx
REM

echo Installing %AppxName%
deployappx.exe install %AppxName% > %temp%\%AppxName%_result.txt
call :SUB_CHECKERROR "%AppxName% failed to deploy"

REM Trigger IoTStartup
iotstartup.exe add headed %AppxID%

goto :CLEANUP

REM -------------------------------------------------------------------------------
REM
REM SUB_CHECKERROR <comment>
REM
REM On Error, displays failure code and exits, otherwise returns to caller
REM
REM ------------------------------------------------------------------------------- 
:SUB_CHECKERROR
if "%ERRORLEVEL%"=="0" exit/b
echo.
echo Error %1
echo Result=%ERRORLEVEL%
echo.
popd
ENDLOCAL
exit /b %ERRORLEVEL%

:CLEANUP
popd
ENDLOCAL
exit /b

