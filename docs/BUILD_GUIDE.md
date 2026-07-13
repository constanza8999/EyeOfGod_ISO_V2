# 🔧 Build Guide

> How to build the Eye of God V∞ × Kali Purple ISO on any platform

---

## 📋 Prerequisites

### Hardware
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4 GB | 8 GB+ |
| Disk Space | 15 GB free | 30 GB+ free |
| Internet | Broadband | 100 Mbps+ |
| Target HDD/USB | 32 GB | 128 GB+ |

### Software
- **Linux:** Kali Linux, Debian 12+, or Ubuntu 22.04+
- **Windows:** Windows 10 build 19041+ or Windows 11 (for WSL2)
- **macOS:** Not natively supported (use Docker or VM)

---

## 🐧 Linux Build

### Step 1: Install Dependencies
```bash
# Kali / Debian / Ubuntu
sudo apt update
sudo apt install -y \
    xorriso squashfs-tools \
    grub-pc-bin grub-efi-amd64-bin grub-efi-amd64 \
    mtools dosfstools \
    live-build live-boot live-boot-initramfs-tools \
    debootstrap cryptsetup \
    curl wget python3 python3-pip \
    memtest86+
```

### Step 2: Clone & Build
```bash
# Clone the repository
git clone https://github.com/constanza8999/EyeOfGod_ISO_V2.git
cd EyeOfGod_ISO_V2

# Build the ISO (with sudo)
sudo bash scripts/build_kali_hdd.sh --clean .

# Options:
#   --clean, -c    Remove previous build directory before starting
#   --help, -h     Show help
#
# You can also specify a source directory:
#   sudo bash scripts/build_kali_hdd.sh --clean /path/to/source
```

**What happens during the build:**
1. ⏳ Dependency verification (15 seconds)
2. 📁 Directory structure creation
3. 📦 Kernel acquisition (vmlinuz + initrd)
4. 🔨 Root filesystem via debootstrap (15-30 minutes)
5. 🐍 Python dependency installation
6. 🟣 Kali Purple package installation
7. ⚡ EyeGod file copy
8. ⚙️ System configuration (hostname, secrets template)
9. 📀 SquashFS packaging (5-10 minutes)
10. 🎛️ GRUB installation (BIOS + UEFI)
11. 💿 Hybrid ISO generation with xorriso
12. ✅ Final ISO output

> **Total time:** 30-60 minutes depending on internet speed and CPU.

### Step 3: Flash to HDD/USB
```bash
# ⚠ CRITICAL: Identify the correct disk
lsblk

# ⚠ REPLACE /dev/sdX with your EXTERNAL HDD (NOT your system disk!)
sudo dd if=EyeOfGod_KaliPurple_2025.3_HDD.iso \
         of=/dev/sdX \
         bs=4M status=progress && sync
```

### Step 4: Set Up Persistence
```bash
# Without encryption (visible data if HDD is accessed)
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX

# With LUKS encryption (recommended for sensitive data)
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX --luks

# Automated (skip confirmation)
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX --luks --force
```

---

## 🪟 Windows Build (WSL2)

### Prerequisites
- Windows 10 build 19041+ or Windows 11
- PowerShell 5.1+ (or PowerShell Core)
- Virtualization enabled in BIOS

### Step 1: Set Up WSL (one-time)
**Run PowerShell as Administrator:**
```powershell
cd EyeOfGod_ISO_V2
.\scripts\wsl_build.ps1 -SetupWsl
```

This will:
1. ✅ Check if WSL is installed (install if not)
2. ✅ Set WSL 2 as default version
3. ✅ Install Kali Linux distribution from Microsoft Store
4. ❗ On first install, you'll need to create a UNIX username/password

### Step 2: Build the ISO
```powershell
# PowerShell (does NOT require admin for this step)
.\scripts\wsl_build.ps1 -Build
```

This will:
1. ✅ Copy the project to WSL (`/home/$USER/eyegod_iso_v2/`)
2. ✅ Install build dependencies inside WSL
3. 🔨 Run `build_kali_hdd.sh` inside WSL
4. ✅ Copy the generated ISO to your Windows Desktop

### Step 3: Flash to HDD/USB from Windows

**Option A — PowerShell Script (Admin):**
```powershell
# PowerShell as Administrator
.\scripts\flash_iso.ps1

# Or specify the ISO directly
.\scripts\flash_iso.ps1 -IsoPath ".\EyeOfGod_KaliPurple_2025.3_HDD.iso"
```

**Option B — Batch Menu (Double-click):**
```
Double-click: scripts\flash_iso.bat
Select option 1: "Flashear ISO a USB/HDD"
```

**Option C — Rufus (GUI):**
1. Download [Rufus](https://rufus.ie)
2. Select your USB/HDD
3. Choose the ISO file
4. Partition scheme: **MBR** (or **GPT** for UEFI-only systems)
5. Click **START**

---

## 🐳 Docker Build (Alternative)

If you don't have a Kali Linux system, you can build using Docker:

```bash
# Create a Dockerfile
cat > Dockerfile << 'EOF'
FROM kalilinux/kali-rolling
RUN apt update && apt install -y \
    xorriso squashfs-tools grub-pc-bin grub-efi-amd64-bin \
    mtools dosfstools live-build live-boot debootstrap \
    cryptsetup-bin curl wget python3 python3-pip
WORKDIR /build
COPY . .
CMD ["bash", "scripts/build_kali_hdd.sh", "--clean", "."]
EOF

# Build the Docker image
docker build -t eyegod-builder .

# Run the build (output ISO will be in current directory)
docker run --privileged -v "$(pwd):/build" eyegod-builder
```

> **Note:** Docker builds may be slower due to filesystem overhead.

---

## 🧪 Testing with QEMU

Before flashing to real hardware, test the ISO in QEMU:

```bash
# Install QEMU
sudo apt install -y qemu-system-x86-64

# Boot the ISO
qemu-system-x86_64 \
    -m 4096 \
    -enable-kvm \
    -cdrom EyeOfGod_KaliPurple_2025.3_HDD.iso \
    -boot d \
    -vga virtio

# Test with persistence (create a virtual HDD)
qemu-img create -f qcow2 test_persist.qcow2 20G
qemu-system-x86_64 \
    -m 4096 \
    -enable-kvm \
    -cdrom EyeOfGod_KaliPurple_2025.3_HDD.iso \
    -drive file=test_persist.qcow2,format=qcow2 \
    -boot d \
    -vga virtio
```

---

## ⚠️ Common Build Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| `debootstrap` fails | No internet or mirror down | Check internet; try again with different mirror |
| Kernel not found | Not running Kali | Use `--clean` with downloaded `.deb` |
| `xorriso` missing | Dependency not installed | `sudo apt install xorriso` |
| Permission denied | Missing sudo | Prepend `sudo` to the command |
| ISO too large for target | Target HDD too small | Use HDD ≥ 32GB |
| WSL build hangs | WSL first-time setup | Complete user creation in Kali console |

---

<p align="center">
  <i>Next: <a href="BOOT_PROCESS.md">Boot Process →</a></i>
</p>
