# 👁 Eye of God V∞ × Kali Purple Wiki

Welcome to the **Eye of God V∞ × Kali Purple** wiki! This is the central knowledge base for building, deploying, and customizing your own Kali Linux live ISO with persistence and the Eye of God procedural framework.

## 📖 Quick Navigation

| Section | Description |
|---------|-------------|
| [Installation](Installation) | Step-by-step build and flash guide |
| [GRUB Configuration](GRUB-Configuration) | Understanding and customizing the boot menu |
| [Customization](Customization) | Adding tools, themes, and EyeGod levels |
| [Architecture](https://github.com/constanza8999/EyeOfGod_ISO_V2/blob/main/docs/ARCHITECTURE.md) | System design and component overview |
| [Persistence](https://github.com/constanza8999/EyeOfGod_ISO_V2/blob/main/docs/PERSISTENCE.md) | How persistence and LUKS work |

## 🚀 Getting Started

```bash
# Quick build
git clone https://github.com/constanza8999/EyeOfGod_ISO_V2.git
cd EyeOfGod_ISO_V2
sudo bash scripts/build_kali_hdd.sh --clean .
sudo dd if=EyeOfGod_KaliPurple_2025.3_HDD.iso of=/dev/sdX bs=4M status=progress
```

## ❓ Need Help?

- [Open an Issue](https://github.com/constanza8999/EyeOfGod_ISO_V2/issues)
- Check the [Troubleshooting Guide](https://github.com/constanza8999/EyeOfGod_ISO_V2/blob/main/docs/TROUBLESHOOTING.md)
