@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem ======================================================================
rem  sort_rename.bat
rem  Renames all files in the script's directory to sequential numbers,
rem  ordered by last-modified date (oldest first = 001). The original
rem  file extension is preserved.
rem
rem  Configuration:
rem    KEEP_NAME=0  ->  001.jpg
rem    KEEP_NAME=1  ->  001_originalname.jpg
rem ======================================================================

set "KEEP_NAME=0"
set "LOGNAME=rename_log.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "LIST=%TEMP%\sort_rename_%RANDOM%%RANDOM%.txt"
set "LOG=%CD%\%LOGNAME%"

rem --- Build the file list sorted by last-written time, oldest first ---
(
  for /f "delims=" %%F in ('dir /b /a-d-h-s /o:d /t:w') do (
    if /i not "%%F"=="%SELF%" if /i not "%%F"=="%LOGNAME%" echo %%F
  )
) > "%LIST%"

set /a TOTAL=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do set /a TOTAL+=1

if %TOTAL% EQU 0 (
  echo No files to rename in: %CD%
  goto :cleanup
)

rem --- Number width: at least 3 digits, more for large file counts ---
set "WIDTH=3"
if %TOTAL% GTR 999 set "WIDTH=4"
if %TOTAL% GTR 9999 set "WIDTH=5"

echo Directory : %CD%
echo Files     : %TOTAL%
echo Order     : oldest modification date first
echo.
set "CONFIRM="
set /p "CONFIRM=Rename these files? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
  echo Cancelled.
  goto :cleanup
)

echo Rename log - %DATE% %TIME%> "%LOG%"

rem --- Pass 1: move every file to a unique temporary name ---
rem     This avoids collisions with files that already have numeric names.
set /a COUNT=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :pass1 "%%F"

rem --- Pass 2: temporary names to final names ---
set /a COUNT=0
for /f "usebackq eol=| delims=" %%F in ("%LIST%") do call :pass2 "%%F"

echo.
echo Done. Mapping saved to %LOGNAME%

:cleanup
if exist "%LIST%" del "%LIST%" >nul 2>&1
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:fmt
set "NUM=00000%COUNT%"
call set "NUM=%%NUM:~-%WIDTH%%%"
exit /b 0

:pass1
set /a COUNT+=1
call :fmt
ren "%~1" "__tmp_%NUM%__%~x1" 2>nul
if errorlevel 1 echo [ERROR] Could not rename: %~1
exit /b 0

:pass2
set /a COUNT+=1
call :fmt
if "%KEEP_NAME%"=="1" (
  set "FINAL=%NUM%_%~n1%~x1"
) else (
  set "FINAL=%NUM%%~x1"
)
ren "__tmp_%NUM%__%~x1" "%FINAL%" 2>nul
if errorlevel 1 (
  echo [ERROR] Could not finalize: %~1
) else (
  echo %~1  =^>  %FINAL%
  >> "%LOG%" echo "%~1" to "%FINAL%"
)
exit /b 0
