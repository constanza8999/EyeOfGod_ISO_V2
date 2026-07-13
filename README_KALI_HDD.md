# 👁 EYE OF GOD V∞ × KALI PURPLE — HDD EXTERNO
## Kernel 6.12.0-kali-amd64 | Kali Linux 2025.3 | Boot BIOS+UEFI

---

## ¿QUÉ KERNEL USA?

| Versión Kali  | Kernel          | Notas |
|---------------|-----------------|-------|
| Kali 2025.3   | **6.12.0-kali** | ← Esta build |
| Kali 2025.2   | 6.12.0-kali     | |
| Kali 2025.1   | 6.12.0-kali     | |
| Kali 2024.4   | 6.11.0-kali     | |

El kernel de Kali es el kernel Linux estándar **parcheado por OffSec** con:
- Soporte de inyección de paquetes 802.11 (wireless injection)
- `dmesg` sin restricciones (sin necesidad de root)
- Puertos < 1024 sin privilegios de root
- Drivers extra para hardware de seguridad
- Parches de `kali-tweaks` para pentesting

---

## ÁRBOL DE DIRECTORIOS

```
EYEOFGOD_ISO_V2/
│
├── .gitignore                        ← Build artifacts ignorados
├── README_KALI_HDD.md                 ← Este archivo
│
├── scripts/
│   ├── build_kali_hdd.sh              ← Build completo de la ISO (Linux/WSL)
│   ├── setup_hdd_persistence.sh       ← Configurar persistencia en HDD (Linux)
│   ├── grub_kali.cfg                  ← GRUB (copia de iso_root/ para build)
│   ├── flash_iso.ps1                  ← Flashear ISO en Windows (PowerShell)
│   ├── wsl_build.ps1                  ← Build desde WSL en Windows (PowerShell)
│   └── flash_iso.bat                  ← Menú interactivo para Windows
│
└── iso_root/
    └── boot/grub/grub.cfg             ← Menú GRUB principal (40+ entradas)
    └── live/                          ← Kernel e initrd (se generan en build)
```

---

## FLUJO COMPLETO DE BOOT EN HDD EXTERNO

```
BIOS/UEFI
  │
  └──► GRUB2 (grub.cfg)
          │
          ├─ Menú EyeGod × Kali Purple (40+ entradas)
          │   ├─ Kali Purple modo defensivo (NIST CSF)
          │   ├─ Kali Purple modo ofensivo (MITRE ATT&CK)
          │   ├─ Niveles EyeGod 0 → ∞
          │   ├─ 💾 Persistencia en HDD externo
          │   ├─ 🔐 Persistencia cifrada LUKS
          │   └─ 🖥  Instalación completa en HDD
          │
          └──► linux vmlinuz-6.12.0-kali-amd64 boot=live live-media=removable ...
                    │
                    └──► initrd.img (live-boot de Kali)
                              │
                              ├── Detecta HDD externo
                              ├── Monta filesystem.squashfs
                              ├── Crea overlayfs (squash + RAM o partición persist)
                              └──► Sistema Kali Purple arrancado
                                        │
                                        ├── [systemd] eyegod-bridge.service → WebSocket :8765
                                        ├── [systemd] eyegod-kernel.service → Python REPL
                                        └── [auto] EyeGod dashboard en localhost:8766
```

---

## INSTALACIÓN — LINUX / WSL

### Requisitos
- HDD/SSD externo: mínimo **32GB** (recomendado 128GB+)
- Sistema para construir: **Kali Linux**, Debian/Ubuntu, o **WSL en Windows**

### 🔹 Opción A — Linux nativo

#### Paso 1 — Instalar dependencias (en Kali/Debian/Ubuntu)
```bash
sudo apt update
sudo apt install -y \
  xorriso squashfs-tools \
  grub-pc-bin grub-efi-amd64-bin grub-efi-amd64 \
  mtools dosfstools \
  live-build live-boot live-boot-initramfs-tools \
  debootstrap cryptsetup \
  python3 python3-pip memtest86+
```

#### Paso 2 — Construir la ISO
```bash
cd EYEOFGOD_ISO_V2

# Build normal
sudo bash scripts/build_kali_hdd.sh --clean .

# Ver ayuda
sudo bash scripts/build_kali_hdd.sh --help
```

#### Paso 3 — Flashear al HDD externo
```bash
# ⚠ REEMPLAZA /dev/sdX con tu HDD externo (verifica con lsblk)
lsblk  # identificar el disco correcto

sudo dd if=EyeOfGod_KaliPurple_2025.3_HDD.iso \
         of=/dev/sdX \
         bs=4M status=progress && sync
```

> ⚠ **IMPORTANTE:** Asegúrate de que `/dev/sdX` sea el HDD externo y **NO** tu disco del sistema.

#### Paso 4 — Configurar persistencia (opcional pero recomendado)
```bash
# Sin cifrado
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX

# Con cifrado LUKS (recomendado)
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX --luks

# Sin confirmación (automatización)
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX --luks --force
```

---

### 🔹 Opción B — Windows (WSL + PowerShell)

#### Paso 1 — Configurar WSL con Kali Linux
```powershell
# PowerShell como ADMINISTRADOR
.\scripts\wsl_build.ps1 -SetupWsl
```
Esto instala WSL2 y la distribución Kali Linux automáticamente.

#### Paso 2 — Construir la ISO
```powershell
# PowerShell (no necesita admin para esto)
.\scripts\wsl_build.ps1 -Build
```
Esto copia el proyecto a WSL, instala dependencias, ejecuta el build, y trae la ISO de vuelta a Windows.

#### Paso 3 — Flashear la ISO a un USB/HDD
**Método 1 — PowerShell (automático):**
```powershell
# PowerShell como ADMINISTRADOR
.\scripts\flash_iso.ps1

# O especificando la ISO directamente
.\scripts\flash_iso.ps1 -IsoPath ".\EyeOfGod_KaliPurple_2025.3_HDD.iso" -Force
```

**Método 2 — Menú interactivo (doble click):**
Simplemente haz doble click en `scripts\flash_iso.bat` y selecciona la opción deseada.

**Método 3 — Rufus (recomendado si los scripts no funcionan):**
1. Descarga [Rufus](https://rufus.ie)
2. Abre Rufus, selecciona el USB/HDD externo
3. En "Selección de arranque", elige la ISO
4. Esquema de partición: **MBR** (o GPT si tu PC es UEFI)
5. Click **EMPEZAR**

#### Paso 4 — Configurar persistencia
La persistencia requiere Linux. Opciones:
- **WSL:** `wsl -d kali-linux` y sigue los pasos de Linux
- **Máquina virtual:** Arranca cualquier Linux Live y ejecuta el script
- **Bootea la ISO sin persistencia** primero y configura después desde Kali

---

### ⚠ Paso 5 para todos — Deshabilitar Secure Boot
En la BIOS/UEFI del equipo donde vas a bootear:
- `Secure Boot` → **Disabled**
- `Boot Order` → HDD externo primero
- Guarda y reinicia

### Paso 6 — Bootear
1. Conecta el HDD externo por USB 3.x (más rápido)
2. Al arrancar, presiona `F8`, `F11` o `F12` (según placa)
3. Selecciona el HDD externo
4. En el menú GRUB selecciona la opción deseada

---

## OPCIONES DE BOOT EN EL MENÚ GRUB

| Opción | Descripción |
|--------|-------------|
| `👁 EYE OF GOD V∞ × KALI PURPLE` | Boot principal, sin persistencia |
| `🟣 Kali Purple — Modo Defensivo NIST` | Blue team, herramientas NIST CSF |
| `🔴 Kali Purple — Modo Ofensivo MITRE` | Red team, herramientas MITRE ATT&CK |
| `💾 PERSISTENCIA EN HDD EXTERNO` | Guarda cambios entre reinicios |
| `🔐 PERSISTENCIA CIFRADA LUKS` | Igual pero cifrado |
| `🔐 PERSISTENCIA LUKS + NUKE` | Cifrado con opción de borrado de emergencia |
| `🖥 Instalar en HDD Externo` | Instalación completa (destructiva) |
| `Niveles 0 → ∞` | EyeGod skins temáticos (20 niveles) |
| `💾 Modo RAM (toram)` | Carga todo en RAM, libera el HDD |
| `Modo Forense` | Sin escritura en ningún disco |
| `Shell de Emergencia` | bash en initramfs para diagnóstico |
| `🧪 10,000 Subsistemas` | Entidades procedurales EyeGod |
| `🟣 Kali Purple — NIST CSF` | 6 toolsets: Identify, Protect, Detect, Respond, Recover, Malcolm |

---

## PERSISTENCIA — CÓMO FUNCIONA

Kali live-boot usa el sistema de **persistencia oficial de Kali**:

1. La ISO se flashea → crea 2 particiones (ISO + EFI tiny)
2. `setup_hdd_persistence.sh` crea una 3ª partición con label `persistence`
3. El archivo `persistence.conf` contiene `/ union`
4. Al bootear con la opción de persistencia, live-boot detecta automáticamente
   la partición por su label y monta un **overlayfs** encima del squashfs
5. Todos los cambios (archivos, configuración, herramientas instaladas) se
   guardan en esa partición y sobreviven al reinicio

Con LUKS: la partición está cifrada. live-boot pide la contraseña al boot.

---

## ESTRUCTURA DE PARTICIONES FINAL EN EL HDD

```
/dev/sdX
├── sdX1  ← ISO live (FAT32/ISO9660, ~4-8GB) — NO TOCAR
├── sdX2  ← EFI (FAT12, 8MB)                 — NO TOCAR
└── sdX3  ← Persistencia EyeGod/Kali (ext4, resto del disco)
             label: "persistence"
             contiene: persistence.conf  →  "/ union"
```

---

## PARÁMETROS DEL KERNEL USADOS

```
boot=live                     # Activa live-boot
live-media=removable          # Busca el medio en dispositivos removables/externos
live-media-path=/live         # Ruta al filesystem.squashfs dentro del medio
components quiet splash       # Boot limpio con splash
eyegod=true                   # Flag EyeGod para el init script
consciousness=SINGULARITY     # Nivel de consciencia al arrancar
persistence                   # (solo opciones de persistencia) Activa persistencia
persistence-encryption=luks   # (solo LUKS) Indica cifrado
```

---

## NOTAS

- **Secure Boot debe estar DESHABILITADO** — el kernel de Kali no está firmado
- Las credenciales del proyecto (Groq, Telegram, etc.) van en `/etc/eyegod/secrets`
- Con LUKS, sin la contraseña los datos son irrecuperables
- El HDD externo puede usarse en cualquier equipo compatible con BIOS/UEFI x86_64
- Si encuentras un directorio `{iso_root/` con nombres extraños, elimínalo con `rm -rf './{iso_root}'` y usa `--clean` la próxima vez
- Los scripts `.sh` requieren `sudo`; los scripts `.ps1` requieren PowerShell como **Administrador**

---

*"El Ojo no distingue entre HDD interno y externo. Todo lo ve."*
