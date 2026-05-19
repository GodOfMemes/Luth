@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%..\.." || exit /b 1

:: 1. Dynamically locate the latest MSBuild.exe installation
for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
    set "MSBUILD_PATH=%%i"
)

:: 2. Fail gracefully if not found
if not defined MSBUILD_PATH (
    echo ERROR: MSBuild could not be found. Make sure Visual Studio is installed.
    popd
    pause
    exit /b 1
)

:: 3. Execute the build
"%MSBUILD_PATH%" Luth.sln /p:Configuration=Debug /p:Platform=x64
set "BUILD_RESULT=%ERRORLEVEL%"

popd
pause
exit /b %BUILD_RESULT%
