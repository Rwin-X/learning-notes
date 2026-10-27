@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  archive_old_files.bat
rem  Moves files that have not been modified for a given number of days
rem  into a new numbered archive folder (archive_001, archive_002, ...).
rem  Works fully offline.
rem
rem  Behavior:
rem    - Shows a preview of the files that would be moved and asks for
rem      confirmation before moving anything.
rem    - Each run uses a new archive folder, so nothing is overwritten.
rem    - Optionally includes sub-folders; the folder structure is kept
rem      inside the archive. Empty source folders are left in place
rem      (remove_empty_folders.bat can clean them up).
rem    - Skips this script, folders named archive_* and backup_*, and
rem      the .git folder.
rem    - Uses robocopy (built into Windows). Files are moved, not
rem      deleted, so they can be moved back by hand.
rem ======================================================================

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"

:askdays
set "DAYS="
set /p "DAYS=Archive files not modified for at least how many days? (1-1899): "
if defined DAYS set "DAYS=%DAYS:"=%"
if not defined DAYS goto :baddays
for /f "delims=0123456789" %%X in ("%DAYS%") do goto :baddays
if not "%DAYS:~4%"=="" goto :baddays
if "%DAYS:~0,1%"=="0" goto :baddays
if %DAYS% GEQ 1900 goto :baddays

set "SUB="
set /p "SUB=Include sub-folders? (Y/N): "

rem --- Find the next free archive folder name ---
set /a N=0
:findnext
set /a N+=1
if %N% GTR 999 goto :toomany
set "NUM=000%N%"
set "DEST=archive_%NUM:~-3%"
if exist "%DEST%" goto :findnext

set "RCOPT=/MINAGE:%DAYS% /MOV /NJH /NP /FP"
if /i "%SUB%"=="Y" set "RCOPT=%RCOPT% /S"

echo.
echo Preview: files older than %DAYS% day(s) that would be moved to %DEST%
echo.
robocopy . "%DEST%" %RCOPT% /L /XF "%SELF%" /XD archive_* backup_* .git
if errorlevel 8 goto :failed

echo.
set "CONFIRM="
set /p "CONFIRM=Move the files listed above? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

echo.
robocopy . "%DEST%" %RCOPT% /NFL /NDL /XF "%SELF%" /XD archive_* backup_* .git
if errorlevel 8 goto :failed

rem Remove the archive folder again if nothing was moved into it
rd "%DEST%" 2>nul

echo.
if exist "%DEST%\" (
  echo Files moved to: %DEST%
) else (
  echo No files matched, so no archive folder was created.
)
goto :cleanup

:baddays
echo Enter a whole number from 1 to 1899.
echo.
goto :askdays

:toomany
echo Too many archive folders already exist.
goto :cleanup

:failed
echo.
echo [ERROR] robocopy reported errors. Check the messages above.
goto :cleanup

:cancelled
echo Cancelled.

:cleanup
popd
pause
endlocal
exit /b 0
