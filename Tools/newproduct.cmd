:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new product
:: usage : newproduct <product name> <bsp name>
@echo off

goto START

:Usage
echo Usage: newproduct ProductName BSPName
echo    ProductName....... Required, Name of the product to be created. 
echo    BSPName........... Required, Name of the BSP to be used
echo    [/?].............. Displays this usage string. 
echo    Example:
echo        newproduct SampleA MBM
echo Existing products are
dir /b /AD %SRC_DIR%\Products

echo Existing BSPs are
dir /b /AD %SRC_DIR%\BSP

exit /b 1

:START
setlocal

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

if not defined SRC_DIR (
	echo Environment not defined. Call setenv
	goto End
)
:: Error Checks

if /i exist %SRC_DIR%\Products\%1 (
	echo Error : %1 already exists; 
	goto End
)

if /i not exist %SRC_DIR%\BSP\%2 (
	echo Error : %2 not found 
	goto End
)

:: Start processing command
echo Creating %1 Product with BSP %2
SET PRODUCT=%1
SET PRODSRC_DIR=%SRC_DIR%\Products\%PRODUCT%

mkdir "%PRODSRC_DIR%"
mkdir "%PRODSRC_DIR%\prov"

copy %BSPSRC_DIR%\%2\OEMInputSamples\RetailOEMInput.xml %PRODSRC_DIR%\RetailOEMInput.xml >nul
copy %BSPSRC_DIR%\%2\OEMInputSamples\TestOEMInput.xml %PRODSRC_DIR%\TestOEMInput.xml >nul

copy "%IOTADK_ROOT%\Templates\oemcustomization.cmd" %PRODSRC_DIR%\oemcustomization.cmd >nul
REM Get a new GUID for the Provisioning config file
call "%KITSROOT%bin\x64\uuidgen.exe" > %PRODSRC_DIR%\uuid.txt
set /p NEWGUID=<%PRODSRC_DIR%\uuid.txt
del %PRODSRC_DIR%\uuid.txt

powershell -Command "(gc %IOTADK_ROOT%\Templates\customizations.xml) -replace 'ProductName', '%PRODUCT%Prov' -replace 'GUID', '%NEWGUID%' | Out-File %PRODSRC_DIR%\prov\customizations.xml -Encoding utf8"

echo %1 product directories ready
goto End


:Error
endlocal
echo "newproduct %1 " failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
