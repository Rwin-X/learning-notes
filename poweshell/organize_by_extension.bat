@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  organize_by_extension.bat
rem  Moves every file in the script's directory into a sub-folder named
rem  after its extension.
rem
rem  Example:  photo.jpg -> jpg\photo.jpg
rem            notes.txt -> txt\notes.txt
rem            README    -> no_extension\README
rem
rem  Behavior:
rem    - Folders are created automatically when needed.
rem    - Never overwrites: if a file with the same name already exists in
rem      the target folder, the file is skipped and reported.
rem    - Skips this script, the log, hidden/system files and folders.
rem    - Writes a record of every move to the log file.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "LOGNAME=organize_by_extension_log.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "LIST=%TEMP%\organize_ext_%RANDOM%%RANDOM%.txt"
set "LOG=%CD%\%LOGNAME%"

rem --- Build the list of files ---
(
  for /f "eol=| delims=" %%F in ('dir /b /a-d-h-s') do (
    if /i not "%%F"=="%SELF%" if /i not "%%F"=="%LOGNAME%" echo(%%F
  )
) > "%LIST%"

set /a TOTAL=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do set /a TOTAL+=1

if %TOTAL% EQU 0 goto :nofiles

echo Directory : "%CD%"
echo Files     : %TOTAL%
echo Action    : move each file into a folder named after its extension
echo.
set "CONFIRM="
set /p "CONFIRM=Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

> "%LOG%" echo Organize by extension log - %DATE% %TIME%

set /a MOVED=0
set /a SKIPPED=0
set /a FAILED=0

for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :organize "%%F"

echo.
echo Moved   : %MOVED%
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
:organize
set "FOLDER=%~x1"
if "%~n1"=="" set "FOLDER="
if defined FOLDER set "FOLDER=%FOLDER:~1%"
if not defined FOLDER set "FOLDER=no_extension"
if not exist "%FOLDER%\" md "%FOLDER%" 2>nul
if not exist "%FOLDER%\" goto :fail
if exist "%FOLDER%\%~1" goto :skip_exists
move "%~1" "%FOLDER%\" >nul 2>&1
if errorlevel 1 goto :fail
echo "%~1"  =^>  "%FOLDER%\"
>> "%LOG%" echo "%~1" to "%FOLDER%\"
set /a MOVED+=1
exit /b 0

:skip_exists
echo [SKIP] Already exists in target folder: "%~1"
set /a SKIPPED+=1
exit /b 0

:fail
echo [ERROR] Could not move: "%~1"
set /a FAILED+=1
exit /b 0
