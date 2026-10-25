@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  find_large_files.bat
rem  Lists the files that are at least a given size (in MB), and saves
rem  the list to large_files_report.txt.
rem
rem  Behavior:
rem    - Report only; no file is changed, moved or deleted.
rem    - Optionally includes sub-folders.
rem    - Sizes are shown in decimal MB (1 MB = 1,000,000 bytes),
rem      rounded down.
rem    - Skips this script, the report and hidden/system files.
rem ======================================================================

set "REPORTNAME=large_files_report.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "REPORT=%CD%\%REPORTNAME%"

:askmin
set "MIN="
set /p "MIN=Minimum file size in MB (whole number): "
if defined MIN set "MIN=%MIN:"=%"
if not defined MIN goto :badnum
for /f "delims=0123456789" %%X in ("%MIN%") do goto :badnum
if not "%MIN:~7%"=="" goto :badnum
if "%MIN:~0,1%"=="0" if not "%MIN%"=="0" goto :badnum

set "REC="
set /p "REC=Include sub-folders? (Y/N): "

set "DIROPT=/a-d-h-s"
if /i "%REC%"=="Y" set "DIROPT=/s /a-d-h-s"

> "%REPORT%" echo Files of at least %MIN% MB in "%CD%" - %DATE% %TIME%

echo.
set /a FOUND=0
for /f "eol=| delims=" %%F in ('dir /b %DIROPT%') do call :check "%%F"

echo.
echo Files found: %FOUND%
echo Report: %REPORTNAME%

popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:badnum
echo Enter a whole number from 0 to 9999999 without leading zeros.
echo.
goto :askmin

rem ----------------------------------------------------------------------
:check
if /i "%~nx1"=="%SELF%" exit /b 0
if /i "%~nx1"=="%REPORTNAME%" exit /b 0
set "SZ=%~z1"
if not defined SZ exit /b 0
set "MB=%SZ:~0,-6%"
if not defined MB set "MB=0"
if %MB% LSS %MIN% exit /b 0
>> "%REPORT%" echo %MB% MB  "%~f1"
echo %MB% MB  "%~f1"
set /a FOUND+=1
exit /b 0
