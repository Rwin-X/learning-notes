@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  zip_each_file.bat
rem  Compresses every file in the script's directory into its own ZIP
rem  archive, using the tar tool that is built into Windows 10 (version
rem  1803) and later.
rem
rem  Example:  report.pdf -> report.pdf.zip
rem
rem  Behavior:
rem    - Original files are kept.
rem    - Existing archives are never overwritten; those files are skipped.
rem    - Files that are already .zip are skipped.
rem    - Skips this script, hidden/system files and folders.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

where tar >nul 2>&1
if errorlevel 1 goto :notar

set "SELF=%~nx0"
set "LIST=%TEMP%\zip_each_%RANDOM%%RANDOM%.txt"

rem --- Build the list of files ---
(
  for /f "eol=| delims=" %%F in ('dir /b /a-d-h-s') do (
    if /i not "%%F"=="%SELF%" echo(%%F
  )
) > "%LIST%"

set /a TOTAL=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do set /a TOTAL+=1

if %TOTAL% EQU 0 goto :nofiles

echo Directory : "%CD%"
echo Files     : %TOTAL%
echo.
set "CONFIRM="
set /p "CONFIRM=Create one ZIP archive per file? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

set /a DONE=0
set /a SKIPPED=0
set /a FAILED=0

for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :zip "%%F"

echo.
echo Created : %DONE%
echo Skipped : %SKIPPED%
echo Failed  : %FAILED%
goto :cleanup

:notar
echo The tar tool was not found. Windows 10 version 1803 or later is required.
goto :end

:nofiles
echo No files found in this directory.
goto :cleanup

:cancelled
echo Cancelled.

:cleanup
if exist "%LIST%" del "%LIST%" >nul 2>&1

:end
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:zip
if /i "%~x1"==".zip" goto :skip
set "ZIPNAME=%~nx1.zip"
if exist "%ZIPNAME%" goto :skip_exists
tar -a -c -f "%ZIPNAME%" "%~1" 2>nul
if errorlevel 1 goto :fail
echo "%~1"  =^>  "%ZIPNAME%"
set /a DONE+=1
exit /b 0

:skip
set /a SKIPPED+=1
exit /b 0

:skip_exists
echo [SKIP] Archive already exists: "%ZIPNAME%"
set /a SKIPPED+=1
exit /b 0

:fail
if exist "%ZIPNAME%" del "%ZIPNAME%" >nul 2>&1
echo [ERROR] Could not compress: "%~1"
set /a FAILED+=1
exit /b 0
