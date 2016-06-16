@echo off
REM Script to install the updates

SET install_dir=%~dp0
REM Getting rid of the \ at the end
SET install_dir=%install_dir:~0,-1%
cd %install_dir%
dir /b %install_dir%\*.cab > updatelist.txt
for /f "delims=" %%i in (updatelist.txt) do (
   echo Staging %%i
   call applyupdate -stage %%i
   REM del %%i
)

echo.
echo Commit updates
applyupdate -commit
