:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new product
:: usage : newproduct <product name>
@echo off
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if NOT DEFINED SRC_DIR (
	echo Environment not defined. Call setenv
	goto End
)
:: Error Checks

if /i EXIST %SRC_DIR%\Products\%1 (
	echo Error : %1 already exists; 
	goto End
)
:: Start processing command
echo Creating %1 Product
SET PRODUCT=%1
SET PRODSRC_DIR=%SRC_DIR%\Products\%PRODUCT%

mkdir "%PRODSRC_DIR%"
mkdir "%PRODSRC_DIR%\bsp"
mkdir "%PRODSRC_DIR%\prov"

if [%BSP_ARCH%] ==[arm] (
:: Copying template files
if exist "%KITSROOT%OEMInputSamples\arm" (
copy "%KITSROOT%OEMInputSamples\arm\RPi2\RetailOEMInput.xml" %PRODSRC_DIR%\RetailOEMInput.xml
copy "%KITSROOT%OEMInputSamples\arm\RPi2\ProductionOEMInput.xml" %PRODSRC_DIR%\TestOEMInput.xml
) else (
copy "%KITSROOT%OEMInputSamples\RPi2\RetailOEMInput.xml" %PRODSRC_DIR%\RetailOEMInput.xml
copy "%KITSROOT%OEMInputSamples\RPi2\ProductionOEMInput.xml" %PRODSRC_DIR%\TestOEMInput.xml
)
copy "%KITSROOT%FMFiles\arm\RPi2FM.xml" %PRODSRC_DIR%\bsp\OEM_RPi2FM.xml
copy "%KITSROOT%FMFiles\arm\IoTUAPRPi2FM.xml" %PRODSRC_DIR%\bsp\OEM_IoTUAPRPi2FM.xml
)
if [%BSP_ARCH%] ==[x86] (
:: Copying template files
if exist "%KITSROOT%OEMInputSamples\x86" (
copy "%KITSROOT%OEMInputSamples\x86\MBM\RetailOEMInput.xml" %PRODSRC_DIR%\RetailOEMInput.xml
copy "%KITSROOT%OEMInputSamples\x86\MBM\ProductionOEMInput.xml" %PRODSRC_DIR%\TestOEMInput.xml
) else (
copy "%KITSROOT%OEMInputSamples\MBM\RetailOEMInput.xml" %PRODSRC_DIR%\RetailOEMInput.xml
copy "%KITSROOT%OEMInputSamples\MBM\ProductionOEMInput.xml" %PRODSRC_DIR%\TestOEMInput.xml
)
copy "%KITSROOT%FMFiles\x86\MBMFM.xml" %PRODSRC_DIR%\bsp\OEM_MBMFM.xml
)

copy "%IOTADK_ROOT%\Templates\oemcustomization.cmd" %PRODSRC_DIR%\oemcustomization.cmd
REM Get a new GUID for the Provisioning config file
call "%KITSROOT%bin\x64\uuidgen.exe" > %PRODSRC_DIR%\uuid.txt
set /p NEWGUID=<%PRODSRC_DIR%\uuid.txt
del %PRODSRC_DIR%\uuid.txt

powershell -Command "(gc %IOTADK_ROOT%\Templates\customizations.xml) -replace 'ProductName', '%PRODUCT%Prov' -replace 'GUID', '%NEWGUID%' | Out-File %PRODSRC_DIR%\prov\customizations.xml -Encoding utf8"

echo %1 product directories ready
goto End

:Usage
echo Usage: newproduct ProductName 
echo    ProductName....... Required, Name of the product to be created. 
echo    [/?].............. Displays this usage string. 
echo    Example:
echo        newproduct SampleA 
echo Existing products are
dir /b /AD %SRC_DIR%\Products

exit /b 1

:Error
echo "newproduct %1 " failed with error %ERRORLEVEL%
exit /b 1

:End
exit /b 0
