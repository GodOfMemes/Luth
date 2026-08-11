@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%..\.." || exit /b 1

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VS_VERSION=vs2022"

if exist "%VSWHERE%" (
    "%VSWHERE%" -version "[18.0,19.0)" -latest -products * >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "VS_VERSION=vs2026"
    )
)

echo Using Premake action: %VS_VERSION%

extern\premake\windows\premake5.exe --file=premake5.lua %VS_VERSION%
set "SETUP_RESULT=%ERRORLEVEL%"

popd
pause
exit /b %SETUP_RESULT%

