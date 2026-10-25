@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  replace_in_names.bat
rem  Finds a piece of text in the file names of the script's directory
rem  and replaces it with other text. Both values are requested when the
rem  script runs.
rem
rem  Behavior:
rem    - Only the base name is changed; the extension is never touched.
rem    - The search is case-insensitive and replaces every occurrence.
rem    - Type {space} to represent a space character.
rem    - Leave the replacement empty to delete the found text.
rem    - Never overwrites an existing file; conflicts are skipped.
rem    - Skips this script, the log, hidden/system files and folders.
rem    - Writes a mapping of old and new names to the log file.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "LOGNAME=replace_in_names_log.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "LIST=%TEMP%\replace_names_%RANDOM%%RANDOM%.txt"
set "LOG=%CD%\%LOGNAME%"

:askfind
set "FIND="
set /p "FIND=Text to find in file names ({space} = a space): "
if defined FIND set "FIND=%FIND:"=%"
if not defined FIND goto :emptyfind
set "FIND=%FIND:{space}= %"
echo "%FIND%"| findstr /c:"=" /c:"*" /c:"%%" >nul
if not errorlevel 1 goto :badfind
if "%FIND:~0,1%"=="~" goto :badfind

:askrepl
set "REPL="
set /p "REPL=Replace with (empty = delete the text, {space} = a space): "
if defined REPL set "REPL=%REPL:"=%"
if defined REPL set "REPL=%REPL:{space}= %"
echo "%REPL%"| findstr /r /c:"[\\/:*?<>|]" /c:"=" /c:"%%" >nul
if not errorlevel 1 goto :badrepl

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
echo Directory    : "%CD%"
echo Files scanned: %TOTAL%
echo Find         : "%FIND%"
echo Replace with : "%REPL%"
echo Names that do not contain the text are left unchanged.
echo.
set "CONFIRM="
set /p "CONFIRM=Apply the replacement? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

> "%LOG%" echo Replace in names log - %DATE% %TIME%

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
:emptyfind
echo The text to find cannot be empty.
echo.
goto :askfind

:badfind
echo The text to find cannot contain = or * or %% and cannot start with ~
echo.
goto :askfind

:badrepl
echo The replacement cannot contain = or %% or any of \ / : * ? ^< ^> ^|
echo.
goto :askrepl

rem ----------------------------------------------------------------------
:change
set "BASE=%~n1"
set "EXT=%~x1"
if not defined BASE goto :skip
call set "NEWBASE=%%BASE:%FIND%=%REPL%%%"
if not defined NEWBASE goto :skip_empty
if "%NEWBASE%"=="%BASE%" goto :skip
set "NEWNAME=%NEWBASE%%EXT%"
rem A case-only change is allowed; otherwise never overwrite another file
if /i "%NEWNAME%"=="%~1" goto :doren
if exist "%NEWNAME%" goto :skip_exists
:doren
ren "%~1" "%NEWNAME%" 2>nul
if errorlevel 1 goto :fail
echo "%~1"  =^>  "%NEWNAME%"
>> "%LOG%" echo "%~1" to "%NEWNAME%"
set /a CHANGED+=1
exit /b 0

:skip
set /a SKIPPED+=1
exit /b 0

:skip_empty
echo [SKIP] The result would be an empty name: "%~1"
set /a SKIPPED+=1
exit /b 0

:skip_exists
echo [SKIP] Target already exists: "%~1"  =^>  "%NEWNAME%"
set /a SKIPPED+=1
exit /b 0

:fail
echo [ERROR] Could not rename: "%~1"
set /a FAILED+=1
exit /b 0
