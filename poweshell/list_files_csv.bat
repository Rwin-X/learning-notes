@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem ======================================================================
rem  list_files_csv.bat
rem  Exports an inventory of the files in the script's directory to
rem  files_list.csv with these columns:
rem      name, size_bytes, modified, full_path
rem
rem  Behavior:
rem    - Optionally includes sub-folders.
rem    - Skips this script, the output file and hidden/system files.
rem    - The file is replaced on every run.
rem ======================================================================

set "OUTNAME=files_list.csv"

pushd "%~dp0" || (echo Failed to enter script directory.& exit /b 1)

set "SELF=%~nx0"
set "OUT=%CD%\%OUTNAME%"

echo Directory : "%CD%"
echo.
set "REC="
set /p "REC=Include sub-folders? (Y/N): "

set "DIROPT=/a-d-h-s"
if /i "%REC%"=="Y" set "DIROPT=/s /a-d-h-s"

> "%OUT%" echo name,size_bytes,modified,full_path

set /a COUNT=0
for /f "eol=| delims=" %%F in ('dir /b %DIROPT%') do call :row "%%F"

echo.
echo Files listed: %COUNT%
echo Output: %OUTNAME%

popd
pause
endlocal
exit /b 0

rem ----------------------------------------------------------------------
:row
if /i "%~nx1"=="%SELF%" exit /b 0
if /i "%~nx1"=="%OUTNAME%" exit /b 0
>> "%OUT%" echo "%~nx1","%~z1","%~t1","%~f1"
set /a COUNT+=1
exit /b 0
