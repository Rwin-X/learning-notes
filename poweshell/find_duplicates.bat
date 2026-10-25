@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  find_duplicates.bat
rem  Finds files with identical content (same SHA256 hash) in the
rem  script's directory. Files whose size is unique are skipped without
rem  hashing, which keeps the scan fast.
rem
rem  Behavior:
rem    - Always writes a report: duplicates_report.txt.
rem    - Optionally moves the extra copies into a folder named
rem      "duplicates". The first file found in each group stays in place.
rem      Nothing is ever deleted.
rem    - Scans only the top level of the directory.
rem    - Skips this script, the report, hidden/system files, empty files.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "REPORTNAME=duplicates_report.txt"
set "DUPDIR=duplicates"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "REPORT=%CD%\%REPORTNAME%"
set "LIST=%TEMP%\dups_list_%RANDOM%%RANDOM%.txt"
set "TMPOUT=%TEMP%\dups_out_%RANDOM%%RANDOM%.txt"

rem --- Build the list of files ---
(
  for /f "eol=| delims=" %%F in ('dir /b /a-d-h-s') do (
    if /i not "%%F"=="%SELF%" if /i not "%%F"=="%REPORTNAME%" echo(%%F
  )
) > "%LIST%"

set /a TOTAL=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do set /a TOTAL+=1

if %TOTAL% EQU 0 goto :nofiles

echo Directory : "%CD%"
echo Files     : %TOTAL%
echo.
set "MOVE="
set /p "MOVE=Move duplicate copies into the %DUPDIR% folder? (Y/N, N = report only): "
echo.

> "%REPORT%" echo Duplicate files report - %DATE% %TIME%

rem --- Pass 1: count how many files share each size ---
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :sizecount "%%F"

rem --- Pass 2: hash only files whose size is shared with another file ---
set /a DUPS=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :check "%%F"

echo.
echo Duplicate files found: %DUPS%
echo Report: %REPORTNAME%
goto :cleanup

:nofiles
echo No files found in this directory.

:cleanup
if exist "%LIST%" del "%LIST%" >nul 2>&1
if exist "%TMPOUT%" del "%TMPOUT%" >nul 2>&1
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:sizecount
if "%~z1"=="0" exit /b 0
if defined S_%~z1 goto :sizeadd
set "S_%~z1=1"
exit /b 0

:sizeadd
set /a S_%~z1+=1
exit /b 0

rem ----------------------------------------------------------------------
:check
if "%~z1"=="0" exit /b 0
call set "CNT=%%S_%~z1%%"
if "%CNT%"=="1" exit /b 0
set "HASH="
certutil -hashfile "%~1" SHA256 > "%TMPOUT%" 2>&1
if errorlevel 1 goto :check_fail
for /f "usebackq skip=1 eol=| delims=" %%H in ("%TMPOUT%") do if not defined HASH set "HASH=%%H"
if not defined HASH goto :check_fail
set "HASH=%HASH: =%"
if defined H_%HASH% goto :dup
set "H_%HASH%=%~1"
exit /b 0

:check_fail
echo [ERROR] Could not hash: "%~1"
exit /b 0

:dup
call set "FIRST=%%H_%HASH%%%"
echo [DUPLICATE] "%~1"  ==  "%FIRST%"
>> "%REPORT%" echo "%~1" is a duplicate of "%FIRST%"
set /a DUPS+=1
if /i not "%MOVE%"=="Y" exit /b 0
if not exist "%DUPDIR%\" md "%DUPDIR%" 2>nul
if exist "%DUPDIR%\%~1" goto :move_exists
move "%~1" "%DUPDIR%\" >nul 2>&1
if errorlevel 1 echo [ERROR] Could not move: "%~1"
exit /b 0

:move_exists
echo [SKIP] A file with this name already exists in the duplicates folder: "%~1"
exit /b 0
