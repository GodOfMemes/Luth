@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%..\.." || exit /b 1

extern\premake\windows\premake5.exe --file=premake5.lua vs2022
set "SETUP_RESULT=%ERRORLEVEL%"

popd
pause
exit /b %SETUP_RESULT%
