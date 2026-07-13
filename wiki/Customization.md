# 🎨 Customization Guide

## Adding Packages

Edit `build_kali_hdd.sh`, find the `debootstrap` line, and add packages:

```bash
--include=python3,python3-pip,bash,curl,wget,openssh-client,\
net-tools,iproute2,cryptsetup,YOUR_PACKAGE_HERE
```

Or add them in the chroot section:
```bash
chroot "${SQUASH_ROOT}" apt-get install -y your-package
```

## Adding EyeGod Levels

Edit `grub.cfg` to add new levels:

```grub
menuentry "  🌟  Nivel X — Your Theme  [KALI 6.12 / YOUR_SKIN]" --class eyegod {
    linux  /live/vmlinuz-6.12.0-kali-amd64 ${CMDLINE} eyegod_level=X skin=your_skin
    initrd /live/initrd.img-6.12.0-kali-amd64
}
```

## Adding Subsystems

Add new subsystems in the subsystems submenu of `grub.cfg`:

```grub
menuentry "YourSubsystemName-XXXX    [YS-## / Kali 6.12]" {
    linux /live/vmlinuz-6.12.0-kali-amd64 ${CMDLINE} subsystem=YourSubsystemName-XXXX
    initrd /live/initrd.img-6.12.0-kali-amd64
}
```

## Custom EyeGod Files

Place your EyeGod Python scripts and HTML files in the build source directory. They will be automatically copied to `/opt/eyegod/` during the build:

```
EyeGodV1000_10.py           # Main EyeGod Python script
eyegod_bridge_v2000.py      # WebSocket bridge
eyegod_iso_extensions.py    # ISO extensions
generate_subsystems.py      # Subsystem generator
requirements.txt            # Python dependencies
EyeGod_V2000_ULTRA.html     # Dashboard
eyegod_admin.html           # Admin panel
```

## Rebuilding After Changes

```bash
sudo bash scripts/build_kali_hdd.sh --clean .
sudo dd if=EyeOfGod_KaliPurple_2025.3_HDD.iso of=/dev/sdX bs=4M status=progress
```
