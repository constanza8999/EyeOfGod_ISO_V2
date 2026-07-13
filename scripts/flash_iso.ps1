<#
╔══════════════════════════════════════════════════════════════════════════╗
║  EYE OF GOD V∞ × KALI PURPLE — FLASHEAR ISO EN WINDOWS               ║
║  PowerShell script para escribir la ISO en un USB/HDD externo         ║
║  Soporta: dd for Windows, Rufus CLI, balenaEtcher CLI                 ║
╚══════════════════════════════════════════════════════════════════════════╝
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$IsoPath = "",
    
    [Parameter(Mandatory=$false)]
    [int]$DiskNumber = -1,
    
    [Parameter(Mandatory=$false)]
    [switch]$ListDisks = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

# ── Guardar color original ───────────────────────────────────────────────────
$originalColor = $Host.UI.RawUI.ForegroundColor

Write-Host @"
  ╔══════════════════════════════════════════════════════════════╗
  ║   👁  EYE OF GOD V∞  ×  KALI PURPLE  —  WINDOWS FLASHER    ║
  ╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor DarkRed

# ── Restaurar color al salir ───────────────────────────────────────────────────
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -SupportEvent -Action {
    $Host.UI.RawUI.ForegroundColor = $originalColor
} | Out-Null

function Write-Info  { Write-Host "[INFO ]" -ForegroundColor Cyan -NoNewline; Write-Host " $args" }
function Write-Ok    { Write-Host "[ OK  ]" -ForegroundColor Green -NoNewline; Write-Host " $args" }
function Write-Warn  { Write-Host "[WARN ]" -ForegroundColor Yellow -NoNewline; Write-Host " $args" }
function Write-Fail  { Write-Host "[FAIL ]" -ForegroundColor Red -NoNewline; Write-Host " $args"; exit 1 }

# ── Help ──────────────────────────────────────────────────────────────────────
if ($Help) {
    Write-Host @"
USO:
    .\scripts\flash_iso.ps1 -IsoPath "C:\ruta\EyeOfGod.iso"

OPCIONES:
    -IsoPath <ruta>     Ruta al archivo .iso
    -DiskNumber <num>   Número de disco destino (omitir para elegir interactivo)
    -ListDisks          Listar discos disponibles y salir
    -Force              Saltar confirmación
    -Help               Mostrar esta ayuda

EJEMPLOS:
    .\scripts\flash_iso.ps1 -IsoPath ".\EyeOfGod_KaliPurple_2025.3_HDD.iso"
    .\scripts\flash_iso.ps1 -IsoPath "D:\ISOs\eyegod.iso" -DiskNumber 2 -Force
    .\scripts\flash_iso.ps1 -ListDisks

REQUISITOS:
    - Ejecutar como ADMINISTRADOR
    - Tener dd for Windows, Rufus, o balenaEtcher instalado
    - El disco destino debe ser un USB/HDD externo (NO el disco del sistema)
"@
    exit 0
}

# ── Verificar administrador ───────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Fail "Este script requiere permisos de ADMINISTRADOR. Ejecuta PowerShell como Administrador."
}

# ── Listar discos ─────────────────────────────────────────────────────────────
function List-Disks {
    Write-Host "`nDiscos disponibles:" -ForegroundColor Cyan
    Get-Disk | Where-Object { $_.BusType -notin @('File Backed Virtual', 'USB', 'SCSI', 'SAS') -or $_.Size -gt 16GB } |
        Sort-Object Number |
        Format-Table -AutoSize -Property `
            @{N="N°";E={$_.Number}},
            @{N="Tamaño";E={"{0:N0} GB" -f ($_.Size / 1GB)}},
            @{N="Tipo";E={$_.BusType}},
            @{N="Estilo";E={$_.PartitionStyle}},
            @{N="Estado";E={if($_.OperationalStatus -eq "Online"){"Online"}else{$_.OperationalStatus}}},
            @{N="Sistema";E={if($_.IsSystem -or $_.IsBoot){"⚠ SISTEMA"}else{""}}}
}

if ($ListDisks) {
    List-Disks
    exit 0
}

# ── Buscar ISO ────────────────────────────────────────────────────────────────
if (-not $IsoPath) {
    # Buscar automáticamente archivos .iso en el directorio actual
    $isos = Get-ChildItem -Path "." -Filter "*.iso" -File | Sort-Object LastWriteTime -Descending
    if ($isos.Count -eq 0) {
        Write-Fail "No se encontró archivo .iso. Especifica la ruta con -IsoPath"
    } elseif ($isos.Count -eq 1) {
        $IsoPath = $isos[0].FullName
        Write-Info "ISO encontrada: $IsoPath"
    } else {
        Write-Host "Se encontraron varias ISOs:" -ForegroundColor Yellow
        for ($i = 0; $i -lt $isos.Count; $i++) {
            Write-Host "  [$i] $($isos[$i].Name) ($([math]::Round($isos[$i].Length / 1GB, 2)) GB)"
        }
        $selection = Read-Host "Selecciona el número de la ISO"
        $IsoPath = $isos[[int]$selection].FullName
    }
}

if (-not (Test-Path $IsoPath)) {
    Write-Fail "Archivo no encontrado: $IsoPath"
}

$isoSize = (Get-Item $IsoPath).Length
Write-Info "ISO: $IsoPath ($([math]::Round($isoSize / 1GB, 2)) GB)"

# ── Seleccionar disco ─────────────────────────────────────────────────────────
if ($DiskNumber -eq -1) {
    List-Disks
    Write-Host ""
    $DiskNumber = Read-Host "Introduce el N° de disco destino"
}

$disk = Get-Disk -Number $DiskNumber -ErrorAction SilentlyContinue
if (-not $disk) {
    Write-Fail "Disco N° $DiskNumber no encontrado. Usa -ListDisks para ver los disponibles."
}

# ── Protección contra disco del sistema ───────────────────────────────────────
if ($disk.IsSystem -or $disk.IsBoot) {
    Write-Fail "⚠  El disco N° $DiskNumber es el DISCO DEL SISTEMA. ABORTANDO por seguridad."
}

$systemDrives = @()
Get-Partition -DiskNumber $DiskNumber -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.DriveLetter) {
        $vol = Get-Volume -DriveLetter $_.DriveLetter -ErrorAction SilentlyContinue
        if ($vol.DriveType -eq "Fixed") {
            $systemDrives += $_.DriveLetter
        }
    }
}
if ($systemDrives.Count -gt 0) {
    Write-Warn "⚠  El disco N° $DiskNumber contiene volúmenes fijos: $($systemDrives -join ', ')"
    Write-Warn "⚠  Verifica que sea el disco EXTERNO correcto."
    if (-not $Force) {
        $confirm = Read-Host "¿SEGURO que quieres flashear este disco? (escribe 'CONFIRMO')"
        if ($confirm -ne "CONFIRMO") { Write-Fail "Operación cancelada." }
    }
}

$diskSizeGB = [math]::Round($disk.Size / 1GB, 1)
$isoSizeGB = [math]::Round($isoSize / 1GB, 2)

Write-Host ""
Write-Host "═══ RESUMEN ═══" -ForegroundColor Yellow
Write-Host "  ISO   : $IsoPath"
Write-Host "  Tamaño: $isoSizeGB GB"
Write-Host "  Disco : N° $DiskNumber ($diskSizeGB GB, $($disk.BusType))"
Write-Host "═══════════════" -ForegroundColor Yellow
Write-Host ""

if (-not $Force) {
    Write-Warn "⚠  TODO el contenido del disco N° $DiskNumber SERÁ BORRADO."
    $confirm = Read-Host "¿Continuar? (s/N)"
    if ($confirm -notmatch '^[sS]$') { Write-Fail "Operación cancelada." }
}

# ── Detectar herramienta de flasheo ──────────────────────────────────────────
function Find-Flasher {
    # dd for Windows (chrysocome.net)
    $ddPaths = @(
        "dd.exe",
        "C:\Windows\dd.exe",
        "C:\Windows\System32\dd.exe",
        "${env:ProgramFiles}\dd\dd.exe",
        "${env:ProgramFiles(x86)}\dd\dd.exe"
    )
    foreach ($p in $ddPaths) {
        if (Get-Command $p -ErrorAction SilentlyContinue) { return "dd", $p }
    }

    # Rufus CLI
    $rufusPaths = @(
        "rufus.exe",
        "rufus-cli.exe",
        "${env:ProgramFiles}\Rufus\rufus.exe",
        "${env:ProgramFiles(x86)}\Rufus\rufus.exe",
        "${env:LOCALAPPDATA}\Rufus\rufus.exe"
    )
    foreach ($p in $rufusPaths) {
        if (Get-Command $p -ErrorAction SilentlyContinue) { return "rufus", $p }
    }

    # balenaEtcher CLI
    $etcherPaths = @(
        "balena-etcher.exe",
        "etcher.exe",
        "${env:ProgramFiles}\balena-etcher\balena-etcher.exe",
        "${env:LOCALAPPDATA}\Programs\balena-etcher\balena-etcher.exe"
    )
    foreach ($p in $etcherPaths) {
        if (Get-Command $p -ErrorAction SilentlyContinue) { return "etcher", $p }
    }

    return $null, $null
}

$flasher, $flasherPath = Find-Flasher

if (-not $flasher) {
    Write-Warn "No se encontró dd.exe, Rufus ni balenaEtcher."
    Write-Warn ""
    Write-Host "OPCIÓN A — Descarga Rufus (recomendado para Windows):" -ForegroundColor Cyan
    Write-Host "  1. Ve a https://rufus.ie y descarga Rufus"
    Write-Host "  2. Ábrelo y selecciona:"
    Write-Host "     - Dispositivo: el USB/HDD externo"
    Write-Host "     - Selección de arranque: la ISO generada"
    Write-Host "     - Esquema: MBR (o GPT si tu equipo es UEFI)"
    Write-Host "  3. Click 'EMPEZAR'"
    Write-Host ""
    Write-Host "OPCIÓN B — Descarga dd for Windows:" -ForegroundColor Cyan
    Write-Host "  1. Ve a http://www.chrysocome.net/dd"
    Write-Host "  2. Descarga dd.exe y colócalo en C:\Windows\"
    Write-Host "  3. Ejecuta este script de nuevo"
    Write-Host ""
    Write-Host "OPCIÓN C — Usa balenaEtcher:" -ForegroundColor Cyan
    Write-Host "  1. Ve a https://balena.io/etcher"
    Write-Host "  2. Descarga, instala, selecciona la ISO y el disco"
    Write-Host "  3. Click 'Flash!'"
    exit 1
}

# ── Ejecutar flasheo ─────────────────────────────────────────────────────────
Write-Info "Usando: $flasher ($flasherPath)"

$physicalPath = "\\.\PhysicalDrive$DiskNumber"

switch ($flasher) {
    "dd" {
        Write-Info "Flasheando con dd for Windows..."
        Write-Warn "Esto puede tomar varios minutos. NO desconectes el disco."
        
        $ddArgs = @(
            "if=$IsoPath",
            "of=$physicalPath",
            "bs=4M",
            "--progress"
        )
        
        $process = Start-Process -FilePath $flasherPath -ArgumentList $ddArgs -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Ok "ISO flasheada correctamente."
        } else {
            Write-Fail "dd falló con código: $($process.ExitCode)"
        }
    }
    
    "rufus" {
        Write-Info "Abriendo Rufus con la ISO preseleccionada..."
        Write-Warn "Rufus se abrirá en modo interactivo. Completa estos pasos:"
        Write-Warn "  1. Verifica que el dispositivo sea el correcto"
        Write-Warn "  2. Esquema de partición: MBR (o GPT para UEFI)"
        Write-Warn "  3. Click 'EMPEZAR'"
        
        # Rufus acepta el ISO como argumento para preseleccionarlo
        Start-Process -FilePath $flasherPath -ArgumentList "`"$IsoPath`"" -Wait
        Write-Ok "Rufus cerrado."
    }
    
    "etcher" {
        Write-Info "Abriendo balenaEtcher con la ISO preseleccionada..."
        Write-Warn "balenaEtcher se abrirá en modo gráfico. Completa estos pasos:"
        Write-Warn "  1. Verifica que el dispositivo sea el correcto"
        Write-Warn "  2. Click 'Flash!'"
        
        # balenaEtcher acepta el ISO como argumento para preseleccionarlo
        Start-Process -FilePath $flasherPath -ArgumentList "`"$IsoPath`"" -Wait
        Write-Ok "balenaEtcher cerrado."
    }
}

# ── Final ─────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host @"
╔══════════════════════════════════════════════════════════════════════╗
║  ✅  ISO FLASHEADA — PRÓXIMOS PASOS                                ║
╠══════════════════════════════════════════════════════════════════════╣
║  1. Deshabilita Secure Boot en la BIOS/UEFI                        ║
║  2. Conecta el HDD/USB y bootea desde él (F8/F11/F12)              ║
║  3. En el menú GRUB, selecciona la opción deseada                   ║
║                                                                     ║
║  Para persistencia en Linux/WSL:                                    ║
║    sudo bash scripts/setup_hdd_persistence.sh /dev/sdX              ║
╚══════════════════════════════════════════════════════════════════════╝
"@
