@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  remove_empty_folders.bat
rem  Removes every empty sub-folder below the script's directory.
rem
rem  Safety:
rem    - Uses the plain "rd" command, which refuses to delete a folder
rem      that contains anything, so no file can ever be deleted.
rem    - Folders that hold only empty sub-folders are removed too; the
rem      scan repeats until nothing more can be removed.
rem    - Folders whose names start with a dot (for example .git) and
rem      folders inside them are skipped.
rem    - Hidden/system folders and reparse points (junctions, symbolic
rem      links) are skipped.
rem    - Every removed folder is written to the log file.
rem ======================================================================

set "LOGNAME=removed_folders_log.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "LIST=%TEMP%\empty_dirs_%RANDOM%%RANDOM%.txt"
set "LOG=%CD%\%LOGNAME%"

rem Base path with a trailing backslash, used to build relative paths
set "BASE=%CD%\"
if "%CD:~-1%"=="\" set "BASE=%CD%"

echo Folder : "%CD%"
echo.
echo All empty sub-folders below this folder will be removed.
echo Folders that contain any file are never touched.
echo.
set "CONFIRM="
set /p "CONFIRM=Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

> "%LOG%" echo Removed empty folders - %DATE% %TIME%
set /a REMOVED=0

:pass
set /a PASS_REMOVED=0
(
  for /f "eol=| delims=" %%D in ('dir /b /s /ad-h-s-l') do echo(%%D
) > "%LIST%"
for /f "usebackq eol=| delims=" %%D in ("%LIST%") do call :try "%%D"
if %PASS_REMOVED% GTR 0 goto :pass

echo.
echo Removed %REMOVED% empty folder(s).
echo Log: %LOGNAME%
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
:try
set "P=%~1"
call set "REL=%%P:%BASE%=%%"
rem Skip dot-folders at the top level and anywhere deeper
if "%REL:~0,1%"=="." exit /b 0
if not "%REL:\.=%"=="%REL%" exit /b 0
rem rd without /s only succeeds when the folder is completely empty
rd "%~1" 2>nul
if errorlevel 1 exit /b 0
echo Removed: "%~1"
>> "%LOG%" echo "%~1"
set /a REMOVED+=1
set /a PASS_REMOVED+=1
exit /b 0
