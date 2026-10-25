@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  normalize_names.bat
rem  Cleans up the file names in the script's directory:
rem    - optionally replaces spaces with underscores
rem    - optionally converts the letters to lowercase or uppercase
rem      (applies to the whole name, including the extension)
rem
rem  Behavior:
rem    - Never overwrites an existing file; conflicts are skipped.
rem    - Skips this script, the log, hidden/system files and folders.
rem    - Writes a mapping of old and new names to the log file.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "LOGNAME=normalize_names_log.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "LIST=%TEMP%\normalize_%RANDOM%%RANDOM%.txt"
set "LOG=%CD%\%LOGNAME%"

set "SPACES="
set /p "SPACES=Replace spaces with underscores? (Y/N): "

:askcase
set "CASEMODE="
set /p "CASEMODE=Letter case - L = lowercase, U = uppercase, N = keep as is: "
if /i "%CASEMODE%"=="L" goto :modeok
if /i "%CASEMODE%"=="U" goto :modeok
if /i "%CASEMODE%"=="N" goto :modeok
echo Enter L, U or N.
goto :askcase

:modeok
if /i not "%SPACES%"=="Y" if /i "%CASEMODE%"=="N" goto :nothing

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
echo.
set "CONFIRM="
set /p "CONFIRM=Apply the changes? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

> "%LOG%" echo Normalize names log - %DATE% %TIME%

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

:nothing
echo Nothing to do: no change was selected.
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
:change
set "NAME=%~1"
if /i "%SPACES%"=="Y" set "NAME=%NAME: =_%"
if /i "%CASEMODE%"=="L" for %%A in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") do call set "NAME=%%NAME:%%~A%%"
if /i "%CASEMODE%"=="U" for %%A in ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") do call set "NAME=%%NAME:%%~A%%"
if "%NAME%"=="%~1" goto :skip
rem A case-only change is allowed; otherwise never overwrite another file
if /i "%NAME%"=="%~1" goto :doren
if exist "%NAME%" goto :skip_exists
:doren
ren "%~1" "%NAME%" 2>nul
if errorlevel 1 goto :fail
echo "%~1"  =^>  "%NAME%"
>> "%LOG%" echo "%~1" to "%NAME%"
set /a CHANGED+=1
exit /b 0

:skip
set /a SKIPPED+=1
exit /b 0

:skip_exists
echo [SKIP] Target already exists: "%~1"  =^>  "%NAME%"
set /a SKIPPED+=1
exit /b 0

:fail
echo [ERROR] Could not rename: "%~1"
set /a FAILED+=1
exit /b 0
