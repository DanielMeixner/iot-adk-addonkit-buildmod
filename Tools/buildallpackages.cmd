@echo off

echo Creating all packages under %COMMON_DIR%\Packages
dir %COMMON_DIR%\Packages\*.pkg.xml /S /b > %PKGLOG_DIR%\commonpackagelist.txt

for /f "delims=" %%i in (%PKGLOG_DIR%\commonpackagelist.txt) do (
   echo. Processing %%~nxi
   call createpkg.cmd %%i > %PKGLOG_DIR%\%%~ni.log
)

echo Creating all packages under %PKGSRC_DIR%
dir %PKGSRC_DIR%\*.pkg.xml /S /b > %PKGLOG_DIR%\packagelist.txt

for /f "delims=" %%i in (%PKGLOG_DIR%\packagelist.txt) do (
   echo. Processing %%~nxi
   call createpkg.cmd %%i > %PKGLOG_DIR%\%%~ni.log
)

exit /b