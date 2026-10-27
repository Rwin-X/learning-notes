@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  rename_from_map.bat
rem  Renames files from a mapping file that you edit yourself, with a
rem  built-in undo. Works fully offline.
rem
rem  Option E - Export:
rem    Writes rename_map.txt with one line per file:
rem        old name|new name
rem    Open it in a text editor and change only the part after the
rem    vertical bar. Lines that start with two colons are ignored.
rem    Save the file as UTF-8 if the names contain non-Latin letters.
rem  Option A - Apply:
rem    Renames every file whose new name differs from the old name, and
rem    saves rename_undo_map.txt so that the run can be reversed.
rem  Option U - Undo:
rem    Applies rename_undo_map.txt, which restores the previous names.
rem
rem  Behavior:
rem    - Never overwrites an existing file; conflicts are skipped. As a
rem      result, swaps and chains (a to b while b to c) are skipped too.
rem    - New names cannot contain \ / : * ? " < > |
rem    - Skips this script, the map files and hidden/system files.
rem
rem  Note: file names that contain a percent sign are not supported.
rem ======================================================================

set "MAPNAME=rename_map.txt"
set "UNDONAME=rename_undo_map.txt"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "MAP=%CD%\%MAPNAME%"
set "UNDOMAP=%CD%\%UNDONAME%"
set "UNDOTMP=%TEMP%\rename_undo_%RANDOM%%RANDOM%.txt"

echo Directory : "%CD%"
echo.
echo   E  Export the current names to %MAPNAME%
echo   A  Apply %MAPNAME%
echo   U  Undo the last apply
echo.
set "CHOICE="
set /p "CHOICE=Select an option (E, A or U): "
if /i "%CHOICE%"=="E" goto :export
if /i "%CHOICE%"=="A" goto :apply
if /i "%CHOICE%"=="U" goto :undo
echo Invalid choice.
goto :cleanup

rem ----------------------------------------------------------------------
:export
if not exist "%MAP%" goto :export_go
set "OW="
set /p "OW=%MAPNAME% already exists. Replace it? (Y/N): "
if /i not "%OW%"=="Y" goto :cancelled

:export_go
(
  echo :: Rename map. Each line has the format: old name^|new name
  echo :: Edit only the part after the vertical bar. Lines starting with two colons are ignored.
  for /f "eol=| delims=" %%F in ('dir /b /a-d-h-s') do (
    if /i not "%%F"=="%SELF%" if /i not "%%F"=="%MAPNAME%" if /i not "%%F"=="%UNDONAME%" echo(%%F^|%%F
  )
) > "%MAP%"
echo.
echo Map written: %MAPNAME%
echo Edit the names after the vertical bar, save the file, then run this
echo script again and choose A.
goto :cleanup

rem ----------------------------------------------------------------------
:undo
set "MAP=%UNDOMAP%"
set "MAPNAME=%UNDONAME%"
if not exist "%MAP%" goto :noundo

:apply
if not exist "%MAP%" goto :nomap
set /a TOTAL=0
for /f "usebackq tokens=1,* eol=: delims=|" %%A in ("%MAP%") do set /a TOTAL+=1
if %TOTAL% EQU 0 goto :emptymap

echo.
echo Map file : %MAPNAME%
echo Entries  : %TOTAL%
echo.
set "CONFIRM="
set /p "CONFIRM=Apply these renames? (Y/N): "
if /i not "%CONFIRM%"=="Y" goto :cancelled

> "%UNDOTMP%" echo :: Undo map created %DATE% %TIME%

set /a CHANGED=0
set /a SKIPPED=0
set /a FAILED=0

echo.
for /f "usebackq tokens=1,* eol=: delims=|" %%A in ("%MAP%") do call :doone "%%A" "%%B"

if %CHANGED% GTR 0 move /y "%UNDOTMP%" "%UNDOMAP%" >nul

echo.
echo Renamed : %CHANGED%
echo Skipped : %SKIPPED%
echo Failed  : %FAILED%
if %CHANGED% GTR 0 echo Undo map: %UNDONAME%
goto :cleanup

:nomap
echo %MAPNAME% was not found. Run option E first.
goto :cleanup

:noundo
echo No undo map was found. Nothing has been applied yet.
goto :cleanup

:emptymap
echo The map file has no entries.
goto :cleanup

:cancelled
echo Cancelled.

:cleanup
if exist "%UNDOTMP%" del "%UNDOTMP%" >nul 2>&1
popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:writeline
setlocal EnableDelayedExpansion
>> "%~1" echo(!LINE!
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:doone
set "OLD=%~1"
set "NEW=%~2"
if not defined NEW exit /b 0
if /i "%OLD%"=="%SELF%" exit /b 0
if "%OLD%"=="%NEW%" exit /b 0
if not exist "%OLD%" goto :d_missing
echo "%NEW%"| findstr /r /c:"[\\/:*?<>|]" >nul
if not errorlevel 1 goto :d_badname
rem A case-only change is allowed; otherwise never overwrite another file
if /i "%OLD%"=="%NEW%" goto :d_ren
if exist "%NEW%" goto :d_exists

:d_ren
ren "%OLD%" "%NEW%" 2>nul
if errorlevel 1 goto :d_fail
echo "%OLD%"  =^>  "%NEW%"
set "LINE=%NEW%|%OLD%"
call :writeline "%UNDOTMP%"
set /a CHANGED+=1
exit /b 0

:d_missing
echo [SKIP] File not found: "%OLD%"
set /a SKIPPED+=1
exit /b 0

:d_badname
echo [SKIP] Invalid new name: "%NEW%"
set /a SKIPPED+=1
exit /b 0

:d_exists
echo [SKIP] Target already exists: "%OLD%"  =^>  "%NEW%"
set /a SKIPPED+=1
exit /b 0

:d_fail
echo [ERROR] Could not rename: "%OLD%"
set /a FAILED+=1
exit /b 0
