@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  compare_folders.bat
rem  Compares the script's directory with another folder, including all
rem  sub-folders, and reports the differences. Works fully offline.
rem
rem  Method:
rem    - Files are matched by relative path.
rem    - If the sizes differ, the files are different.
rem    - If the sizes are equal, the SHA256 hashes are compared.
rem
rem  Report (compare_report.txt):
rem    ONLY-IN-THIS   exists only in the script's directory
rem    ONLY-IN-OTHER  exists only in the other folder
rem    DIFFERENT      exists in both but the content differs
rem
rem  Behavior:
rem    - Read-only: no file is changed, moved or deleted.
rem    - Skips this script, the report, and hidden/system files. Paths
rem      that contain an equals sign are skipped.
rem    - Do not compare a folder with one of its own sub-folders.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "REPORTNAME=compare_report.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "REPORT=%CD%\%REPORTNAME%"
set "LISTA=%TEMP%\cmp_a_%RANDOM%%RANDOM%.txt"
set "LISTB=%TEMP%\cmp_b_%RANDOM%%RANDOM%.txt"
set "TMPOUT=%TEMP%\cmp_out_%RANDOM%%RANDOM%.txt"
set "BASEA=%CD%\"
if "%CD:~-1%"=="\" set "BASEA=%CD%"

echo This folder : "%CD%"
echo.

:askdir
set "DIRB="
set /p "DIRB=Path of the folder to compare with: "
if defined DIRB set "DIRB=%DIRB:"=%"
if not defined DIRB goto :emptydir
if not exist "%DIRB%\" goto :baddir
for %%P in ("%DIRB%") do set "DIRB=%%~fP"
if "%DIRB:~-1%"=="\" if not "%DIRB:~-2%"==":\" set "DIRB=%DIRB:~0,-1%"
if /i "%DIRB%"=="%CD%" goto :samedir
set "BASEB=%DIRB%\"
if "%DIRB:~-1%"=="\" set "BASEB=%DIRB%"

rem --- Build both file lists ---
(
  for /f "eol=| delims=" %%F in ('dir /b /s /a-d-h-s') do echo(%%F
) > "%LISTA%"
(
  for /f "eol=| delims=" %%F in ('dir /b /s /a-d-h-s "%DIRB%"') do echo(%%F
) > "%LISTB%"

set /a TOTALA=0
set /a TOTALB=0
for /f "usebackq eol=| delims=" %%F in ("%LISTA%") do set /a TOTALA+=1
for /f "usebackq eol=| delims=" %%F in ("%LISTB%") do set /a TOTALB+=1

echo.
echo Other folder : "%DIRB%"
echo Files here   : %TOTALA%
echo Files there  : %TOTALB%
echo.
echo Files of equal size are compared by hash, which can take a while.
set "CONFIRM="
set /p "CONFIRM=Start the comparison? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

> "%REPORT%" echo Folder comparison report - %DATE% %TIME%
>> "%REPORT%" echo This folder  : "%CD%"
>> "%REPORT%" echo Other folder : "%DIRB%"
>> "%REPORT%" echo.

set /a SAME=0
set /a DIFF=0
set /a ONLYA=0
set /a ONLYB=0
set /a FAILED=0
set /a SKIPPED=0

echo.
rem --- Pass 1: remember every file of this folder with its size ---
for /f "usebackq eol=| delims=" %%F in ("%LISTA%") do call :loadA "%%F"

rem --- Pass 2: check every file of the other folder ---
for /f "usebackq eol=| delims=" %%F in ("%LISTB%") do call :checkB "%%F"

rem --- Pass 3: files that exist only in this folder ---
for /f "usebackq eol=| delims=" %%F in ("%LISTA%") do call :onlyA "%%F"

echo.
echo Identical      : %SAME%
echo Different      : %DIFF%
echo Only in this   : %ONLYA%
echo Only in other  : %ONLYB%
echo Skipped        : %SKIPPED%
echo Failed         : %FAILED%
echo Report         : %REPORTNAME%
goto :cleanup

:emptydir
echo The path cannot be empty.
echo.
goto :askdir

:baddir
echo That folder does not exist.
echo.
goto :askdir

:samedir
echo Choose a different folder than this one.
echo.
goto :askdir

:cancelled
echo Cancelled.

:cleanup
if exist "%LISTA%" del "%LISTA%" >nul 2>&1
if exist "%LISTB%" del "%LISTB%" >nul 2>&1
if exist "%TMPOUT%" del "%TMPOUT%" >nul 2>&1
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:rel
rem Usage: call :rel "<base path ending with backslash>" "<full path>"
set "P=%~2"
set "BS=%~1"
call set "REL=%%P:%BS%=%%"
exit /b 0

:gethash
set "HASH="
certutil -hashfile "%~1" SHA256 > "%TMPOUT%" 2>&1
if errorlevel 1 exit /b 0
for /f "usebackq skip=1 eol=| delims=" %%H in ("%TMPOUT%") do if not defined HASH set "HASH=%%H"
if defined HASH set "HASH=%HASH: =%"
exit /b 0

rem ----------------------------------------------------------------------
:loadA
if /i "%~nx1"=="%SELF%" exit /b 0
if /i "%~nx1"=="%REPORTNAME%" exit /b 0
call :rel "%BASEA%" "%~1"
echo "%REL%"| findstr /c:"=" >nul
if not errorlevel 1 goto :skiprel
set "A_%REL%=%~z1"
exit /b 0

:skiprel
set /a SKIPPED+=1
exit /b 0

rem ----------------------------------------------------------------------
:checkB
call :rel "%BASEB%" "%~1"
echo "%REL%"| findstr /c:"=" >nul
if not errorlevel 1 goto :skiprel
call set "SA=%%A_%REL%%%"
if not defined SA goto :onlyinB
set "S_%REL%=1"
if not "%SA%"=="%~z1" goto :differs
if "%SA%"=="0" goto :same
call :gethash "%BASEA%%REL%"
set "HA=%HASH%"
call :gethash "%~1"
if not defined HA goto :cmpfail
if not defined HASH goto :cmpfail
if /i "%HA%"=="%HASH%" goto :same

:differs
echo [DIFFERENT] "%REL%"
>> "%REPORT%" echo DIFFERENT      "%REL%"
set /a DIFF+=1
exit /b 0

:same
set /a SAME+=1
exit /b 0

:onlyinB
echo [ONLY IN OTHER] "%REL%"
>> "%REPORT%" echo ONLY-IN-OTHER  "%REL%"
set /a ONLYB+=1
exit /b 0

:cmpfail
echo [ERROR] Could not hash: "%REL%"
set /a FAILED+=1
exit /b 0

rem ----------------------------------------------------------------------
:onlyA
if /i "%~nx1"=="%SELF%" exit /b 0
if /i "%~nx1"=="%REPORTNAME%" exit /b 0
call :rel "%BASEA%" "%~1"
echo "%REL%"| findstr /c:"=" >nul
if not errorlevel 1 exit /b 0
call set "SEEN=%%S_%REL%%%"
if defined SEEN exit /b 0
echo [ONLY IN THIS] "%REL%"
>> "%REPORT%" echo ONLY-IN-THIS   "%REL%"
set /a ONLYA+=1
exit /b 0
