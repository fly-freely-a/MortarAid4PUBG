@echo off
setlocal
cd /d "%~dp0"

echo [1/4] Checking Python...
where py >nul 2>nul
if %errorlevel% equ 0 (
    set "PYTHON_CMD=py -3"
) else (
    where python >nul 2>nul
    if errorlevel 1 (
        echo Python 3 was not found. Install it from https://www.python.org/downloads/windows/
        pause
        exit /b 1
    )
    set "PYTHON_CMD=python"
)

echo [2/4] Creating virtual environment...
if not exist ".venv\Scripts\python.exe" (
    %PYTHON_CMD% -m venv .venv
    if errorlevel 1 goto :failed
)

echo [3/4] Installing build dependencies...
call ".venv\Scripts\activate.bat"
python -m pip install --upgrade pip
if errorlevel 1 goto :failed
python -m pip install -r requirements.txt pyinstaller
if errorlevel 1 goto :failed

echo [4/4] Building single-file MortarAid.exe...
if exist "dist\MortarAid" rmdir /s /q "dist\MortarAid"
if exist "dist\MortarAid-win64.zip" del /q "dist\MortarAid-win64.zip"
python -m PyInstaller --clean --noconfirm MortarAid.spec
if errorlevel 1 goto :failed

echo.
echo Build completed successfully.
echo EXE: %CD%\dist\MortarAid.exe
pause
exit /b 0

:failed
echo.
echo Build failed. Review the error message above.
pause
exit /b 1
