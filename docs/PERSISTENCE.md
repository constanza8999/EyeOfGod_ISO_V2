# 💾 Persistence System

> How data persistence works in Eye of God V∞ × Kali Purple

---

## 🔬 Technical Overview

Kali Linux live systems use **overlayfs** (formerly known as overlay filesystem or unionfs) to provide persistence. This allows users to save files, installed packages, and configuration changes across reboots.

```
┌──────────────────────────────────────────────────────────────┐
│                    OVERLAY FILESYSTEM                         │
│                                                               │
│  ┌─────────────────────┐     ┌──────────────────────────┐    │
│  │     LOWER LAYER      │     │     UPPER LAYER           │    │
│  │  (read-only)         │     │  (writable)               │    │
│  │                      │     │                           │    │
│  │  filesystem.squashfs │     │  ┌───────────────────┐   │    │
│  │  (Kali OS)           │     │  │ persistence.ext4  │   │    │
│  │                      │     │  │ (saved to HDD)    │   │    │
│  │  • /bin              │     │  │                   │   │    │
│  │  • /etc              │     │  │  Changes:          │   │    │
│  │  • /usr              │     │  │  • /home/*         │   │    │
│  │  • /lib              │     │  │  • /etc/*          │   │    │
│  │  • /opt              │     │  │  • /var/*          │   │    │
│  │  • ...               │     │  │  • /root/*         │   │    │
│  └──────────┬───────────┘     │  • New packages      │   │    │
│             │                 └───────────────────────────┘   │
│             │                         │                       │
│             └─────────────────────────┘                       │
│                         │                                      │
│                         ▼                                      │
│              ┌─────────────────────┐                          │
│              │   MERGED VIEW (/)    │                          │
│              │  (lower + upper)     │                          │
│              │  Writes go to upper  │                          │
│              │  Reads merge both    │                          │
│              └─────────────────────┘                          │
└──────────────────────────────────────────────────────────────┘
```

---

## 📂 Persistence Partition Layout

After running `setup_hdd_persistence.sh`, the external HDD has this structure:

```
/dev/sdX (External HDD)
├── sdX1  [ISO9660/FAT32]   ← Live ISO
│   ├── live/filesystem.squashfs
│   ├── live/vmlinuz-*
│   └── live/initrd.img-*
│
├── sdX2  [FAT12/EFI]       ← EFI System Partition (8MB)
│   └── EFI/BOOT/BOOTX64.EFI
│
└── sdX3  [ext4 / LUKS]     ← Persistence Partition
    └── persistence.conf     ← Configuration file
                             ← Label: "persistence"
```

### The `persistence.conf` File

This single file controls the overlay behavior:

```conf
# Simple: mount entire filesystem as persistent
/ union

# Advanced example (multiple directories):
# /home
# /etc     # Note: this would persist config separately
# /var
# /root
```

The format is:
```
<path> <mount_option>
```

Where:
- `path` — The mount point (e.g., `/` for root, `/home` for user files)
- `mount_option` — Usually `union` for overlay, or `bind` for bind mount

---

## 🔐 LUKS Encryption

### How It Works

When using `--luks` mode, the persistence partition is encrypted with **LUKS2** (Linux Unified Key Setup):

```
1. cryptsetup luksFormat --type luks2 /dev/sdX3
   → Creates LUKS header with encryption metadata
   → Uses AES-XTS with Argon2 KDF (password hashing)

2. cryptsetup luksOpen /dev/sdX3 eyegod_persist
   → Decrypts and creates /dev/mapper/eyegod_persist

3. mkfs.ext4 -L persistence /dev/mapper/eyegod_persist
   → Creates ext4 filesystem inside decrypted volume

4. echo "/ union" > /mount/point/persistence.conf
   → Creates overlay configuration
```

### Boot Flow with LUKS

```
1. GRUB loads kernel with: persistence persistence-encryption=luks
2. initramfs detects: boot=live + persistence + persistence-encryption=luks
3. Scans for partition labeled "persistence"
4. Finds LUKS partition (encrypted, so label is hidden)
5. blkid detects the partition as crypto_LUKS type
6. initramfs prompts: "Enter LUKS passphrase:"
7. cryptsetup luksOpen → creates /dev/mapper/luks-<uuid>
8. Mounts decrypted volume
9. Checks for /persistence.conf → "/ union"
10. Sets up overlayfs with persistence as upper layer
```

### LUKS + Nuke Mode

The **LUKS + Nuke** option in GRUB adds a special nuke password feature. If the nuke password is entered (instead of the real password), the LUKS header is securely overwritten, making data permanently inaccessible.

```bash
# This is implemented at the initramfs/cryptsetup level:
# A specific "nuke password" triggers a secure erase instead of decrypt
```

> ⚠ **WARNING:** With LUKS-Nuke, entering the nuke password **irreversibly destroys all data** on the persistence partition.

---

## 🛠️ Manual Persistence Setup

If you prefer to set up persistence manually (without the script):

### Without Encryption
```bash
# 1. Create partition
sudo parted /dev/sdX mkpart primary ext4 5G 100%

# 2. Format (label must be "persistence")
sudo mkfs.ext4 -L persistence /dev/sdX3

# 3. Configure
sudo mount /dev/sdX3 /mnt
echo "/ union" | sudo tee /mnt/persistence.conf
sudo umount /mnt
```

### With LUKS Encryption
```bash
# 1. Create partition
sudo parted /dev/sdX mkpart primary ext4 5G 100%

# 2. Encrypt (you'll be prompted for a passphrase)
sudo cryptsetup luksFormat --type luks2 /dev/sdX3

# 3. Open and format
sudo cryptsetup luksOpen /dev/sdX3 mypersist
sudo mkfs.ext4 -L persistence /dev/mapper/mypersist

# 4. Configure
sudo mount /dev/mapper/mypersist /mnt
echo "/ union" | sudo tee /mnt/persistence.conf
sudo umount /mnt
sudo cryptsetup luksClose mypersist
```

---

## 📊 Persistence Modes Comparison

| Mode | Data Survival | Encryption | Speed | Use Case |
|------|---------------|------------|-------|----------|
| **None** | ❌ Lost on reboot | — | ⚡ Fastest | Testing, single session |
| **Plain** | ✅ Saved | ❌ No | 🟡 Medium | General daily use |
| **LUKS** | ✅ Saved | ✅ Yes | 🟡 Medium (decrypt overhead) | Sensitive data |
| **LUKS+Nuke** | ✅ Saved (until nuked) | ✅ Yes | 🟡 Medium | OPSEC, high-risk environments |
| **RAM (toram)** | ❌ Lost on shutdown | — | ⚡ Very fast | Performance, freeing HDD |
| **Forensic** | ❌ No writes | — | 🟢 Fast (read-only) | Evidence acquisition |

---

## 🧪 Persistence Verification

After booting, verify persistence is active:

```bash
# Check mount points
mount | grep overlay

# Expected output:
# overlay on / type overlay (rw,relatime,lowerdir=...,upperdir=...)

# Check if persistence label exists
lsblk -o NAME,LABEL | grep persistence

# Create a test file and reboot
echo "Persistence works!" > /home/user/persist_test.txt
# After reboot, check if file exists:
cat /home/user/persist_test.txt
```

---

## ⚠️ Limitations & Known Issues

| Issue | Description | Workaround |
|-------|-------------|------------|
| **Package updates** | APT cache fills persistence | Clean with `apt clean` |
| **Disk wear** | Frequent writes on HDD | Use `toram` for heavy I/O |
| **LUKS password change** | Password can't be changed easily | Backup data, recreate partition |
| **GRUB update** | Changes to initrd may break persistence | Use emergency shell to fix |
| **Partition resize** | Can't easily shrink LUKS volumes | Backup and recreate |

---

<p align="center">
  <i>Next: <a href="WINDOWS_SETUP.md">Windows Setup →</a></i>
</p>
