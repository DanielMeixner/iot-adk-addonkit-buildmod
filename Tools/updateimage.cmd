@echo off
echo This is a beta version
goto START

:Usage
echo Usage: updateimage ProductName BuildType UpdateName
echo    ProductName....... Required, Name of the product to be updated. 
echo    BuildType......... Required, Retail/Test 
echo    UpdateName........ Required, Name of the update to be applied
echo    [/?].............. Displays this usage string. 
echo    Example:
echo        updateimage SampleA Retail Update1

exit /b 1

:START

setlocal
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
if [%3] == [] goto Usage

REM Checking prerequisites
set PRODUCT=%1
if NOT exist "%SRC_DIR%\Products\%PRODUCT%" (
	echo %1 does not exist. Available Products are
	dir /B /AD %SRC_DIR%\Products
	echo.
	goto END
)

if /I NOT [%2] == [Retail] ( if /I NOT [%2] == [Test] goto Usage )

set UPDATE=%3
if NOT exist "%PKGUPD_DIR%\%UPDATE%" (
	echo %1 does not exist. Available updates are
	dir /B /AD %PKGUPD_DIR%
	echo.
	goto END
)

set PRODSRC_DIR=%SRC_DIR%\Products\%PRODUCT%
set PRODBLD_DIR=%BLD_DIR%\%1\%2
set UPDBLD_DIR=%BLD_DIR%\%PRODUCT%\%UPDATE%\%2

if NOT exist %PRODBLD_DIR%\Flash.FFU (
   echo %PRODBLD_DIR%\Flash.FFU does not exist. Create FFU using createimage
   echo.
   goto END
)
if NOT exist %UPDBLD_DIR% (
   mkdir %UPDBLD_DIR%
)
REM Start processing command
echo Updating %PRODUCT% %2 Image with %UPDATE%
echo Build Start Time : %TIME%
echo Making a copy of the FFU
copy %PRODBLD_DIR%\Flash.FFU %UPDBLD_DIR%\Flash.FFU

echo Updating image...
call ImageApp.exe "%UPDBLD_DIR%\Flash.FFU" /UpdateInputXML:"%PKGUPD_DIR%\%UPDATE%\UpdateInput.xml" 

if errorlevel 1 goto Error

echo Build End Time : %TIME%
echo Image Update completed
goto End

:Error
endlocal
echo "UpdateImage %1 %2 %3" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0