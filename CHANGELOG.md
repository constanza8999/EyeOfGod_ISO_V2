# 📋 Changelog

> **Eye of God V∞ × Kali Purple** — All notable changes to this project

---

## [v2025.3.1] — 2026-07-13

### 🚀 Features

- **Website Overhaul**: Complete redesign with Matrix digital rain background, interactive terminal emulator with 15+ commands, scroll progress bar, floating action buttons, custom cursor, and Ctrl+K command palette
- **Loading Screen**: Animated boot sequence with rotating status messages and progress bar
- **PWA Support**: Service worker for offline caching and manifest.json for installable web app
- **Release Script**: New `scripts/create_release.sh` for automated version tagging and release notes generation

### 🎨 Website Improvements

- **Matrix Rain**: Canvas-based digital rain with katakana characters, varied brightness, and smooth animation
- **Interactive Terminal**: 15 commands including `boot`, `grub`, `levels`, `status`, `eye`, `neofetch`, `ping` — with tab autocomplete and command suggestions
- **Command Palette**: Ctrl+K opens searchable command palette for quick navigation between sections
- **Scroll Progress**: Gradient progress bar at top of page tracking reading position
- **Floating Buttons**: Back-to-top and command palette toggle with tooltips
- **Custom Cursor**: Cyberpunk-style dot+ring cursor with hover effects on interactive elements
- **Performance**: Touch device detection, debounced events, optimized particle connections

### 🔧 Maintenance

- Fixed broken logo reference in README documentation
- Created `docs/assets/` directory with logo placeholder
- Added Project website badge to README

### 📦 Other Changes

- All previous commits documented below

---

## [2025.3.0] — Initial Release Series

### v2 — Website & CI

- **GitHub Pages**: Modern responsive website with cyberpunk dark theme (red/black/gold)
- **CI Workflow**: GitHub Actions for automated ISO building with Kali Linux Docker container
- **Comprehensive Documentation**: Architecture, build guide, boot process, persistence, Windows setup, troubleshooting, contributing, security, wiki pages

### v1 — Core ISO

- **Build Script**: `build_kali_hdd.sh` — Full ISO builder with debootstrap, kernel acquisition, squashfs packaging, GRUB installation, hybrid ISO generation
- **GRUB Configuration**: 40+ boot entries organized into main menu, EyeGod levels (0→∞), NIST CSF toolsets, persistence options, procedural subsystems, recovery/diagnostics
- **Persistence Setup**: `setup_hdd_persistence.sh` — Creates ext4 or LUKS-encrypted persistence partition
- **Windows Support**: PowerShell scripts for WSL2 build (`wsl_build.ps1`), ISO flashing (`flash_iso.ps1`), and interactive batch menu (`flash_iso.bat`)
- **EyeGod Framework**: 10,000 procedural subsystems, WebSocket bridge (:8765), HTTP dashboard (:8766), Python REPL kernel

### Architecture

- **Kernel**: linux-image-6.12.0-kali-amd64 (Kali Linux 2025.3)
- **Boot**: BIOS + UEFI hybrid via GRUB 2.06
- **Persistence**: OverlayFS with ext4 or LUKS2 encryption
- **Format**: Hybrid ISO (ISO9660 + FAT32 + FAT12 EFI)

---

## Release Process

Releases are created by pushing a signed tag to GitHub:

```bash
# Create and push a release
bash scripts/create_release.sh v2025.3.1 --push
```

This triggers the GitHub Actions workflow which:
1. Builds the ISO in a Kali Linux container
2. Creates a GitHub Release with the ISO as an asset
3. Publishes release notes auto-generated from commit history

---

*"The Eye does not distinguish between internal and external HDD. It sees all."*
