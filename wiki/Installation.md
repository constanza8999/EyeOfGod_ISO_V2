# 🚀 Installation Guide

## Linux

### Prerequisites
```bash
sudo apt install -y xorriso squashfs-tools grub-pc-bin grub-efi-amd64-bin \
    mtools dosfstools live-build live-boot debootstrap cryptsetup-bin \
    curl wget python3 python3-pip memtest86+
```

### Build
```bash
git clone https://github.com/constanza8999/EyeOfGod_ISO_V2.git
cd EyeOfGod_ISO_V2
sudo bash scripts/build_kali_hdd.sh --clean .
```

### Flash
```bash
# ⚠ Replace /dev/sdX with your external HDD!
sudo dd if=EyeOfGod_KaliPurple_2025.3_HDD.iso of=/dev/sdX bs=4M status=progress && sync

# Optional: set up persistence
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX --luks
```

## Windows (WSL2)

### PowerShell (Admin)
```powershell
# One-time WSL setup
.\scripts\wsl_build.ps1 -SetupWsl

# Build the ISO
.\scripts\wsl_build.ps1 -Build

# Flash
.\scripts\flash_iso.ps1
```

## BIOS Settings
1. Disable **Secure Boot**
2. Set **Boot Order**: External HDD first
3. Save and reboot

## First Boot
1. Select a GRUB entry
2. If using LUKS, enter your passphrase when prompted
3. Login to Kali Purple
4. Set passwords: `sudo passwd` and `passwd`
