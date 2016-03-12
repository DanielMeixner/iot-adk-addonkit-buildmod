@echo off

echo Creating all packages under %COMMON_DIR%\Packages

dir %COMMON_DIR%\Packages\*.pkg.xml /S /b > commonpackagelist.txt

for /f "delims=" %%i in (commonpackagelist.txt) do (
   echo Processing %%i
   call createpkg.cmd %%i
)
del commonpackagelist.txt

echo Creating all packages under %PKGSRC_DIR%

dir %PKGSRC_DIR%\*.pkg.xml /S /b > packagelist.txt

for /f "delims=" %%i in (packagelist.txt) do (
   echo Processing %%i
   call createpkg.cmd %%i
)

del packagelist.txt
