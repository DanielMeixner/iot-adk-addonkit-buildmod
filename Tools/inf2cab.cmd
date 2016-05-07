:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new package
@echo off

goto START

:Usage
echo Usage: inf2cab filename.inf 
echo    filename.inf..... Required, input .inf file; expects filename.sys file in the same location 
echo    [/?]............. Displays this usage string. 
echo    Example:
echo        inf2cab C:\test\testdriver.inf
exit /b 1

:START

if NOT DEFINED SRC_DIR (
	echo Environment not defined. Call setenv
	exit /b -1
)

setlocal ENABLEDELAYEDEXPANSION

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

set PKG_TYPE=%~x1
set FILE_NAME=%~n1
set FILE_PATH=%~dp1

if [%PKG_TYPE%] ==[.inf] (
	set COMP_NAME=Drivers
	set SUB_NAME=%FILE_NAME%
) else ( goto Usage )


:: Start processing command
REM Extracting inf dependencies
call :Extract_Dependency %1

echo. Authoring %COMP_NAME%.%SUB_NAME%.pkg.xml
:: Create Driver package using template files
powershell -Command "(gc %IOTADK_ROOT%\Templates\DrvTemplate1.pkg.xml) -replace 'COMPNAME', '%COMP_NAME%' -replace 'SUBNAME', '%SUB_NAME%' -replace 'DRIVER_NAME', '%FILE_NAME%' -replace 'PLFNAME', '%BSP_ARCH%' | Out-File %FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml -Encoding utf8"

echo. Updating Pkg xml with dependencies
call :Update_PkgXml %FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml

if exist %FILE_PATH%\temp.xml (
del %FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml 
move /Y %FILE_PATH%\temp.xml %FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml >nul
REM Cleanup temp files
del %FILE_PATH%\input.inf
del %FILE_PATH%\infdep.txt
)


echo. Processing %COMP_NAME%.%SUB_NAME%.pkg.xml 
set PKGBLD_DIR=%FILE_PATH%\
call createpkg %FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml > %FILE_PATH%%COMP_NAME%.%SUB_NAME%.pkg.log
if not errorlevel 0 ( echo. Error : Failed to create package. See %FILE_PATH%%COMP_NAME%.%SUB_NAME%.pkg.log 
) else (echo. Package created. See %FILE_PATH%%OEM_NAME%.%COMP_NAME%.%SUB_NAME%.cab )

goto End

:Error
endlocal
echo "inf2cab %1 " failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0

:Extract_Dependency
setlocal ENABLEDELAYEDEXPANSION
set TOKEN=0
if exist %FILE_PATH%\infdep.txt ( del %FILE_PATH%\infdep.txt )
if exist %FILE_PATH%\input.inf ( del %FILE_PATH%\input.inf )
echo. Processing %1
REM Convert the encoding format to utf8
powershell -Command "(gc %1) | Out-File %FILE_PATH%\input.inf -Encoding utf8"
REM Parse the inf section SourceDiskFiles and get the list of dependencies
for /f "delims=" %%i in (%FILE_PATH%\input.inf) do (
   if !TOKEN! == 1 (
		for /f "tokens=1,* delims= " %%A in ("%%i") do (
			if "%%B" EQU "" (
					set TOKEN=0
				) else (
				 echo.%%A>> %FILE_PATH%\infdep.txt
				)
		)
    )
   if "%%i" EQU "[SourceDisksFiles]" (
    set TOKEN=1
   )	  
)
endlocal
exit /b

:Update_PkgXml
setlocal ENABLEDELAYEDEXPANSION
if exist %FILE_PATH%\temp.xml (del %FILE_PATH%\temp.xml)
if not exist %FILE_PATH%\infdep.txt (
	echo. error, file not found :%FILE_PATH%\infdep.txt 
	exit /b 1
)
set TOKEN=0
for /f "delims=" %%i in (%1) do (
   if !TOKEN! == 1 (
		for /f "delims=" %%A in (%FILE_PATH%\infdep.txt) do (
			call :PRINT_TEXT "         <Reference Source="%%A" />"
		)
		call :PRINT_TEXT "         <Files>"
		
		for /f "delims=" %%A in (%FILE_PATH%\infdep.txt) do (
			call :PRINT_TEXT "           <File Source="%%A" />"
		)
		call :PRINT_TEXT "         </Files>"		
		set TOKEN=0
    )
   if "%%i" EQU "RefMark_Start" (
		call :PRINT_TEXT "      <Driver InfSource="%FILE_NAME%.inf">"
        set TOKEN=1
   ) else (
		echo %%i >> %FILE_PATH%\temp.xml
   ) 	  
)
endlocal
exit /b 0

:PRINT_TEXT
for /f "useback tokens=*" %%a in ('%1') do set TEXT=%%~a
echo !TEXT! >> %FILE_PATH%\temp.xml
exit /b