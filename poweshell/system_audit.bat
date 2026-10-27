@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  system_audit.bat
rem  Local security audit snapshots. Works fully offline: it reads only
rem  local system data and uses no network commands.
rem
rem  Option 1 - Create snapshot:
rem    Collects local information into audit_reports\audit_001.txt,
rem    audit_002.txt, ... (the next free number is used each time):
rem      - Windows version and current user
rem      - local user accounts and the local Administrators group
rem      - privileges of the current user and UAC settings
rem      - autorun entries (registry and startup folders)
rem      - scheduled task names
rem      - active service names and running process names
rem      - installed software names (from the registry)
rem  Option 2 - Compare:
rem    Compares the two most recent snapshots and shows what changed.
rem    The first line of each snapshot is a timestamp, so it will always
rem    appear as a difference.
rem
rem  Notes:
rem    - Read-only: nothing on the system is changed.
rem    - Some data needs an administrator console. Run every snapshot
rem      the same way (always elevated, or always not) so that the
rem      comparison is meaningful.
rem    - If the Administrators group has a localized name on your
rem      system, that section will show an error message.
rem ======================================================================

set "OUTDIR=audit_reports"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

echo Directory : "%CD%"
echo.
echo   1  Create a new audit snapshot
echo   2  Compare the two most recent snapshots
echo.
set "CHOICE="
set /p "CHOICE=Select an option (1 or 2): "
if "%CHOICE%"=="1" goto :snapshot
if "%CHOICE%"=="2" goto :compare
echo Invalid choice.
goto :end

rem ----------------------------------------------------------------------
:snapshot
if not exist "%OUTDIR%\" md "%OUTDIR%" 2>nul
if not exist "%OUTDIR%\" goto :mkfail

set /a N=0
:findnext
set /a N+=1
if %N% GTR 999 goto :toomany
set "NUM=000%N%"
set "OUT=%OUTDIR%\audit_%NUM:~-3%.txt"
if exist "%OUT%" goto :findnext

set "TMPA=%TEMP%\audit_tmp_%RANDOM%%RANDOM%.txt"

echo.
echo Collecting local system information. This can take a minute...

> "%OUT%" echo Local system audit snapshot - %DATE% %TIME%

call :head "Host"
>> "%OUT%" echo Computer name: %COMPUTERNAME%
>> "%OUT%" echo Current user : %USERNAME%
ver >> "%OUT%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName >> "%OUT%" 2>&1
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild >> "%OUT%" 2>&1
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion >> "%OUT%" 2>&1

call :head "Local user accounts"
net user >> "%OUT%" 2>&1

call :head "Local Administrators group"
net localgroup Administrators >> "%OUT%" 2>&1

call :head "Privileges of the current user"
whoami /priv >> "%OUT%" 2>&1

call :head "UAC settings"
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA >> "%OUT%" 2>&1
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin >> "%OUT%" 2>&1

call :head "Autorun entries (registry)"
for %%K in ("HKLM\Software\Microsoft\Windows\CurrentVersion\Run" "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce") do reg query %%K >> "%OUT%" 2>&1

call :head "Startup folders"
dir /b "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" >> "%OUT%" 2>&1
dir /b "%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp" >> "%OUT%" 2>&1

call :head "Scheduled tasks (names)"
type nul > "%TMPA%"
for /f "usebackq tokens=1 delims=," %%T in (`schtasks /query /fo CSV /nh 2^>nul`) do >> "%TMPA%" echo %%T
sort "%TMPA%" >> "%OUT%"

call :head "Active services (names)"
sc query type= service state= active 2>nul | findstr /b /c:"SERVICE_NAME" >> "%OUT%"

call :head "Running processes (image names)"
type nul > "%TMPA%"
for /f "usebackq tokens=1 delims=," %%P in (`tasklist /fo csv /nh`) do >> "%TMPA%" echo %%P
sort "%TMPA%" >> "%OUT%"

call :head "Installed software (registry display names)"
for %%K in ("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") do reg query %%K /s /v DisplayName 2>nul | findstr /c:"DisplayName" >> "%OUT%"

if exist "%TMPA%" del "%TMPA%" >nul 2>&1

echo.
echo Snapshot saved: %OUT%
goto :end

:mkfail
echo Could not create the folder %OUTDIR%.
goto :end

:toomany
echo Too many snapshots already exist.
goto :end

rem ----------------------------------------------------------------------
:compare
set "LAST="
set "PREV="
for /l %%I in (1,1,999) do call :probe %%I
if not defined PREV goto :needtwo

set "DIFFFILE=%OUTDIR%\audit_diff.txt"
fc "%PREV%" "%LAST%" > "%DIFFFILE%"
if errorlevel 2 goto :fcfail
if errorlevel 1 goto :hasdiff
echo.
echo No differences between the two snapshots.
goto :end

:hasdiff
echo.
echo Comparing "%PREV%" with "%LAST%"
echo.
type "%DIFFFILE%"
echo.
echo Saved to: %DIFFFILE%
goto :end

:needtwo
echo At least two snapshots are required. Create another snapshot first.
goto :end

:fcfail
echo The comparison failed.

:end
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:head
>> "%OUT%" echo.
>> "%OUT%" echo ===== %~1 =====
exit /b 0

:probe
set "NUM=000%1"
set "F=%OUTDIR%\audit_%NUM:~-3%.txt"
if not exist "%F%" exit /b 0
set "PREV=%LAST%"
set "LAST=%F%"
exit /b 0
