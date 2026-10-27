@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  wipe_free_space.bat
rem  Overwrites the FREE space of the drive that contains this script, so
rem  that the contents of previously deleted files can no longer be
rem  recovered. Uses the cipher tool built into Windows. Works fully
rem  offline.
rem
rem  Important:
rem    - Existing files are not touched; only unused space is overwritten.
rem    - Cipher makes three passes (zeros, ones, random data). On a large
rem      drive this can take hours.
rem    - While it runs, the drive is almost full. Other programs that
rem      write to the same drive may report a "disk full" error, so close
rem      them first.
rem    - Use a local drive. On SSDs the effect is limited, because the
rem      drive controller decides where data is physically written; full
rem      disk encryption is the better protection there.
rem    - Press Ctrl+C to stop; the temporary files are cleaned up by
rem      cipher when it ends.
rem ======================================================================

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

where cipher >nul 2>&1
if errorlevel 1 goto :nocipher

set "WP=%CD%"
if "%CD:~-1%"=="\" set "WP=%CD%."

echo Drive : %CD:~0,2%
echo.
echo This will overwrite all FREE space on this drive.
echo Existing files are not changed, but the operation can take hours and
echo will leave the drive almost full while it runs.
echo.
set "CONFIRM="
set /p "CONFIRM=Type YES to continue: "
if /i not "%CONFIRM%"=="YES" goto :cancelled

echo.
cipher /w:"%WP%"
if errorlevel 1 goto :failed

echo.
echo Finished. The free space of the drive has been overwritten.
goto :cleanup

:nocipher
echo The cipher tool was not found on this system.
goto :cleanup

:failed
echo.
echo [ERROR] cipher reported an error. Check the messages above.
goto :cleanup

:cancelled
echo Cancelled.

:cleanup
popd
pause
endlocal
exit /b 0
