# 🎮 GRUB Configuration

The main GRUB configuration is in `iso_root/boot/grub/grub.cfg` (or `scripts/grub_kali.cfg` for builds).

## Menu Structure

```
Main Menu (5 entries)
├── EyeGod Levels Submenu (20 levels: 0 → ∞)
├── Kali Purple NIST CSF Submenu (6 toolsets)
├── HDD Options Submenu (5 entries)
├── Subsystems Submenu (8 procedurals)
└── Recovery Submenu (5 entries)
```

## Adding a Boot Entry

```grub
menuentry "  🆕 My Custom Entry  [KALI 6.12]" --class kali {
    linux  /live/vmlinuz-6.12.0-kali-amd64 boot=live components quiet splash \
           live-media=removable live-media-path=/live \
           eyegod_level=CUSTOM skin=custom
    initrd /live/initrd.img-6.12.0-kali-amd64
}
```

## Theme Customization

```grub
# Change color scheme
set color_normal=white/black
set color_highlight=black/white
set menu_color_normal=cyan/black
set menu_color_highlight=black/cyan

# Change resolution
set gfxmode=1366x768,1024x768,auto

# Change timeout (seconds)
set timeout=30
```

## Custom Background

1. Add a PNG image: `iso_root/boot/grub/themes/eyegod-kali/background.png`
2. In `grub.cfg`:
```grub
insmod png
background_image /boot/grub/themes/eyegod-kali/background.png
```
