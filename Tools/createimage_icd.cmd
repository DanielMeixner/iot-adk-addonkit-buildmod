@echo off
setlocal
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
if /I NOT [%2] == [Retail] ( if /I NOT [%2] == [Test] goto Usage )

REM Checking prerequisites
if NOT DEFINED SRC_DIR (
	echo Environment not defined. Call setenv
	goto End
)
REM Start processing command
echo Creating %1 %2 Image
echo Build Start Time : %TIME%

set PRODUCT=%1
set PRODSRC_DIR=%SRC_DIR%\Products\%PRODUCT%
set PRODBLD_DIR=%BLD_DIR%\%1\%2

echo Building product specific packages
call createpkg.cmd %SRC_DIR%\Packages\Custom.Cmd\Custom.Cmd.pkg.xml

echo creating image...
call icd.exe /Build-ImageFromPackages /ImagePath:"%BLD_DIR%\%1\%2\IoTCore.FFU" /OEMInputXML:"%PRODSRC_DIR%\%2OEMInput.xml" /MSPackageRoot:"%KITSROOT%MSPackages" /CPUType:%BSP_ARCH% /CustomizationXML:"%PRODSRC_DIR%\customizations.xml" /OEMCustomizationVer:"%BSP_VERSION%"

if errorlevel 1 goto Error

echo Build End Time : %TIME%
echo Image creation completed
goto End

:Usage
echo Usage: createimage ProductName BuildType 
echo    ProductName....... Required, Name of the product to be created. 
echo    BuildType......... Required, Retail/Test 
echo    [/?].............. Displays this usage string. 
echo    Example:
echo        createimage SampleA Retail

exit /b 1

:Error
echo "CreateImage %1 %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0

::icd.exe /Build-ImageFromPackages /ImagePath:<path_to_ffu> [/OEMInputXML:<path_to_xml>] 
::[/BSPConfigFile:<path_to_bsp_config_xml>] [/ImageType:<image_type>] [/MSPackageRoot:<path_to_mspackage_directory>] 
::[/CPUType:<CPUType>] [/ProvisioningPackage:<path_to_ppkg>] [/OEMCustomizationVer:<version>] 
::[/CustomizationXML:<path_to_xml>] [/MCSFCustomizationXML:<path_to_xml>] [/?]  