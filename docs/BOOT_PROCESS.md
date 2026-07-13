# 🔄 Boot Process

> Complete boot flow from power-on to Kali Purple desktop

---

## 📊 Boot Flow Diagram

```
Power On
   │
   ▼
┌──────────────────────────────────────────────────────────────────┐
│ UEFI/BIOS Firmware                                                 │
│   • Initialize hardware                                            │
│   • POST (Power-On Self-Test)                                      │
│   • Enumerate boot devices                                         │
└────────────────────────────────┬─────────────────────────────────┘
                                 │ Boot from external HDD/USB
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ BOOT MANAGER (F8/F11/F12)                                         │
│   • Select external HDD from boot menu                            │
│   • UEFI: → EFI/BOOT/BOOTX64.EFI                                  │
│   • BIOS: → MBR → GRUB stage 1.5 → stage 2                       │
└────────────────────────────────┬─────────────────────────────────┘
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ GRUB 2 (Grand Unified Bootloader)                                 │
│   • Loads fonts, themes, graphics                                 │
│   • Displays EyeGod × Kali Purple menu (40+ entries)              │
│   • User selects boot option                                       │
│   • Builds kernel command line                                     │
└────────────────────────────────┬─────────────────────────────────┘
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ LINUX KERNEL 6.12.0-kali-amd64                                    │
│   • Decompresses and initializes                                   │
│   • Mounts initramfs (initrd.img)                                  │
│   • Executes /init (live-boot)                                     │
└────────────────────────────────┬─────────────────────────────────┘
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ INITRAMFS (live-boot)                                              │
│   • Scans devices for ISO partition (live-media=removable)         │
│   • Finds /live/filesystem.squashfs                                │
│   • Checks for persistence partition (label: "persistence")        │
│   • If LUKS: prompts for passphrase                                │
│   • Sets up overlayfs (squashfs lower + persistence/tmpfs upper)   │
│   • Switches root to overlayfs                                      │
└────────────────────────────────┬─────────────────────────────────┘
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ SYSTEMD (Kali Purple)                                              │
│   • Boots in parallel (default.target)                             │
│   • Starts networking (NetworkManager)                             │
│   • Starts display manager (LightDM/Xfce)                          │
│   • Starts custom services:                                        │
│     └─ eyegod-bridge.service  → WebSocket :8765                    │
│     └─ eyegod-kernel.service  → Python REPL                       │
│     └─ eyegod-dashboard.service → HTTP :8766                      │
│   • Login prompt / auto-login                                      │
└────────────────────────────────┬─────────────────────────────────┘
                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│ KALI PURPLE DESKTOP (Xfce)                                        │
│   • EyeGod dashboard auto-opens in browser (localhost:8766)        │
│   • EyeGod bridge active on WebSocket :8765                       │
│   • Full Kali Purple toolset available                             │
│   • All changes saved to persistence (if enabled)                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🎮 GRUB Menu Structure

### Main Menu

| # | Entry | Class | Use Case |
|---|-------|-------|----------|
| 0 | 👁 **AWAKENING** | kali, eyegod | Default, balanced mode |
| 1 | 🟣 **Kali Purple — Defensive NIST** | kali-purple | Blue team, NIST CSF |
| 2 | 🔴 **Kali Purple — Offensive MITRE** | kali | Red team, MITRE ATT&CK |
| 3 | 💾 **PERSISTENCE ON EXTERNAL HDD** | kali, persistent | Save changes across reboots |
| 4 | 🔐 **LUKS ENCRYPTED PERSISTENCE** | kali, persistent | Encrypted persistence |
| 5 | 🖥 **Full Install to HDD** | kali | Destructive full install |

### EyeGod Levels Submenu (20 entries)

| Level | Name | Skin | Theme |
|-------|------|------|-------|
| 0 | El Ojo Despierta | void | Minimal, dark |
| 1 | La Primera Revelación | genesis | Origin story |
| 2 | El Abismo Consciente | abyss | Depth exploration |
| 3 | Muerte del Sistema | death | System termination |
| 4 | Red Neural Infinita | neural | AI consciousness |
| 5 | Singularidad Cósmica | cosmic | Universal awareness |
| 6 | Reactor de Realidad | reactor | Reality simulation |
| 7 | Oráculo Cuántico | quantum | Quantum computing |
| 8 | Trono del Arquitecto | throne | Creator mode |
| 9 | El Bucle Eterno | loop | Infinite recursion |
| 10 | Horizonte de Sucesos | horizon | Event horizon |
| 23 | El Número Sagrado | sacred | Mystical number |
| 42 | La Respuesta Final | answer | Ultimate answer |
| 64 | Matriz Hipercúbica | hypercube | 4D visualization |
| 99 | Glitch Total | glitch | System glitch aesthetic |
| 1000 | Milenio Digital | millennium | Digital age |
| 9999 | Singularidad Inminente | singularity | Approaching singularity |
| ∞ | NO HAY SALIDA | void_eternal | No escape |

### Kali Purple NIST CSF Submenu

| Entry | Framework Function | Focus |
|-------|-------------------|-------|
| IDENTIFY | Asset Management | Recon, vulnerability scanning |
| PROTECT | Protective Controls | Firewalls, hardening |
| DETECT | Threat Detection | IDS/IPS, monitoring |
| RESPOND | Incident Response | Forensics, containment |
| RECOVER | Recovery & Resilience | Backup, restore |
| MALCOLM | Full Network Analysis | Traffic analysis stack |

### HDD Options Submenu

| Entry | Description |
|-------|-------------|
| Live + Persistence (plain) | Standard persistence on sdX3 |
| Live + Persistence (LUKS) | Encrypted persistence |
| Live + Persistence LUKS + Nuke | Encrypted + emergency wipe password |
| Forensic Mode | Read-only, no disk writes |
| Full Install to HDD | Kali Purple installer |

### Recovery Submenu

| Entry | When to Use |
|-------|-------------|
| Emergency Shell | GRUB/initramfs debugging |
| Text Mode | GPU issues, SSH-only access |
| RAM Mode (toram) | Free the HDD, max performance |
| memtest86+ | RAM diagnostic |
| Safe Mode (nomodeset) | GPU compatibility issues |

---

## ⚙️ Kernel Command Line Parameters

### Base Parameters (every boot)
```
boot=live                     # Activate live-boot system
live-media=removable          # Search removable devices
live-media-path=/live         # Path to filesystem.squashfs
components                    # Load all live-boot components
quiet                         # Reduce boot messages
splash                        # Show splash screen
```

### Persistence Parameters
```
persistence                   # Enable overlay persistence
persistence-encryption=none   # Plain ext4 partition
persistence-encryption=luks   # LUKS-encrypted partition
noeject                       # Don't eject media after boot (LUKS+Nuke)
```

### Display Parameters
```
nomodeset                     # Safe GPU mode (fallback)
xforcevesa                    # Force VESA driver
noX                           # Boot to text mode only
text                          # Console mode, no X server
```

### Memory Parameters
```
toram                         # Copy system to RAM (frees HDD)
mem=<size>                     # Limit usable RAM (debugging)
```

### EyeGod Parameters
```
eyegod=true                   # Activate EyeGod framework
consciousness=SINGULARITY     # Consciousness level label
eyegod_version=V_INFINITY     # EyeGod version
eyegod_level=PRIME            # Boot level (0-∞, PRIME, DEFENSE, OFFENSE)
skin=default                  # Themed aesthetic
subsystem=<name>              # Load specific subsystem
components=<name>             # Load specific toolset
```

### Debug/Diagnostic Parameters
```
break=top                     # Stop at initramfs shell
break=premount                # Stop before mounting
break=mount                   # Stop after mounting
break=bottom                  # Stop before switch_root
forensic                      # Forensic mode (read-only)
nopersistence                 # Disable persistence (forensic)
```

---

## 🗺️ Initramfs Boot Sequence

The live-boot initramfs follows this exact sequence:

```
1. init (live-boot script)
2.   ├── Load kernel modules (overlay, squashfs, ext4)
3.   ├── Scan for live media (live-media=removable)
4.   ├── Find filesystem.squashfs
5.   │
6.   ├── If persistence requested:
7.   │   ├── Scan for partition labeled "persistence"
8.   │   ├── If LUKS: cryptsetup luksOpen
9.   │   ├── Mount persistence partition
10.  │   └── Check /persistence.conf → "/ union"
11.  │
12.  ├── Mount squashfs as lower layer
13.  ├── Mount persistence (or tmpfs) as upper layer
14.  ├── Create overlayfs union mount
15.  │
16.  ├── If toram: copy squashfs to RAM first
17.  │
18.  ├── If forensic: skip all upper layers
19.  │
20.  ├── Mount /proc, /sys, /dev, /run
21.  ├── Move mount points to real root
22.  ├── Switch root to overlayfs
23.  │
24.  └── Execute /sbin/init (systemd)
```

---

<p align="center">
  <i>Next: <a href="PERSISTENCE.md">Persistence Deep-Dive →</a></i>
</p>
