@echo off

if NOT DEFINED SRC_DIR (
	echo Environment not defined. Call setenv
	goto End
)
if exist %BLD_DIR% (
rmdir "%BLD_DIR%" /S /Q 
echo Build directories cleaned
) else echo Nothing to clean.
:End