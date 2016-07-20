REM This script builds architecture specific FFUs for OEMInputSamples in Core Kit package
REM Usage: BuildKitSamples [BuildType]
REM    BuildType......... Optional, Retail/Test; if not specified, it builds both Retail and Test
REM    Example:
REM        BuildKitSamples Test
REM        BuildKitSamples Retail
REM        BuildKitSamples 

@echo off
setlocal
set FLAVOUR=%1
if /I NOT [%1] == [Retail] ( if /I NOT [%1] == [Test] set FLAVOUR=  )
echo.
echo.Build Start Time : %TIME%
echo.

if [%ARCH%] == [arm] (
	call :COPY_AND_BUILD RPi2 %FLAVOUR%
) else if [%ARCH%] == [x86] (
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
copy "%KITSROOT%OEMInputSamples\%1\RetailOemInput.xml" "%PRODUCT_DIR%\RetailOemInput.xml" >nul
copy "%KITSROOT%OEMInputSamples\%1\ProductionOemInput.xml" "%PRODUCT_DIR%\TestOemInput.xml" >nul
echo.Building %1FFU %2
call buildimage %1FFU %2
exit /b 0

