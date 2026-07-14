@echo off
title Eye of God V∞ — EXE Builder
chcp 65001 >nul

echo.
echo   ╔══════════════════════════════════════════════════════════════╗
echo   ║   👁  EYE OF GOD V∞ — EXE BUILDER                          ║
echo   ║   Building Windows Release Tool                            ║
echo   ╚══════════════════════════════════════════════════════════════╝
echo.

:: Check Python
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo   [FAIL] Python not found. Install Python 3.8+ from https://python.org
    pause
    exit /b 1
)

echo   [INFO] Python detected:
python --version
echo.

:: Install dependencies
echo   [INFO] Installing dependencies...
pip install pyinstaller >nul 2>&1
if %errorLevel% neq 0 (
    echo   [WARN] PyInstaller installation may have failed
)

:: Build EXE
echo   [INFO] Building EXE with PyInstaller...
echo   [INFO] This may take a few minutes...
echo.

pyinstaller ^
    --name "EyeOfGod_ReleaseTool" ^
    --onefile ^
    --windowed ^
    --clean ^
    --noconfirm ^
    --hidden-import tkinter ^
    --hidden-import tkinter.ttk ^
    --hidden-import tkinter.scrolledtext ^
    --hidden-import tkinter.filedialog ^
    --hidden-import tkinter.messagebox ^
    tools/eyegod_tool.py

if %errorLevel% neq 0 (
    echo.
    echo   [FAIL] Build failed. Check the output above for errors.
    pause
    exit /b 1
)

:: Copy EXE to root
echo.
echo   [INFO] Copying EXE to project root...
copy /Y dist\EyeOfGod_ReleaseTool.exe . >nul 2>&1

:: Cleanup
echo   [INFO] Cleaning up build artifacts...
rmdir /S /Q build >nul 2>&1
del /Q EyeOfGod_ReleaseTool.spec >nul 2>&1

echo.
echo   ╔══════════════════════════════════════════════════════════════╗
echo   ║   ✅  BUILD COMPLETE                                        ║
echo   ╠══════════════════════════════════════════════════════════════╣
echo   ║   EXE Location: dist\EyeOfGod_ReleaseTool.exe               ║
echo   ║   Size: Check with: dir dist\EyeOfGod_ReleaseTool.exe       ║
echo   ║                                                              ║
echo   ║   You can now distribute the EXE file.                      ║
echo   ╚══════════════════════════════════════════════════════════════╝
echo.

pause
