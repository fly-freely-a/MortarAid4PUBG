@echo off
setlocal
cd /d "%~dp0"

echo [1/5] Checking Python...
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

echo [2/5] Creating virtual environment...
if not exist ".venv\Scripts\python.exe" (
    %PYTHON_CMD% -m venv .venv
    if errorlevel 1 goto :failed
)

echo [3/5] Installing build dependencies...
call ".venv\Scripts\activate.bat"
python -m pip install --upgrade pip
if errorlevel 1 goto :failed
python -m pip install -r requirements.txt pyinstaller
if errorlevel 1 goto :failed

echo [4/5] Building MortarAid...
python -m PyInstaller --clean --noconfirm MortarAid.spec
if errorlevel 1 goto :failed

echo [5/5] Creating zip package...
if exist "dist\MortarAid-win64.zip" del /q "dist\MortarAid-win64.zip"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '.\dist\MortarAid\*' -DestinationPath '.\dist\MortarAid-win64.zip' -Force"
if errorlevel 1 goto :failed

echo.
echo Build completed successfully.
echo EXE: %CD%\dist\MortarAid\MortarAid.exe
echo ZIP: %CD%\dist\MortarAid-win64.zip
pause
exit /b 0

:failed
echo.
echo Build failed. Review the error message above.
pause
exit /b 1
