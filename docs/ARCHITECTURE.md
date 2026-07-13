# 🏗️ System Architecture

> **Eye of God V∞ × Kali Purple** — Architecture Overview
> Kernel 6.12.0-kali-amd64 | Kali Linux 2025.3 | BIOS+UEFI Hybrid Boot

---

## 📐 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      PHYSICAL LAYER                                  │
│  External HDD/USB 3.x (32GB+ recommended, 128GB+)                   │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────────┐
│                      BOOT LAYER                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  BIOS/UEFI → GRUB2 → Kernel 6.12 → initrd → live-boot        │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────────┐
│                      SYSTEM LAYER (overlayfs)                        │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────────┐   │
│  │ squashfs RO  │  │  persistence │  │      tmpfs (RAM)         │   │
│  │ (read-only)  │  │  (ext4/LUKS) │  │  /run, /tmp, /var/log   │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────────────────────┘   │
│         └─────────────────┴────────────────┘                        │
│                         │ overlayfs                                 │
│                         ▼                                            │
│              ┌──────────────────┐                                   │
│              │  Unified Root FS │                                   │
│              └──────────────────┘                                   │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────────────┐
│                      EYEGOD FRAMEWORK                                │
│  ┌────────────────┐  ┌───────────────┐  ┌──────────────────────┐   │
│  │  EyeGod Kernel  │  │  Bridge WS    │  │  10,000 Subsystems   │   │
│  │  (Python REPL)  │  │  :8765        │  │  (Procedural)        │   │
│  └───────┬────────┘  └──────┬────────┘  └──────────────────────┘   │
│          └──────────────────┴──────────────┘                        │
│                         ▼                                            │
│              ┌──────────────────┐                                   │
│              │  HTTP Dashboard  │                                   │
│              │  :8766           │                                   │
│              └──────────────────┘                                   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🗂️ Component Breakdown

### 1️⃣ Physical Layer — External HDD Partition Layout

```
/dev/sdX (External HDD, 32GB+)
├── sdX1  [ISO9660/FAT32]  ← Live ISO partition (~4-8GB)
│   ├── /boot/grub/grub.cfg
│   ├── /live/vmlinuz-6.12.0-kali-amd64
│   ├── /live/initrd.img-6.12.0-kali-amd64
│   ├── /live/filesystem.squashfs
│   └── /live/filesystem.size
│
├── sdX2  [FAT12, 8MB]     ← EFI System Partition
│   └── /EFI/BOOT/BOOTX64.EFI
│
└── sdX3  [ext4/LUKS]      ← Persistence Partition (rest of disk)
    └── /persistence.conf  →  "/ union"
```

### 2️⃣ Boot Layer — GRUB2 Configuration

The GRUB configuration (`iso_root/boot/grub/grub.cfg`) provides 40+ boot entries organized into:

- **Main Menu:** 6 primary entries (AWAKENING, Defensive, Offensive, Persistence, LUKS, Install)
- **EyeGod Levels:** 20 levels (0 → ∞) with themed skins
- **NIST CSF Submenu:** 6 toolsets (Identify, Protect, Detect, Respond, Recover, Malcolm)
- **HDD Options Submenu:** 5 entries (persistence variants, forensic, full install)
- **Subsystems Submenu:** 8 showcase subsystems + procedural generator
- **Recovery Submenu:** 5 entries (emergency shell, text mode, RAM mode, memtest, safe mode)

**Kernel Parameters:**
```
boot=live                     # Activate live-boot
live-media=removable          # Scan removable devices
live-media-path=/live         # Path to squashfs
components quiet splash       # Clean boot with splash
eyegod=true                   # EyeGod init flag
consciousness=SINGULARITY     # Consciousness level
persistence                   # Enable persistence overlay
persistence-encryption=luks   # LUKS encryption indicator
```

### 3️⃣ System Layer — Live-Boot Stack

Kali's `live-boot` system uses **overlayfs** to create a writable environment:

```
                 ┌─────────────────────────┐
                 │   / (merged view)        │
                 │   overlayfs (rw)         │
                 └────────┬───────┬────────┘
                          │       │
           ┌──────────────▼┐   ┌──▼──────────────┐
           │ lower (ro)     │   │ upper (rw)       │
           │ squashfs       │   │ persistence.ext4 │
           │ Kali OS        │   │ or tmpfs (no     │
           │                │   │ persistence)     │
           └────────────────┘   └──────────────────┘
```

**Persistence Modes:**
| Mode | Upper Layer | Data Survival |
|------|-------------|---------------|
| None | tmpfs (RAM) | ❌ Lost on reboot |
| Plain | ext4 on sdX3 | ✅ Saved on HDD |
| LUKS | LUKS-encrypted ext4 | ✅ Encrypted, saved on HDD |
| Forensic | None (read-only) | ❌ No writes to any disk |
| RAM (toram) | tmpfs (preloaded) | ❌ Lost on reboot, faster |

### 4️⃣ EyeGod Framework

The EyeGod framework consists of 3 systemd services:

| Service | Port | Function |
|---------|------|----------|
| `eyegod-kernel.service` | — | Python REPL kernel, manages subsystems |
| `eyegod-bridge.service` | 8765 (WebSocket) | Real-time bridge for external tools |
| `eyegod-dashboard.service` | 8766 (HTTP) | Web-based management dashboard |

**Configuration files:**
```
/etc/eyegod/config           # Main EyeGod configuration
/etc/eyegod/secrets          # API keys (Groq, Telegram, etc.)
/etc/eyegod/secrets.template # Template for secrets
/opt/eyegod/                 # EyeGod application files
/var/eyegod/subsystems/      # Procedural subsystem storage
```

---

## 🔄 Build Process Flow

```
Source Files
    │
    ▼
┌──────────────────────────────────────────────────────┐
│ build_kali_hdd.sh                                     │
│                                                        │
│  Step 1: Verify dependencies                           │
│  Step 2: Create directory structure                    │
│  Step 3: Obtain Kali kernel 6.12                       │
│     ├── From /boot/ (running Kali)                     │
│     ├── From apt (.deb download)                       │
│     └── Fallback: any existing kernel                  │
│  Step 4: Build root filesystem                         │
│     ├── debootstrap Kali (primary method)              │
│     ├── Install Kali Purple packages                   │
│     └── Install Python dependencies                    │
│  Step 5: Copy EyeGod files                             │
│  Step 6: System configuration                          │
│  Step 7: Package squashfs                              │
│  Step 8: Install GRUB (BIOS + UEFI)                    │
│  Step 9: Generate hybrid ISO with xorriso              │
│  Step 10: Display flash instructions                   │
└──────────────────────────────────────────────────────┘
    │
    ▼
EyeOfGod_KaliPurple_2025.3_HDD.iso
    │
    ├──▶ dd to HDD (Linux) ◀── flash_iso.ps1 (Windows)
    │
    ▼
┌──────────────────────────────────────────────────────┐
│ setup_hdd_persistence.sh                              │
│                                                        │
│  1. Detect existing ISO partitions                     │
│  2. Create 3rd partition (ext4 or LUKS)               │
│  3. Format & label as "persistence"                    │
│  4. Write /persistence.conf → "/ union"               │
└──────────────────────────────────────────────────────┘
```

---

## 🔐 Security Architecture

```
Boot Security:
├── Secure Boot: ⚠ DISABLED (Kali kernel not signed)
├── UEFI Boot: Supported via BOOTX64.EFI
└── BIOS Boot: Supported via isolinux/GRUB MBR

Persistence Security:
├── Plain Mode: Data visible if HDD accessed externally
└── LUKS Mode: AES-XTS encryption, password required at boot
    └── cryptsetup luksFormat --type luks2

EyeGod Secrets:
├── /etc/eyegod/secrets (root-only access)
├── API keys for Groq, Telegram, admin
└── Template provided; user must populate
```

---

## 🪟 Windows Support Architecture

```
Windows 10/11
    │
    ├── Native: flash_iso.ps1
    │   ├── Detects: dd, Rufus, balenaEtcher
    │   ├── Lists disks safely (excludes system disks)
    │   └── Flashes ISO with progress
    │
    └── WSL2: wsl_build.ps1
        ├── Installs WSL + Kali Linux (SetupWsl mode)
        ├── Copies project to WSL via tar pipeline
        └── Runs build_kali_hdd.sh inside WSL (Build mode)
            └── Returns ISO to Windows desktop
```

---

## 📊 Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Hybrid ISO** (BIOS+UEFI) | Maximum compatibility across hardware |
| **Squashfs + overlayfs** | Official Kali live-boot method, proven reliability |
| **LUKS2** | Modern encryption, stronger KDF options |
| **GRUB2** | Most flexible bootloader, theme support |
| **debootstrap** | Minimal rootfs, then add packages (bandwidth efficient) |
| **PowerShell + WSL** | Only way to build Linux ISOs on Windows natively |
| **xorriso** | De facto standard for hybrid ISO generation |

---

<p align="center">
  <i>Next: <a href="BUILD_GUIDE.md">Build Guide →</a></i>
</p>
