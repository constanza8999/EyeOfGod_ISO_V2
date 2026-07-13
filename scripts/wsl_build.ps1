<#
╔══════════════════════════════════════════════════════════════════════════╗
║  EYE OF GOD V∞ × KALI PURPLE — WSL BUILD HELPER (WINDOWS)            ║
║  Configura WSL con Kali Linux y construye la ISO desde Windows        ║
╚══════════════════════════════════════════════════════════════════════════╝
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$SetupWsl = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Build = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help = $false
)

$Host.UI.RawUI.ForegroundColor = "DarkRed"
Write-Host @"
  ╔══════════════════════════════════════════════════════════════╗
  ║   👁  EYE OF GOD V∞  ×  KALI PURPLE  —  WSL BUILDER        ║
  ║       Construye la ISO desde Windows 10/11                  ║
  ╚══════════════════════════════════════════════════════════════╝
"@
$Host.UI.RawUI.ForegroundColor = "Gray"

function Write-Info  { Write-Host "[INFO ]" -ForegroundColor Cyan -NoNewline; Write-Host " $args" }
function Write-Ok    { Write-Host "[ OK  ]" -ForegroundColor Green -NoNewline; Write-Host " $args" }
function Write-Warn  { Write-Host "[WARN ]" -ForegroundColor Yellow -NoNewline; Write-Host " $args" }
function Write-Fail  { Write-Host "[FAIL ]" -ForegroundColor Red -NoNewline; Write-Host " $args"; exit 1 }

# ── Help ──────────────────────────────────────────────────────────────────────
if ($Help) {
    Write-Host @"
USO:
    .\scripts\wsl_build.ps1 -SetupWsl     Configurar WSL con Kali Linux
    .\scripts\wsl_build.ps1 -Build        Construir la ISO dentro de WSL

OPCIONES:
    -SetupWsl   Instala/verifica WSL2 y crea una distribución Kali
    -Build      Copia el proyecto a WSL y ejecuta el build
    -Help       Muestra esta ayuda

REQUISITOS:
    - Windows 10 build 19041+ o Windows 11
    - PowerShell como Administrador para -SetupWsl
    - Conexión a internet

FLUJO COMPLETO:
    1. .\scripts\wsl_build.ps1 -SetupWsl    (una vez)
    2. .\scripts\wsl_build.ps1 -Build       (cada vez que quieras rebuildear)
"@
    exit 0
}

# ── Verificar Windows 10/11 ───────────────────────────────────────────────────
$winVer = [Environment]::OSVersion.Version
if ($winVer.Major -lt 10) {
    Write-Fail "Se requiere Windows 10 (build 19041+) o Windows 11."
}

# ══════════════════════════════════════════════════════════════════════════════
#  MODO: SETUP WSL
# ══════════════════════════════════════════════════════════════════════════════
if ($SetupWsl) {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Fail "-SetupWsl requiere PowerShell como Administrador."
    }

    # ── Paso 1: Verificar/Instalar WSL ─────────────────────────────────────────
    Write-Info "Paso 1: Verificando WSL..."
    $wslInstalled = Get-Command wsl.exe -ErrorAction SilentlyContinue
    if (-not $wslInstalled) {
        Write-Info "Instalando WSL2 (se requiere reinicio)..."
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        Write-Warn "Reinicia el equipo y ejecuta este script de nuevo con -SetupWsl"
        exit 0
    } else {
        Write-Ok "WSL detectado."
    }

    # ── Paso 2: WSL 2 como default ────────────────────────────────────────────
    Write-Info "Paso 2: Configurando WSL 2 como versión por defecto..."
    wsl --set-default-version 2 2>$null
    Write-Ok "WSL 2 configurado."

    # ── Paso 3: Instalar Kali Linux ──────────────────────────────────────────
    Write-Info "Paso 3: Instalando distribución Kali Linux..."
    $kaliInstalled = wsl -l --quiet 2>$null | Select-String -SimpleMatch "kali"
    if (-not $kaliInstalled) {
        Write-Info "Descargando Kali Linux desde Microsoft Store (puede tomar tiempo)..."
        wsl --install -d kali-linux
        Write-Warn "Kali Linux instalado. Completa la configuración inicial:"
        Write-Warn "  - Crea un usuario y contraseña cuando se solicite"
        Write-Warn "  - Luego ejecuta: .\scripts\wsl_build.ps1 -Build"
    } else {
        Write-Ok "Kali Linux ya está instalado."
    }

    # ── Paso 4: Verificar ─────────────────────────────────────────────────────
    Write-Host ""
    Write-Info "Verificando instalación..."
    wsl -l -v

    Write-Host ""
    Write-Host @"
╔══════════════════════════════════════════════════════════════════════╗
║  ✅  WSL KALI LISTO                                               ║
╠══════════════════════════════════════════════════════════════════════╣
║  Ahora ejecuta:                                                     ║
║    .\scripts\wsl_build.ps1 -Build                                   ║
╚══════════════════════════════════════════════════════════════════════╝
"@
}

# ══════════════════════════════════════════════════════════════════════════════
#  MODO: BUILD
# ══════════════════════════════════════════════════════════════════════════════
if ($Build) {
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        Write-Fail "WSL no está instalado. Ejecuta primero: .\scripts\wsl_build.ps1 -SetupWsl"
    }

    # ── Obtener el usuario de WSL ────────────────────────────────────────────
    $wslUser = wsl whoami 2>$null
    if (-not $wslUser) { $wslUser = "user" }
    
    $projectRoot = Resolve-Path "."
    $wslPath = "/home/$wslUser/eyegod_iso_v2"

    # ── Paso 1: Copiar proyecto a WSL ────────────────────────────────────────
    Write-Info "Paso 1: Copiando proyecto a WSL..."
    Write-Info "Origen:  $projectRoot"
    Write-Info "Destino: $wslPath"
    
    # Convertir ruta Windows a ruta WSL (/mnt/c/...)
    $wslProjectRoot = wsl wslpath "$projectRoot" 2>$null
    if (-not $wslProjectRoot) {
        Write-Warn "wslpath falló. Usando ruta directa /mnt/..."
        $drive = $projectRoot.Substring(0,1).ToLower()
        $rest = $projectRoot.Substring(2) -replace '\\','/'
        $wslProjectRoot = "/mnt/$drive$rest"
    }
    
    # Crear/actualizar usando rsync o tar para preservar estructura
    wsl mkdir -p "$wslPath"
    
    # Usar tar pipeline para copiar manteniendo permisos y estructura
    $tarCmd = "tar cf - -C '$wslProjectRoot' . | tar xf - -C '$wslPath'"
    wsl --exec bash -c $tarCmd 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Proyecto copiado a WSL: $wslPath"
    } else {
        # Fallback: copia simple
        Write-Warn "tar pipeline falló, usando copia simple..."
        wsl cp -r "$wslProjectRoot/." "$wslPath/" 2>$null
        Write-Ok "Proyecto copiado (método alternativo)."
    }

    # ── Paso 2: Instalar dependencias en WSL ─────────────────────────────────
    Write-Info "Paso 2: Instalando dependencias en WSL Kali..."
    Write-Info "Esto requiere tu contraseña de sudo en WSL."
    
    wsl -d kali-linux --exec bash -c @"
cd '$wslPath'
sudo apt update -qq
sudo apt install -y --no-install-recommends \
    xorriso squashfs-tools debootstrap \
    grub-pc-bin grub-efi-amd64-bin grub-efi-amd64 \
    mtools dosfstools live-build live-boot live-boot-initramfs-tools \
    cryptsetup-bin curl wget python3 python3-pip \
    memtest86+ 2>&1 | tail -5
"@

    # ── Paso 3: Ejecutar build ────────────────────────────────────────────────
    Write-Info "Paso 3: Construyendo ISO (puede tomar 15-30 minutos)..."
    Write-Host ""
    Write-Warn "NO cierres esta ventana hasta que termine."
    Write-Host ""
    
    wsl -d kali-linux --exec bash -c "cd '$wslPath' && sudo bash scripts/build_kali_hdd.sh --clean ."

    # ── Paso 4: Copiar ISO de vuelta a Windows ───────────────────────────────
    Write-Info "Paso 4: Copiando ISO generada a Windows..."
    $isoName = "EyeOfGod_KaliPurple_2025.3_HDD.iso"
    $wslIso = "$wslPath/$isoName"
    $windowsDest = "$projectRoot/$isoName"
    
    $isoExists = wsl test -f "$wslIso" && echo "yes" || echo "no"
    if ($isoExists -eq "yes") {
        wsl cp "$wslIso" "/mnt/c/Users/$env:USERNAME/Desktop/"
        Write-Ok "ISO copiada al escritorio: C:\Users\$env:USERNAME\Desktop\$isoName"
        Write-Ok "Tamaño: $(wsl ls -lh '$wslIso' | awk '{print $5}')"
    } else {
        Write-Warn "No se encontró la ISO en WSL. El build puede haber fallado."
        Write-Warn "Revisa los mensajes de error arriba."
    }

    # ── Final ─────────────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host @"
╔══════════════════════════════════════════════════════════════════════╗
║  🎉  BUILD COMPLETADO                                              ║
╠══════════════════════════════════════════════════════════════════════╣
║  Flashea la ISO con:                                                ║
║    .\scripts\flash_iso.ps1 -IsoPath ".\$isoName"                    ║
║                                                                     ║
║  O usa Rufus: https://rufus.ie                                      ║
╚══════════════════════════════════════════════════════════════════════╝
"@
}
