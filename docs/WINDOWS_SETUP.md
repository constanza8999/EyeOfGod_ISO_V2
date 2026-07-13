# 🪟 Windows Setup Guide

> Complete guide to building and flashing the Eye of God ISO on Windows

---

## 📋 Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Windows 10 (build 19041+) or Windows 11 |
| **PowerShell** | Version 5.1+ (built-in) or PowerShell 7+ |
| **WSL2** | Windows Subsystem for Linux v2 |
| **Virtualization** | Enabled in BIOS (for WSL2) |
| **Disk Space** | 20 GB free for WSL + build |
| **Admin Rights** | Required for flashing ISO and WSL setup |

---

## 🔧 Option 1: Build via WSL (Full Build)

### Step 1 — Run the Setup Wizard

**PowerShell (as Administrator):**
```powershell
# Navigate to project
cd C:\path\to\EyeOfGod_ISO_V2

# Setup WSL with Kali Linux (one-time)
.\scripts\wsl_build.ps1 -SetupWsl
```

**What this does:**
1. ✅ Checks if WSL is installed
2. ✅ Enables WSL2 as default
3. 📥 Downloads and installs Kali Linux from Microsoft Store
4. ❗ You'll be prompted to create a Linux username/password

> **Troubleshooting:** If WSL installation fails, run manually:
> ```powershell
> wsl --install -d kali-linux
> ```

### Step 2 — Build the ISO

**PowerShell (any terminal):**
```powershell
.\scripts\wsl_build.ps1 -Build
```

**What this does:**
1. 📁 Copies project files into WSL (`/home/<user>/eyegod_iso_v2/`)
2. 📦 Installs build dependencies (xorriso, debootstrap, etc.)
3. 🔨 Runs the build script (takes 30-60 minutes)
4. 📀 Copies generated ISO to your Windows Desktop

### Step 3 — Flash to USB/HDD

**Method A — PowerShell Script (Admin):**
```powershell
# As Administrator
.\scripts\flash_iso.ps1 -IsoPath "C:\Users\You\Desktop\EyeOfGod_KaliPurple_2025.3_HDD.iso"
```

**Method B — Double-click Menu:**
```
Double-click scripts\flash_iso.bat
Select: [1] Flashear ISO a USB/HDD
```

**Method C — Rufus (Manual):**
1. Download [Rufus](https://rufus.ie)
2. Select your USB/HDD device
3. Click "SELECT" and choose the ISO
4. Partition scheme: **MBR** (BIOS) or **GPT** (UEFI)
5. Click **START**

---

## 💿 Option 2: Download & Flash Only

If you just want to flash a pre-built ISO (no build needed):

```powershell
# PowerShell as Administrator
.\scripts\flash_iso.ps1 -IsoPath "D:\Downloads\EyeOfGod.iso"
```

The script will:
1. ✅ Detect available flash tools (dd, Rufus, balenaEtcher)
2. 🛡️ Show available disks (with system disk protection)
3. ⚠️ Require confirmation before writing
4. 💽 Flash the ISO to the selected disk

---

## 🛠️ Manual WSL Build (Without the Script)

If you prefer to do it step by step:

```powershell
# 1. Open Kali WSL
wsl -d kali-linux

# 2. Inside WSL:
cd /home/$(whoami)
mkdir eyegod_iso_v2

# 3. Copy project from Windows (in WSL):
#    Windows path: /mnt/c/Users/YourName/.../EyeOfGod_ISO_V2
cp -r /mnt/c/Users/$(whoami)/Desktop/EyeOfGod_ISO_V2/* eyegod_iso_v2/

# 4. Install dependencies (in WSL):
sudo apt update
sudo apt install -y xorriso squashfs-tools debootstrap \
    grub-pc-bin grub-efi-amd64-bin grub-efi-amd64 \
    mtools dosfstools live-build live-boot \
    cryptsetup-bin curl wget python3 python3-pip memtest86+

# 5. Build (in WSL):
cd eyegod_iso_v2
sudo bash scripts/build_kali_hdd.sh --clean .

# 6. Copy ISO back to Windows:
cp EyeOfGod_KaliPurple_2025.3_HDD.iso /mnt/c/Users/$(whoami)/Desktop/
```

---

## 🪟 PowerShell Scripts Reference

### `flash_iso.ps1`

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-IsoPath` | Path to the ISO file | `-IsoPath ".\image.iso"` |
| `-DiskNumber` | Disk number to flash to | `-DiskNumber 2` |
| `-ListDisks` | List available disks and exit | `-ListDisks` |
| `-Force` | Skip confirmation prompts | `-Force` |
| `-Help` | Show help | `-Help` |

### `wsl_build.ps1`

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-SetupWsl` | Install/verify WSL with Kali | `-SetupWsl` |
| `-Build` | Build the ISO in WSL | `-Build` |
| `-Help` | Show help | `-Help` |

---

## ❗ Common Windows Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| **WSL not found** | WSL not installed | Run `wsl --install` as Admin |
| **Virtualization error** | VT-x/AMD-V disabled | Enable in BIOS settings |
| **Kali distro not found** | Different distro name | Check with `wsl -l -v` |
| **Permission denied** | PowerShell not Admin | Right-click → Run as Administrator |
| **dd.exe not found** | Flash tool missing | Use Rufus instead (download from rufus.ie) |
| **ISO not found** | Wrong path | Use absolute path with `-IsoPath` |
| **WSL build hangs** | WSL first-time setup | Complete user creation in Kali terminal |

---

<p align="center">
  <i>Next: <a href="TROUBLESHOOTING.md">Troubleshooting →</a></i>
</p>
