@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  backup_files.bat
rem  Copies the files of the script's directory into a new numbered
rem  backup folder (backup_001, backup_002, ...). Existing backups are
rem  never overwritten because each run uses the next free number.
rem
rem  Behavior:
rem    - Uses robocopy, which keeps timestamps.
rem    - Optionally includes sub-folders.
rem    - Skips this script and any folder whose name starts with
rem      "backup_".
rem    - Originals are never modified or deleted.
rem ======================================================================

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"

rem --- Find the next free backup folder name ---
set /a N=0
:findnext
set /a N+=1
if %N% GTR 999 goto :toomany
set "NUM=000%N%"
set "DEST=backup_%NUM:~-3%"
if exist "%DEST%" goto :findnext

echo Directory   : "%CD%"
echo Backup into : %DEST%
echo.
set "SUB="
set /p "SUB=Include sub-folders? (Y/N): "
set "CONFIRM="
set /p "CONFIRM=Create the backup now? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

set "RCOPT=/R:1 /W:1 /NP /NFL /NDL /NJH"
if /i "%SUB%"=="Y" set "RCOPT=%RCOPT% /E"

echo.
robocopy . "%DEST%" %RCOPT% /XF "%SELF%" /XD backup_*
if errorlevel 8 goto :failed

echo.
echo Backup completed: %DEST%
goto :cleanup

:toomany
echo Too many backup folders already exist.
goto :cleanup

:failed
echo.
echo [ERROR] The backup finished with errors. Check the messages above.
goto :cleanup

:cancelled
echo Cancelled.

:cleanup
popd
pause
endlocal
exit /b 0
