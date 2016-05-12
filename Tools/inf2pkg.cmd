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

REM Initialise required INF Configurations
call :INIT_CONFIG
REM Extracting inf dependencies
call :PARSE_INF_FILE %1

echo. Authoring %COMP_NAME%.%SUB_NAME%.pkg.xml
if exist "%OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml" (del "%OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml" )
call :CREATE_PKGFILE 

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

:PARSE_INF_FILE
set TOKEN=0
set TOKEN_FOUND=0
REM Cleanup files before start
if exist %FILE_PATH%\inf_filelist.txt ( del %FILE_PATH%\inf_filelist.txt )
if exist %FILE_PATH%\input.inf ( del %FILE_PATH%\input.inf )
echo. Processing %1
REM Convert the encoding format to utf8
powershell -Command "(gc %1)| ?{$_.trim()}  | Out-File %FILE_PATH%\input.inf -Encoding utf8"
REM Parse the inf section and get the list of dependencies
for /f "delims=" %%i in (%FILE_PATH%\input.inf) do (
   if !TOKEN_FOUND! == 1 (
      REM Check if next field has started
        set TEST=%%i
        set TEST=!TEST:[=!
        if "!TEST!" NEQ "%%i" (
            set TOKEN_FOUND=0
            set TOKEN=0
        ) else (
            if "!TOKEN!" EQU "[SourceDisksFiles]" (
                REM Parsing SourceDisksFiles section
                for /f "tokens=1,* delims= " %%A in ("%%i") do (
                    echo.%%A>> %FILE_PATH%\inf_filelist.txt
                )
            ) else if "!TOKEN!" EQU "[DestinationDirs]" (
                REM Parsing DestinationDirs section
                for /f "tokens=1,2,3 delims= " %%A in ("%%i") do (
                    call :FIND_TEXT "%DIRIDLIST%" %%C
                    if errorlevel 1 (
                        if "%%A" EQU "DefaultDestDir" (
                            set "DEFAULTLOC=!DIRID%%CLOC!"
                        ) else (
                            set "DIRIDGRP%%C=[%%A] !DIRIDGRP%%C!"
                            set TOKENLIST=[%%A] !TOKENLIST!
                        )                            
                    ) else ( 
                        echo Error : Unsupported DIRID %%C. Using this as 12. Please edit generated file to put to actual path
                        if "%%A" EQU "DefaultDestDir" (
                            set "DEFAULTLOC=%DIRID12LOC%"
                        ) else (
                            set DIRIDGRP12=[%%A] !DIRIDGRP12!
                            set TOKENLIST=[%%A] !TOKENLIST!
                        )                     
                    )
                )
            ) else (
                REM Check if the token is part of the DIRIDGRP
                for %%d in (%DIRIDLIST%) do (
                    call :FIND_TEXT "!DIRIDGRP%%d!" !TOKEN!
                    if errorlevel 1 (
                        for /f "tokens=1 delims=," %%A in ("%%i") do (
                            set "DIRID%%dLIST=%%A !DIRID%%dLIST!"
                        )
                    )
                )
            )
        )
    )
    call :FIND_TEXT "!TOKENLIST!" %%i
    if errorlevel 1 (
        echo.   Parsing %%i
        set TOKEN=%%i
        set TOKEN_FOUND=1
    )
)
exit /b

:CREATE_PKGFILE
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
    set "LOCATION=%DEFAULTLOC%"
    REM Check if the file name is in any DIRID list and set dir location accordingly
    for %%d in (%DIRIDLIST%) do (
        call :FIND_TEXT "!DIRID%%dLIST!" %%A
        if errorlevel 1 (
            set "LOCATION=!DIRID%%dLOC!"
        )
    )
    echo.   Placing %%A in !LOCATION!
	call :PRINT_TEXT "           <File Source="%%A" "
    echo                  DestinationDir="!LOCATION!" >> %OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml 
    call :PRINT_TEXT "                 Name="%%A" />"
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

:FIND_TEXT
set TESTLINE=%1
set TESTLINE=!TESTLINE:%2 =!
if %1 NEQ !TESTLINE! ( exit /b 1)
exit /b 0

:INIT_CONFIG
set TOKENLIST=[SourceDisksFiles] [DestinationDirs] 
REM Add DirID and the corresponding location here for extending support for more DirIDs
set DIRIDLIST= 10 11 12 24   

set DIRID10LOC=$(runtime.windows)
set DIRID11LOC=$(runtime.system32)
set DIRID12LOC=$(runtime.drivers)
set DIRID24LOC=$(runtime.root)

exit /b 0

