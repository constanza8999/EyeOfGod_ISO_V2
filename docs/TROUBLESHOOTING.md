# 🆘 Troubleshooting Guide

> Common issues and solutions for Eye of God V∞ × Kali Purple

---

## 🔨 Build Issues

### `debootstrap` Fails

**Symptoms:**
- `debootstrap` exits with error
- "Couldn't find these debs"
- "Failed to download release files"

**Solutions:**
```bash
# 1. Check internet connectivity
curl -I https://http.kali.org

# 2. Try a different mirror
# Edit build_kali_hdd.sh:
# Change: https://http.kali.org/kali
# To:     https://archive.kali.org/kali

# 3. If you have an existing Kali system, use --variant=copymode
# Or manually copy your system:
sudo bash -c "for d in bin sbin lib lib64 usr etc opt root; do cp -a /$d /path/to/squash_root/; done"
```

### Kernel Not Found

**Symptoms:**
- `vmlinuz-6.12.0-kali-amd64` missing
- "No se encontró ningún kernel"
- Fallback kernel used

**Solutions:**
```bash
# Option A: Download the kernel package
sudo apt update
sudo apt download linux-image-6.12.0-kali-amd64
dpkg-deb -x linux-image-*.deb /tmp/kernel_extract
cp /tmp/kernel_extract/boot/vmlinuz-* /path/to/iso_root/live/
cp /tmp/kernel_extract/boot/initrd* /path/to/iso_root/live/

# Option B: Install the kernel
sudo apt install linux-image-6.12.0-kali-amd64

# Option C: Use the latest available kernel
ls -la /boot/vmlinuz-*
# Then copy the newest one manually
```

### GRUB "No Such Device" Error

**Symptoms:**
- GRUB shows "no such device"
- System hangs at GRUB prompt

**Solutions:**
```bash
# Boot from GRUB command line:
grub> ls                          # List available drives
grub> set root=(hd0,msdos1)       # Set correct partition
grub> linux /live/vmlinuz boot=live live-media=removable
grub> initrd /live/initrd.img
grub> boot

# After booting, fix GRUB permanently:
sudo update-grub
sudo grub-install /dev/sdX
```

### ISO Too Large

**Symptoms:**
- ISO > 4.7 GB (DVD size)
- FAT32 filesystem can't hold the ISO
- Flash fails

**Solutions:**
```bash
# 1. Use smaller squashfs compression
# In build_kali_hdd.sh, change:
mksquashfs ... -comp xz ...
# To:
mksquashfs ... -comp gzip -b 256K ...

# 2. Remove unnecessary packages from debootstrap
# Remove: kali-linux-purple (very large)
# Keep: kali-linux-core or minimal

# 3. Use an HDD instead of USB (HDDs handle 4GB+ better)
```

---

## 🚀 Boot Issues

### System Won't Boot from HDD

**Symptoms:**
- "No bootable device"
- System skips the HDD
- Falls back to internal drive

**Solutions:**
```bash
# 1. Check Secure Boot (must be DISABLED)
# In BIOS: Security → Secure Boot → Disabled

# 2. Check boot order in BIOS
# Boot → Boot Priority → USB/HDD External → Move to top

# 3. Verify the ISO was written correctly
# On another Linux system:
sudo fdisk -l /dev/sdX   # Should show ISO9660 partition
```

### GRUB Shows But Won't Boot

**Symptoms:**
- GRUB menu appears
- Selecting an entry shows error
- "Invalid signature" or "File not found"

**Solutions:**
```
# If you see "invalid signature":
# The ISO may be corrupted. Re-flash with:
sudo dd if=*.iso of=/dev/sdX bs=4M status=progress conv=fsync

# If you see "file not found":
# Check the ISO contents:
sudo mount /dev/sdX1 /mnt
ls /mnt/live/     # Should show vmlinuz, initrd.img, filesystem.squashfs
```

### Black Screen After GRUB

**Symptoms:**
- GRUB menu disappears
- Black screen with cursor
- No desktop

**Solutions:**
```bash
# This is usually a graphics driver issue.
# Boot with nomodeset:
# From GRUB, press 'e' on the entry
# Add: nomodeset xforcevesa
# Press Ctrl+X to boot

# Or use the "Safe Mode" entry in the Recovery submenu
```

### LUKS Passphrase Not Prompted

**Symptoms:**
- Booted with LUKS persistence option
- System boots but no passphrase prompt
- Persistence not active

**Solutions:**
```bash
# 1. Check partition label
sudo blkid /dev/sdX3   # Should show LABEL="persistence"

# 2. If LUKS header is missing:
sudo cryptsetup luksFormat /dev/sdX3

# 3. If using wrong GRUB entry:
# Select "🔐 PERSISTENCIA CIFRADA LUKS" (not the plain one)
```

---

## 💾 Persistence Issues

### Persistence Not Saving

**Symptoms:**
- Changes disappear after reboot
- `/persistence.conf` missing or wrong

**Solutions:**
```bash
# 1. Check if persistence partition exists
lsblk -o NAME,LABEL | grep persistence

# 2. Verify persistence.conf content
sudo mount /dev/sdX3 /mnt
cat /mnt/persistence.conf
# Should show: / union

# 3. Re-run setup script
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX --force
```

### LUKS Volume Won't Open

**Symptoms:**
- "No key available with this passphrase"
- `cryptsetup luksOpen` fails

**Solutions:**
```bash
# 1. Check it's actually a LUKS partition
sudo blkid /dev/sdX3   # Should show TYPE="crypto_LUKS"

# 2. Try different keyboard layout (passphrase is case-sensitive)
# The initramfs uses US keyboard layout by default

# 3. As a last resort, check LUKS header:
sudo cryptsetup luksDump /dev/sdX3
```

---

## 🪟 Windows-Specific Issues

### WSL Installation Fails

**Symptoms:**
- WSL install command fails
- "The requested operation is not supported"
- Virtualization error

**Solutions:**
```powershell
# 1. Enable virtualization in BIOS
# Restart → BIOS → Intel VT-x / AMD-V → Enable

# 2. Enable Windows features manually
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 3. Download WSL2 kernel manually
# https://aka.ms/wsl2kernel

# 4. Install Kali directly from Microsoft Store
# Search "Kali Linux" in Microsoft Store and install
```

### dd.exe "Access Denied"

**Symptoms:**
- dd for Windows gives "Access is denied"
- Cannot open `\\.\PhysicalDriveN`

**Solutions:**
```powershell
# 1. Make sure PowerShell is running as Administrator
# Right-click → Run as Administrator

# 2. If using cmd, run as Administrator

# 3. Use Rufus instead (doesn't need raw disk access)
# Download from https://rufus.ie
```

### Rufus "Image is too large"

**Symptoms:**
- Rufus shows "The image is too large for this device"
- Cannot flash the ISO

**Solutions:**
```powershell
# 1. Use a larger USB/HDD (32GB minimum)

# 2. In Rufus, enable "List USB Hard Drives"
# Click the arrow ▼ next to "Device" dropdown
# Check "List USB Hard Drives"

# 3. Use the PowerShell script instead:
.\scripts\flash_iso.ps1 -IsoPath ".\image.iso" -Force
```

---

## 🐛 Debug Mode

For advanced debugging, boot with:

```bash
# Maximum debug output
break=top   # Drop to initramfs shell before mounting
```

Once in the debug shell:
```bash
# Check available devices
ls /dev/sd* /dev/nvme*

# Check for the ISO partition
blkid

# Manually mount and inspect
mount /dev/sdX1 /mnt
ls /mnt/live/

# Check for persistence
mount /dev/sdX3 /mnt 2>/dev/null || echo "No ext4 partition"
cryptsetup luksDump /dev/sdX3 2>/dev/null || echo "Not LUKS"

# View boot logs
cat /run/initramfs/init.log 2>/dev/null
dmesg | grep -i error
```

---

## 📞 Getting Help

If you can't resolve the issue:

1. **Check existing issues:** [GitHub Issues](https://github.com/constanza8999/EyeOfGod_ISO_V2/issues)
2. **Open a new issue:** Include:
   - Full error message
   - Hardware specs (CPU, RAM, motherboard model)
   - Exact steps to reproduce
   - Output of `dmesg | grep -i error` if possible

---

<p align="center">
  <i>Next: <a href="CONTRIBUTING.md">Contributing →</a></i>
</p>
