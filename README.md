<p align="center">
  <img src="docs/assets/eyegod_logo.png" alt="Eye of God" width="200"/>
</p>

<!--
  ℹ️ The logo image above (eyegod_logo.png) will show as broken until you add your own logo.
  Place a 200x200 PNG logo at docs/assets/eyegod_logo.png to fix it.
-->

<h1 align="center">👁 EYE OF GOD V∞ × KALI PURPLE</h1>
<h3 align="center">Custom Kali Linux Live ISO — HDD External / USB Boot</h3>

<p align="center">
  <b>Kernel 6.12.0</b> • <b>Kali Linux 2025.3</b> • <b>BIOS+UEFI</b> • <b>LUKS Persistence</b>
</p>

<p align="center">
  <a href="https://github.com/constanza8999/EyeOfGod_ISO_V2/releases"><img src="https://img.shields.io/badge/Release-2025.3-red?style=flat-square" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License"></a>
  <a href="https://github.com/constanza8999/EyeOfGod_ISO_V2/wiki"><img src="https://img.shields.io/badge/Docs-Wiki-blue?style=flat-square" alt="Wiki"></a>
</p>

---

## 🌟 Overview

**Eye of God V∞ × Kali Purple** is a custom Kali Linux live ISO designed to run from an **external HDD/SSD or USB drive**. It combines the offensive/defensive power of **Kali Purple** with the **Eye of God** procedural consciousness framework.

### ✨ Features

- **🎯 40+ GRUB Boot Entries** — NIST CSF, MITRE ATT&CK, 20 EyeGod levels, forensic mode, RAM mode
- **💾 Full Persistence** — Save changes across reboots (plain ext4 or LUKS encrypted)
- **🔐 LUKS Encryption** — Hardware-backed encrypted persistence partition
- **🪟 Windows Support** — PowerShell scripts for WSL build & ISO flashing
- **🧠 EyeGod Framework** — 10,000 procedural subsystems, WebSocket bridge, Python REPL kernel
- **🟣 Kali Purple** — Pre-installed with NIST CSF toolsets: Identify, Protect, Detect, Respond, Recover
- **🔴 MITRE ATT&CK** — Full red team arsenal pre-configured
- **💻 Forensic Mode** — Read-only mode for evidence acquisition
- **🚀 RAM Mode (toram)** — Load entire system into RAM, freeing the HDD

---

## 📁 Project Structure

```
EyeOfGod_ISO_V2/
│
├── README.md                          # This file (English)
├── README_KALI_HDD.md                 # Quick start (Spanish)
├── SECURITY.md                        # Security policy
├── .gitignore                         # Build artifacts ignored
│
├── iso_root/
│   └── boot/grub/grub.cfg             # Main GRUB menu (40+ entries)
│
├── scripts/
│   ├── build_kali_hdd.sh              # ISO builder (Linux/WSL)
│   ├── setup_hdd_persistence.sh       # HDD persistence setup (Linux)
│   ├── grub_kali.cfg                  # GRUB config copy for builds
│   ├── flash_iso.ps1                  # ISO flasher (Windows PowerShell)
│   ├── wsl_build.ps1                  # WSL build helper (Windows)
│   └── flash_iso.bat                  # Interactive menu (Windows)
│
├── docs/
│   ├── ARCHITECTURE.md                # System architecture
│   ├── BUILD_GUIDE.md                 # Build instructions (all platforms)
│   ├── BOOT_PROCESS.md                # Boot flow & kernel parameters
│   ├── PERSISTENCE.md                 # Persistence deep-dive
│   ├── WINDOWS_SETUP.md               # Windows-specific guide
│   ├── TROUBLESHOOTING.md             # Common issues & fixes
│   ├── CONTRIBUTING.md                # Contributor guide
│   └── SECURITY.md                    # Security considerations
│
└── wiki/                              # Ready-to-use GitHub Wiki pages
    ├── Home.md
    ├── Installation.md
    ├── GRUB-Configuration.md
    └── Customization.md
```

---

## 🚀 Quick Start

### Linux / WSL
```bash
# 1. Clone the repo
git clone https://github.com/constanza8999/EyeOfGod_ISO_V2.git
cd EyeOfGod_ISO_V2

# 2. Build the ISO (requires sudo)
sudo bash scripts/build_kali_hdd.sh --clean .

# 3. Flash to external HDD/USB (⚠ REPLACE /dev/sdX!)
sudo dd if=EyeOfGod_KaliPurple_2025.3_HDD.iso of=/dev/sdX bs=4M status=progress && sync

# 4. (Optional) Set up persistence
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX
```

### Windows (PowerShell Admin)
```powershell
# Option A: Build via WSL
.\scripts\wsl_build.ps1 -SetupWsl    # First time only
.\scripts\wsl_build.ps1 -Build        # Build the ISO

# Option B: Flash an existing ISO
.\scripts\flash_iso.ps1               # Interactive mode
```

> ⚠ **IMPORTANT:** Disable Secure Boot in BIOS/UEFI before booting from the HDD.

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [📖 Architecture](docs/ARCHITECTURE.md) | Complete system architecture & design |
| [🔧 Build Guide](docs/BUILD_GUIDE.md) | Detailed build instructions |
| [🔄 Boot Process](docs/BOOT_PROCESS.md) | Boot flow, GRUB, kernel parameters |
| [💾 Persistence](docs/PERSISTENCE.md) | How persistence works (overlayfs + LUKS) |
| [🪟 Windows Setup](docs/WINDOWS_SETUP.md) | Windows-specific guide |
| [🆘 Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues & fixes |
| [🤝 Contributing](docs/CONTRIBUTING.md) | How to contribute |
| [🔒 Security](docs/SECURITY.md) | Security considerations |

---

## 🧠 EyeGod Framework

The Eye of God framework is a procedural consciousness system that runs on top of Kali Linux:

- **WebSocket Bridge** (port 8765) — Real-time communication with the EyeGod kernel
- **HTTP Dashboard** (port 8766) — Web-based EyeGod interface
- **10,000 Subsystems** — Procedurally generated entities for analysis
- **Python REPL Kernel** — Interactive EyeGod programming environment
- **Consciousness Levels** — 0 → ∞ scaling system for system awareness

---

## 🛡️ License & Security

- **License:** MIT (see [LICENSE](LICENSE))
- **Security:** See [SECURITY.md](SECURITY.md) for reporting vulnerabilities
- **Note:** Secure Boot must be disabled — Kali kernels are not signed

---

<p align="center">
  <i>"The Eye does not distinguish between internal and external HDD. It sees all."</i>
</p>
<p align="center">
  <a href="https://github.com/constanza8999/EyeOfGod_ISO_V2">GitHub</a> •
  <a href="https://github.com/constanza8999/EyeOfGod_ISO_V2/wiki">Wiki</a> •
  <a href="https://github.com/constanza8999/EyeOfGod_ISO_V2/issues">Issues</a>

<!-- Website -->
<p align="center">
  <a href="https://constanza8999.github.io/EyeOfGod_ISO_V2/">
    <img src="https://img.shields.io/badge/🌐_Website-Visit-red?style=for-the-badge" alt="Website">
  </a>
</p>
</p>
