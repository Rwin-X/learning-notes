@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  add_prefix_suffix.bat
rem  Adds a prefix and/or a suffix to the name of every file in the
rem  script's directory. Both values are requested when the script runs.
rem
rem  Example:  prefix "2026_"  suffix "_final"
rem            report.pdf  ->  2026_report_final.pdf
rem
rem  Behavior:
rem    - The suffix is inserted before the extension.
rem    - Type {space} to represent a space character.
rem    - Never overwrites an existing file; conflicts are skipped.
rem    - Skips this script, the log, hidden/system files and folders.
rem    - Writes a mapping of old and new names to the log file.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "LOGNAME=prefix_suffix_log.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "LIST=%TEMP%\prefix_suffix_%RANDOM%%RANDOM%.txt"
set "LOG=%CD%\%LOGNAME%"

:ask
set "PREFIX="
set "SUFFIX="
set /p "PREFIX=Prefix to add (empty = none, {space} = a space): "
set /p "SUFFIX=Suffix to add before the extension (empty = none): "
if defined PREFIX set "PREFIX=%PREFIX:"=%"
if defined SUFFIX set "SUFFIX=%SUFFIX:"=%"
if defined PREFIX set "PREFIX=%PREFIX:{space}= %"
if defined SUFFIX set "SUFFIX=%SUFFIX:{space}= %"
if not defined PREFIX if not defined SUFFIX goto :nothing
echo "%PREFIX%%SUFFIX%"| findstr /r /c:"[\\/:*?<>|]" >nul
if not errorlevel 1 goto :badchars

rem --- Build the list of files ---
(
  for /f "eol=| delims=" %%F in ('dir /b /a-d-h-s') do (
    if /i not "%%F"=="%SELF%" if /i not "%%F"=="%LOGNAME%" echo(%%F
  )
) > "%LIST%"

set /a TOTAL=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do set /a TOTAL+=1

if %TOTAL% EQU 0 goto :nofiles

echo.
echo Directory : "%CD%"
echo Files     : %TOTAL%
echo Prefix    : "%PREFIX%"
echo Suffix    : "%SUFFIX%"
echo.
set "CONFIRM="
set /p "CONFIRM=Rename these files? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

> "%LOG%" echo Prefix and suffix log - %DATE% %TIME%

set /a CHANGED=0
set /a SKIPPED=0
set /a FAILED=0

for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :change "%%F"

echo.
echo Changed : %CHANGED%
echo Skipped : %SKIPPED%
echo Failed  : %FAILED%
echo Log     : %LOGNAME%
goto :cleanup

:nofiles
echo No files found in this directory.
goto :cleanup

:cancelled
echo Cancelled.

:cleanup
if exist "%LIST%" del "%LIST%" >nul 2>&1
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:nothing
echo Enter at least a prefix or a suffix.
echo.
goto :ask

:badchars
echo The values contain invalid characters.
echo The characters \ / : * ? ^< ^> ^| are not allowed in file names.
echo.
goto :ask

rem ----------------------------------------------------------------------
:change
rem Files with no base name (for example ".gitignore") are skipped
if "%~n1"=="" goto :skip
set "NEWNAME=%PREFIX%%~n1%SUFFIX%%~x1"
if exist "%NEWNAME%" goto :skip_exists
ren "%~1" "%NEWNAME%" 2>nul
if errorlevel 1 goto :fail
echo "%~1"  =^>  "%NEWNAME%"
>> "%LOG%" echo "%~1" to "%NEWNAME%"
set /a CHANGED+=1
exit /b 0

:skip
set /a SKIPPED+=1
exit /b 0

:skip_exists
echo [SKIP] Target already exists: "%~1"  =^>  "%NEWNAME%"
set /a SKIPPED+=1
exit /b 0

:fail
echo [ERROR] Could not rename: "%~1"
set /a FAILED+=1
exit /b 0
