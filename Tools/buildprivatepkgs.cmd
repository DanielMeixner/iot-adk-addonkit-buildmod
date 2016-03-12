@echo off

echo Creating all packages under %SRC_DIR%\Packages

dir %SRC_DIR%\Private\*.pkg.xml /S /b > privatepackagelist.txt

for /f "delims=" %%i in (privatepackagelist.txt) do (
   echo Processing %%i
   call createpkg.cmd %%i
)
del privatepackagelist.txt

