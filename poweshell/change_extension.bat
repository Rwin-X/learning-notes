@echo off
setlocal EnableExtensions DisableDelayedExpansion

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
rem ======================================================================

set "LOGNAME=extension_change_log.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "LIST=%TEMP%\change_ext_%RANDOM%%RANDOM%.txt"
set "LOG=%CD%\%LOGNAME%"

rem --- Ask for the new extension ---
:ask
set "NEWEXT="
set /p "NEWEXT=Enter the new extension (for example: txt, jpg, bak): "

rem Remove quotes and any leading dots
if defined NEWEXT set "NEWEXT=%NEWEXT:"=%"
:stripdot
if defined NEWEXT if "%NEWEXT:~0,1%"=="." (
  set "NEWEXT=%NEWEXT:~1%"
  goto :stripdot
)

if not defined NEWEXT (
  echo The extension cannot be empty.
  echo.
  goto :ask
)

rem Reject characters that are not allowed in file names, and spaces
echo "%NEWEXT%"| findstr /r /c:"[ \\/:*?<>|]" >nul
if not errorlevel 1 (
  echo The extension contains invalid characters.
  echo.
  goto :ask
)

rem --- Build the list of files ---
(
  for /f "delims=" %%F in ('dir /b /a-d-h-s') do (
    if /i not "%%F"=="%SELF%" if /i not "%%F"=="%LOGNAME%" echo %%F
  )
) > "%LIST%"

set /a TOTAL=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do set /a TOTAL+=1

if %TOTAL% EQU 0 (
  echo No files found in: %CD%
  goto :cleanup
)

echo.
echo Directory     : %CD%
echo Files found   : %TOTAL%
echo New extension : .%NEWEXT%
echo.
set "CONFIRM="
set /p "CONFIRM=Change the extension of these files? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
  echo Cancelled.
  goto :cleanup
)

echo Extension change log - %DATE% %TIME%> "%LOG%"

set /a CHANGED=0
set /a SKIPPED=0
set /a FAILED=0

for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :change "%%F"

echo.
echo Changed : %CHANGED%
echo Skipped : %SKIPPED%
echo Failed  : %FAILED%
echo Log     : %LOGNAME%

:cleanup
if exist "%LIST%" del "%LIST%" >nul 2>&1
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:change
rem Files with no base name (for example ".gitignore") are skipped
if "%~n1"=="" (
  echo [SKIP] No base name: %~1
  set /a SKIPPED+=1
  exit /b 0
)

rem Skip files that already have exactly this extension
if "%~x1"==".%NEWEXT%" (
  set /a SKIPPED+=1
  exit /b 0
)

set "NEWNAME=%~n1.%NEWEXT%"

rem Do not overwrite another file (a case-only change is allowed)
if exist "%NEWNAME%" if /i not "%~1"=="%NEWNAME%" (
  echo [SKIP] Target already exists: %~1  =^>  %NEWNAME%
  set /a SKIPPED+=1
  exit /b 0
)

ren "%~1" "%NEWNAME%" 2>nul
if errorlevel 1 (
  echo [ERROR] Could not rename: %~1
  set /a FAILED+=1
) else (
  echo %~1  =^>  %NEWNAME%
  >> "%LOG%" echo "%~1" to "%NEWNAME%"
  set /a CHANGED+=1
)
exit /b 0
