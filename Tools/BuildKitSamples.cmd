:: This script builds architecture specific FFUs for OEMInputSamples in Core Kit package
@echo off
setlocal

echo.
echo.Build Start Time : %TIME%
echo.

if [%ARCH%] == [arm] (
	call :COPY_AND_BUILD RPi2
) else if [%ARCH%] == [x86] (
	call :COPY_AND_BUILD MBM
	call :COPY_AND_BUILD APL
) else if [%ARCH%] == [x64] (
	call :COPY_AND_BUILD MBM
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
echo. Copying %1 OEMInputSamples to %PRODUCT_DIR%
copy "%KITSROOT%OEMInputSamples\%BSP_ARCH%\%1\RetailOemInput.xml" "%PRODUCT_DIR%\RetailOemInput.xml" >nul
copy "%KITSROOT%OEMInputSamples\%BSP_ARCH%\%1\ProductionOemInput.xml" "%PRODUCT_DIR%\TestOemInput.xml" >nul
echo. Building %1FFU
REM call buildimage %1FFU
exit /b 0

