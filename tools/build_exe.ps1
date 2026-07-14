<#
╔══════════════════════════════════════════════════════════════════════════╗
║  EYE OF GOD V∞ × KALI PURPLE — EXE BUILDER (PowerShell)               ║
║  Build Windows Release Tool as standalone EXE                          ║
╚══════════════════════════════════════════════════════════════════════════╝
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$Clean = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help = $false
)

$Host.UI.RawUI.ForegroundColor = "DarkRed"
Write-Host @"
  ╔══════════════════════════════════════════════════════════════╗
  ║   👁  EYE OF GOD V∞ — EXE BUILDER                           ║
  ║   Building Windows Release Tool                             ║
  ╚══════════════════════════════════════════════════════════════╝
"@
$Host.UI.RawUI.ForegroundColor = "Gray"

function Write-Info  { Write-Host "[INFO ]" -ForegroundColor Cyan -NoNewline; Write-Host " $args" }
function Write-Ok    { Write-Host "[ OK  ]" -ForegroundColor Green -NoNewline; Write-Host " $args" }
function Write-Warn  { Write-Host "[WARN ]" -ForegroundColor Yellow -NoNewline; Write-Host " $args" }
function Write-Fail  { Write-Host "[FAIL ]" -ForegroundColor Red -NoNewline; Write-Host " $args"; exit 1 }

# Help
if ($Help) {
    Write-Host @"
USAGE:
    .\tools\build_exe.ps1              Build the EXE
    .\tools\build_exe.ps1 -Clean       Clean build artifacts first
    .\tools\build_exe.ps1 -Help        Show this help

REQUIREMENTS:
    - Python 3.8+ installed and in PATH
    - pip (Python package manager)

WHAT THIS DOES:
    1. Installs PyInstaller if not present
    2. Builds a standalone EXE from the Python GUI app
    3. Copies the EXE to the project root
    4. Cleans up temporary build files

OUTPUT:
    - EyeOfGod_ReleaseTool.exe (standalone, no Python required)
"@
    exit 0
}

# Check Python
Write-Info "Checking Python installation..."
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Fail "Python not found. Install Python 3.8+ from https://python.org"
}
Write-Ok "Python detected: $pythonVersion"

# Check pip
Write-Info "Checking pip..."
pip --version 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Fail "pip not found. Ensure pip is installed with Python."
}

# Install PyInstaller
Write-Info "Installing/updating PyInstaller..."
pip install --upgrade pyinstaller 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Ok "PyInstaller ready"
} else {
    Write-Warn "PyInstaller installation may have issues, continuing anyway..."
}

# Clean if requested
if ($Clean) {
    Write-Info "Cleaning previous build artifacts..."
    Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
    Remove-Item -Force "EyeOfGod_ReleaseTool.spec" -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "dist" -ErrorAction SilentlyContinue
    Write-Ok "Cleaned"
}

# Build EXE
Write-Info "Building EXE with PyInstaller..."
Write-Info "This may take 2-5 minutes..."

pyinstaller `
    --name "EyeOfGod_ReleaseTool" `
    --onefile `
    --windowed `
    --clean `
    --noconfirm `
    --hidden-import tkinter `
    --hidden-import tkinter.ttk `
    --hidden-import tkinter.scrolledtext `
    --hidden-import tkinter.filedialog `
    --hidden-import tkinter.messagebox `
    tools\eyegod_tool.py

if ($LASTEXITCODE -ne 0) {
    Write-Fail "Build failed. Check the output above for errors."
}

# Copy EXE
Write-Info "Copying EXE to project root..."
Copy-Item -Force "dist\EyeOfGod_ReleaseTool.exe" -Destination "." -ErrorAction SilentlyContinue
if (Test-Path "EyeOfGod_ReleaseTool.exe") {
    $size = (Get-Item "EyeOfGod_ReleaseTool.exe").Length / 1MB
    Write-Ok "EXE created: EyeOfGod_ReleaseTool.exe ($([math]::Round($size, 1)) MB)"
} else {
    Write-Warn "EXE not found in project root. Check dist\ folder."
}

# Cleanup
Write-Info "Cleaning up build artifacts..."
Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
Remove-Item -Force "EyeOfGod_ReleaseTool.spec" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "dist" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host @"
╔══════════════════════════════════════════════════════════════════════╗
║  ✅  BUILD COMPLETE                                                ║
╠══════════════════════════════════════════════════════════════════════╣
║  EXE: EyeOfGod_ReleaseTool.exe (in project root)                   ║
║                                                                     ║
║  The EXE is standalone - no Python installation required on         ║
║  target machines. Simply distribute the .exe file.                  ║
╚══════════════════════════════════════════════════════════════════════╝
"@
