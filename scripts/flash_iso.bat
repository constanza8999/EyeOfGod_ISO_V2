@echo off
title Eye of God V∞ × Kali Purple — Windows Flash Helper
chcp 65001 >nul
cd /d "%~dp0.."

echo.
echo   ╔══════════════════════════════════════════════════════════════╗
echo   ║   👁  EYE OF GOD V∞  ×  KALI PURPLE                       ║
echo   ║       Windows Flash Helper                                 ║
echo   ╚══════════════════════════════════════════════════════════════╝
echo.

:: Check if running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo   [WARN] Este script requiere permisos de ADMINISTRADOR.
    echo   [WARN] Click derecho ^> "Ejecutar como administrador"
    echo.
    pause
    exit /b 1
)

echo   [1] Flashear ISO a USB/HDD
echo   [2] Listar discos disponibles
echo   [3] Configurar WSL para build
echo   [4] Construir ISO en WSL
echo   [5] Salir
echo.

set /p opcion="Selecciona una opción (1-5): "

if "%opcion%"=="1" goto flash
if "%opcion%"=="2" goto list
if "%opcion%"=="3" goto wsl
if "%opcion%"=="4" goto build
if "%opcion%"=="5" goto end

echo Opción inválida.
pause
exit /b 1

:flash
echo.
echo   Buscando archivos .iso...
powershell -ExecutionPolicy Bypass -File "scripts\flash_iso.ps1" -Force
pause
goto end

:list
echo.
powershell -ExecutionPolicy Bypass -File "scripts\flash_iso.ps1" -ListDisks
pause
goto end

:wsl
echo.
echo   Configurando WSL con Kali Linux...
echo   Nota: Se abrirá una ventana de PowerShell como Administrador.
powershell -Command "Start-Process PowerShell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"scripts\wsl_build.ps1\" -SetupWsl'"
pause
goto end

:build
echo.
echo   Construyendo ISO en WSL...
echo   Nota: Se abrirá una ventana de PowerShell.
powershell -ExecutionPolicy Bypass -File "scripts\wsl_build.ps1" -Build
pause
goto end

:end
echo.
echo   El Ojo todo lo ve.
echo.
