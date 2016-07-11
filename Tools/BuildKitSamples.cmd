@echo off

echo.
echo.Build Start Time : %TIME%
echo.

if [%ARCH%] == [arm] (
	call :COPY_PRODUCT arm RPi2
) else if [%ARCH%] == [x86] (
	call :COPY_PRODUCT x86 mbm
	call :COPY_PRODUCT x86 APL
) else if [%ARCH%] == [amd64] (
	call :COPY_PRODUCT amd64 mbm
)

echo.
echo.Build End Time : %TIME%
echo.
exit /b 0

:COPY_PRODUCT
echo Processing %1 %2FFU product
set PRODUCT_DIR=%SRC_DIR%\Products\%2FFU
if not exist "%PRODUCT_DIR%" (
	mkdir "%PRODUCT_DIR%"
)
copy "%KITSROOT%OEMInputSamples\%1\%2\RetailOemInput.xml" "%PRODUCT_DIR%\RetailOemInput.xml" >nul
copy "%KITSROOT%OEMInputSamples\%1\%2\ProductionOemInput.xml" "%PRODUCT_DIR%\TestOemInput.xml" >nul
call buildimage %2FFU
exit /b 0

