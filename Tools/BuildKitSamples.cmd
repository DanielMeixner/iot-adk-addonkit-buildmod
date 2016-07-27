@echo off
REM This script builds architecture specific FFUs for OEMInputSamples in Core Kit package
setlocal

goto START

:Usage
echo Usage: BuildKitSamples [BuildType]
echo    BuildType.........  Retail/Test 
echo    Example:
echo        BuildKitSamples Test
echo        BuildKitSamples Retail

exit /b 1

:START
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if /I NOT [%1] == [Retail] ( if /I NOT [%1] == [Test] goto Usage  )
set FLAVOUR=%1

echo.
echo.Build Start Time : %TIME%
echo.

if [%ARCH%] == [arm] (
	echo Building RPi2 product 
	call :COPY_AND_BUILD RPi2 %FLAVOUR%
) else if [%ARCH%] == [x86] (
	echo Building MBM product
	call :COPY_AND_BUILD MBM %FLAVOUR%
)

echo.
echo.Build End Time : %TIME%
echo.

endlocal
exit /b 0

:COPY_AND_BUILD
set PRODUCT_DIR=%SRC_DIR%\Products\%1FFU
if not exist "%PRODUCT_DIR%" (
	mkdir "%PRODUCT_DIR%"
)
echo.Copying %1 OEMInputSamples to %PRODUCT_DIR%
copy "%KITSROOT%OEMInputSamples\%BSP_ARCH%\%1\RetailOemInput.xml" "%PRODUCT_DIR%\RetailOemInput.xml" >nul
copy "%KITSROOT%OEMInputSamples\%BSP_ARCH%\%1\ProductionOemInput.xml" "%PRODUCT_DIR%\TestOemInput.xml" >nul
echo.Building %1FFU %2
call buildimage %1FFU %2
exit /b 0

