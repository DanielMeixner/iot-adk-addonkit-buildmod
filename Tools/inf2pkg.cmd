:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new package
@echo off

goto START

:Usage
echo Usage: inf2pkg input.inf [CompName.SubCompName]
echo    input.inf............... Required, input .inf file
echo    CompName.SubCompName.... Optional, default is Drivers.input
echo    [/?].................... Displays this usage string.
echo    Example:
echo        inf2pkg C:\test\testdriver.inf 
exit /b 1

:START

setlocal ENABLEDELAYEDEXPANSION

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if not [%~x1] == [.inf] goto Usage

set FILE_NAME=%~n1
set FILE_PATH=%~dp1
set OUTPUT_PATH=%FILE_PATH%
if [%2] == [] (
	set COMP_NAME=Drivers
	set SUB_NAME=%FILE_NAME%
) else (
	for /f "tokens=1,2 delims=." %%i in ("%2") do ( 
		set COMP_NAME=%%i
		set SUB_NAME=%%j
	)
)

REM Start processing command
REM Extracting inf dependencies
call :Extract_Dependency %1

echo. Authoring %COMP_NAME%.%SUB_NAME%.pkg.xml
if exist "%OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml" (del "%OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml" )
call :Create_PkgXml 

REM check for dependency files in the same folder and flag error if missing
for /f "delims=" %%i in (%FILE_PATH%\inf_filelist.txt) do (
	if not exist "%FILE_PATH%%%i" (
	    echo.   Warning : %FILE_PATH%%%i not found, package creation will fail. 		
	)
	
)	

REM Cleanup temp files
del %FILE_PATH%\input.inf
REM del %FILE_PATH%\inf_filelist.txt

endlocal
exit /b 0

:Extract_Dependency
set TOKEN=0
if exist %FILE_PATH%\inf_filelist.txt ( del %FILE_PATH%\inf_filelist.txt )
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
					exit /b
				) else (
				 echo.%%A>> %FILE_PATH%\inf_filelist.txt
				)
		)
    )
   if "%%i" EQU "[SourceDisksFiles]" (
    set TOKEN=1
   )	  
)
exit /b

:Create_PkgXml
if not exist %FILE_PATH%\inf_filelist.txt (
	echo. error, file not found :%FILE_PATH%\inf_filelist.txt 
	exit /b 1
)
REM Printing the headers
call :PRINT_TEXT "<?xml version="1.0" encoding="utf-8" ?>" 
call :PRINT_TEXT "<Package xmlns="urn:Microsoft.WindowsPhone/PackageSchema.v8.00""
echo          Owner="$(OEMNAME)" OwnerType="OEM" ReleaseType="Production" >> %OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml
call :PRINT_TEXT "         Platform="%BSP_ARCH%" Component="%COMP_NAME%" SubComponent="%SUB_NAME%">"
call :PRINT_TEXT "   <Components>"
call :PRINT_TEXT "      <Driver InfSource="%FILE_NAME%.inf">"
REM Printing references
for /f "delims=" %%A in (%FILE_PATH%\inf_filelist.txt) do (
	call :PRINT_TEXT "         <Reference Source="%%A" />"
)
call :PRINT_TEXT "         <Files>"
REM Printing file sources
for /f "delims=" %%A in (%FILE_PATH%\inf_filelist.txt) do (
	call :PRINT_TEXT "           <File Source="%%A" />"
)
call :PRINT_TEXT "         </Files>"
call :PRINT_TEXT "      </Driver>"
call :PRINT_TEXT "   </Components>" 
call :PRINT_TEXT "</Package>" 		
)
exit /b 0

:PRINT_TEXT
for /f "useback tokens=*" %%a in ('%1') do set TEXT=%%~a
echo !TEXT! >> %OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml
exit /b