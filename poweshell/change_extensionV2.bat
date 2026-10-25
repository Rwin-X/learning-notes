@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  change_extension.bat
rem  Changes the extension of every file in the script's directory.
rem  The new extension is requested interactively when the script runs.
rem
rem  Behavior:
rem    - Skips this script, the log file, hidden/system files and folders.
rem    - Skips files that already have the requested extension.
rem    - Never overwrites: if the target name already exists, the file is
rem      skipped and reported.
rem    - Writes a mapping of old and new names to the log file.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "LOGNAME=extension_change_log.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "LIST=%TEMP%\change_ext_%RANDOM%%RANDOM%.txt"
set "LOG=%CD%\%LOGNAME%"

:ask
set "NEWEXT="
set /p "NEWEXT=Enter the new extension (for example: txt, jpg, bak): "
if defined NEWEXT set "NEWEXT=%NEWEXT:"=%"

:stripdot
if not defined NEWEXT goto :emptyext
if not "%NEWEXT:~0,1%"=="." goto :extclean
set "NEWEXT=%NEWEXT:~1%"
goto :stripdot

:extclean
echo "%NEWEXT%"| findstr /r /c:"[ \\/:*?<>|]" >nul
if not errorlevel 1 goto :badext

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
echo Directory     : "%CD%"
echo Files found   : %TOTAL%
echo New extension : ".%NEWEXT%"
echo.
set "CONFIRM="
set /p "CONFIRM=Change the extension of these files? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

> "%LOG%" echo Extension change log - %DATE% %TIME%

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
:emptyext
echo The extension cannot be empty.
echo.
goto :ask

:badext
echo The extension contains invalid characters.
echo Spaces and the characters \ / : * ? ^< ^> ^| are not allowed.
echo.
goto :ask

rem ----------------------------------------------------------------------
:change
rem Files with no base name (for example ".gitignore") are skipped
if "%~n1"=="" goto :skip
rem Skip files that already have exactly this extension
if "%~x1"==".%NEWEXT%" goto :skip
set "NEWNAME=%~n1.%NEWEXT%"
rem A case-only change is allowed; otherwise never overwrite another file
if /i "%NEWNAME%"=="%~1" goto :doren
if exist "%NEWNAME%" goto :skip_exists
:doren
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
