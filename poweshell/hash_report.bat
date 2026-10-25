@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  hash_report.bat
rem  Computes a cryptographic hash for every file in the script's
rem  directory and saves the result to a report file. The algorithm is
rem  requested when the script runs.
rem
rem  Supported algorithms: MD5, SHA1, SHA256, SHA512 (uses certutil,
rem  which is built into Windows).
rem
rem  Report format (one line per file, same as the Linux tools):
rem      <hash>  <file name>
rem  so the report can be verified later with sha256sum -c, sha1sum -c,
rem  md5sum -c or sha512sum -c.
rem
rem  Behavior:
rem    - The report is named hash_report_<ALGORITHM>.txt and is replaced
rem      on every run.
rem    - Skips this script, the report, hidden/system files and folders.
rem ======================================================================

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"

:askalgo
set "ALGO="
set /p "ALGO=Hash algorithm (MD5, SHA1, SHA256, SHA512) [default: SHA256]: "
if not defined ALGO set "ALGO=SHA256"
set "ALGO=%ALGO:"=%"
set "ALGO=%ALGO:-=%"
set "VALID="
for %%A in (MD5 SHA1 SHA256 SHA512) do if /i "%ALGO%"=="%%A" set "VALID=%%A"
if not defined VALID goto :badalgo
set "ALGO=%VALID%"

set "REPORTNAME=hash_report_%ALGO%.txt"
set "REPORT=%CD%\%REPORTNAME%"
set "LIST=%TEMP%\hash_list_%RANDOM%%RANDOM%.txt"
set "TMPOUT=%TEMP%\hash_out_%RANDOM%%RANDOM%.txt"

rem --- Build the list of files ---
(
  for /f "eol=| delims=" %%F in ('dir /b /a-d-h-s') do (
    if /i not "%%F"=="%SELF%" if /i not "%%F"=="%REPORTNAME%" echo(%%F
  )
) > "%LIST%"

set /a TOTAL=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do set /a TOTAL+=1

if %TOTAL% EQU 0 goto :nofiles

echo.
echo Directory : "%CD%"
echo Files     : %TOTAL%
echo Algorithm : %ALGO%
echo Report    : %REPORTNAME%
echo.

type nul > "%REPORT%"

set /a DONE=0
set /a FAILED=0

for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :hash "%%F"

echo.
echo Hashed : %DONE%
echo Failed : %FAILED%
echo Report : %REPORTNAME%
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
:badalgo
echo Unsupported algorithm. Choose one of: MD5, SHA1, SHA256, SHA512
echo.
goto :askalgo

rem ----------------------------------------------------------------------
:hash
set "HASH="
certutil -hashfile "%~1" %ALGO% > "%TMPOUT%" 2>&1
if errorlevel 1 goto :hash_fail
for /f "usebackq skip=1 eol=| delims=" %%H in ("%TMPOUT%") do if not defined HASH set "HASH=%%H"
if not defined HASH goto :hash_fail
set "HASH=%HASH: =%"
set "LINE=%HASH%  %~1"
rem Delayed expansion is enabled only for the write, so names containing
rem special characters are written safely.
setlocal EnableDelayedExpansion
>> "%REPORT%" echo(!LINE!
endlocal
echo [OK] "%~1"
set /a DONE+=1
exit /b 0

:hash_fail
echo [ERROR] Could not hash: "%~1"
set /a FAILED+=1
exit /b 0
