@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  integrity_monitor.bat
rem  File integrity monitor for the script's directory and all of its
rem  sub-folders. Works fully offline.
rem
rem  Option 1 - Create baseline:
rem    Records the SHA256 hash of every file in integrity_baseline.txt.
rem  Option 2 - Verify:
rem    Hashes the files again and compares them with the baseline.
rem    Reports MODIFIED, NEW and REMOVED files in integrity_report.txt.
rem
rem  Behavior:
rem    - Read-only: no file is changed, moved or deleted.
rem    - Skips this script, the baseline, the report, and hidden/system
rem      files. Paths that contain an equals sign are skipped.
rem    - Keep the baseline somewhere safe if you need to trust it; an
rem      attacker who can edit your files can edit the baseline too.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "ALGO=SHA256"
set "BASENAME=integrity_baseline.txt"
set "REPORTNAME=integrity_report.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "BASELINE=%CD%\%BASENAME%"
set "REPORT=%CD%\%REPORTNAME%"
set "LIST=%TEMP%\integ_list_%RANDOM%%RANDOM%.txt"
set "TMPOUT=%TEMP%\integ_out_%RANDOM%%RANDOM%.txt"
set "BASE=%CD%\"
if "%CD:~-1%"=="\" set "BASE=%CD%"

echo Directory : "%CD%"
echo Algorithm : %ALGO% (all sub-folders are included)
echo.
echo   1  Create a new baseline (snapshot of the current state)
echo   2  Verify the current state against the baseline
echo.
set "CHOICE="
set /p "CHOICE=Select an option (1 or 2): "
if "%CHOICE%"=="1" goto :create
if "%CHOICE%"=="2" goto :verify
echo Invalid choice.
goto :cleanup

rem ----------------------------------------------------------------------
:create
if not exist "%BASELINE%" goto :create_go
set "OW="
set /p "OW=A baseline already exists. Replace it? (Y/N): "
if /i not "%OW%"=="Y" goto :cancelled

:create_go
call :buildlist
if %TOTAL% EQU 0 goto :nofiles
echo.
echo Hashing %TOTAL% file(s). This can take a while for large files.
type nul > "%BASELINE%"
set /a DONE=0
set /a SKIPPED=0
set /a FAILED=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :snap "%%F"
echo.
echo Baseline saved : %BASENAME%
echo Files recorded : %DONE%
echo Skipped        : %SKIPPED%
echo Failed         : %FAILED%
goto :cleanup

rem ----------------------------------------------------------------------
:verify
if not exist "%BASELINE%" goto :nobaseline
call :buildlist
set /a BCOUNT=0
for /f "usebackq tokens=1,* eol=: delims=|" %%A in ("%BASELINE%") do call :loadline "%%A" "%%B"
echo.
echo Baseline entries: %BCOUNT%   Files found now: %TOTAL%
echo.

> "%REPORT%" echo Integrity report - %DATE% %TIME%
set /a OKN=0
set /a MODN=0
set /a NEWN=0
set /a REMN=0
set /a FAILED=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :compare "%%F"
for /f "usebackq tokens=1,* eol=: delims=|" %%A in ("%BASELINE%") do call :missing "%%B"

set /a CHANGES=MODN+NEWN+REMN
echo.
echo Unchanged : %OKN%
echo Modified  : %MODN%
echo New       : %NEWN%
echo Removed   : %REMN%
echo Failed    : %FAILED%
echo Report    : %REPORTNAME%
echo.
if %CHANGES% EQU 0 (
  echo Result: no changes detected.
) else (
  echo Result: CHANGES DETECTED.
)
goto :cleanup

:nobaseline
echo No baseline found. Run option 1 first.
goto :cleanup

:nofiles
echo No files found.
goto :cleanup

:cancelled
echo Cancelled.

:cleanup
if exist "%LIST%" del "%LIST%" >nul 2>&1
if exist "%TMPOUT%" del "%TMPOUT%" >nul 2>&1
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:buildlist
(
  for /f "eol=| delims=" %%F in ('dir /b /s /a-d-h-s') do echo(%%F
) > "%LIST%"
set /a TOTAL=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do set /a TOTAL+=1
exit /b 0

:gethash
set "HASH="
certutil -hashfile "%~1" %ALGO% > "%TMPOUT%" 2>&1
if errorlevel 1 exit /b 0
for /f "usebackq skip=1 eol=| delims=" %%H in ("%TMPOUT%") do if not defined HASH set "HASH=%%H"
if defined HASH set "HASH=%HASH: =%"
exit /b 0

:writeline
setlocal EnableDelayedExpansion
>> "%~1" echo(!LINE!
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:snap
if /i "%~nx1"=="%SELF%" exit /b 0
if /i "%~nx1"=="%BASENAME%" exit /b 0
if /i "%~nx1"=="%REPORTNAME%" exit /b 0
set "P=%~1"
call set "REL=%%P:%BASE%=%%"
echo "%REL%"| findstr /c:"=" >nul
if not errorlevel 1 goto :snap_skip
call :gethash "%~1"
if not defined HASH goto :snap_fail
set "LINE=%HASH%|%REL%"
call :writeline "%BASELINE%"
set /a DONE+=1
exit /b 0

:snap_skip
set /a SKIPPED+=1
exit /b 0

:snap_fail
echo [ERROR] Could not hash: "%REL%"
set /a FAILED+=1
exit /b 0

rem ----------------------------------------------------------------------
:loadline
set "B_%~2=%~1"
set /a BCOUNT+=1
exit /b 0

rem ----------------------------------------------------------------------
:compare
if /i "%~nx1"=="%SELF%" exit /b 0
if /i "%~nx1"=="%BASENAME%" exit /b 0
if /i "%~nx1"=="%REPORTNAME%" exit /b 0
set "P=%~1"
call set "REL=%%P:%BASE%=%%"
echo "%REL%"| findstr /c:"=" >nul
if not errorlevel 1 exit /b 0
set "S_%REL%=1"
call :gethash "%~1"
if not defined HASH goto :cmp_fail
call set "OLD=%%B_%REL%%%"
if not defined OLD goto :cmp_new
if /i "%OLD%"=="%HASH%" goto :cmp_ok
echo [MODIFIED] "%REL%"
>> "%REPORT%" echo MODIFIED  "%REL%"
set /a MODN+=1
exit /b 0

:cmp_ok
set /a OKN+=1
exit /b 0

:cmp_new
echo [NEW] "%REL%"
>> "%REPORT%" echo NEW       "%REL%"
set /a NEWN+=1
exit /b 0

:cmp_fail
echo [ERROR] Could not hash: "%REL%"
set /a FAILED+=1
exit /b 0

rem ----------------------------------------------------------------------
:missing
if "%~1"=="" exit /b 0
call set "SEEN=%%S_%~1%%"
if defined SEEN exit /b 0
echo [REMOVED] "%~1"
>> "%REPORT%" echo REMOVED   "%~1"
set /a REMN+=1
exit /b 0
