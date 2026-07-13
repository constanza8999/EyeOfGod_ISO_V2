# 🔒 Security Documentation

> Security considerations for Eye of God V∞ × Kali Purple

---

## 🛡️ Security Overview

This project combines **Kali Purple** (a security-focused Linux distribution) with the **Eye of God** framework. Understanding the security implications is critical before deployment.

---

## 🔐 Secure Boot

**Kali Linux kernels are NOT signed for UEFI Secure Boot.**

You **must** disable Secure Boot in your BIOS/UEFI settings:

```
BIOS Setup → Security → Secure Boot → Disabled
```

If you cannot disable Secure Boot, this ISO will not boot.

---

## 🗝️ Persistence Security

### Plain Ext4 (No Encryption)

```
Partition: ext4, label "persistence"
Data: Unencrypted
Risk: Anyone with physical access can read all saved data
```

**Suitable for:** Testing, non-sensitive environments

### LUKS Encryption

```
Partition: LUKS2 (AES-XTS), label "persistence"
Data: Encrypted at rest
Risk: Passphrase is the single point of failure
```

**Suitable for:** Sensitive data, field operations

### LUKS + Nuke

```
Partition: LUKS2 with nuke password
Data: Encrypted, with emergency wipe capability
Risk: Entering the nuke password IRREVERSIBLY DESTROYS ALL DATA
```

**Suitable for:** High-risk environments, OPSEC-conscious users

---

## 🔑 Credential Security

### EyeGod Secrets File

Credentials are stored in `/etc/eyegod/secrets`:

```
GROQ_API_KEY=your_key_here
ADMIN_SECRET=your_secret_here
TELEGRAM_TOKEN=your_token_here
```

**Security measures:**
- File is root-owned: `chmod 600 /etc/eyegod/secrets`
- A template is provided (`secrets.template`), NOT the actual secrets
- With LUKS, secrets are encrypted at rest

**⚠ NEVER commit `secrets` to the repository.**

### Default Credentials

This ISO does NOT have default passwords. During first boot:

1. Set a root password: `sudo passwd`
2. Set user passwords: `passwd`
3. Set LUKS passphrase (if using encryption)

---

## 🌐 Network Security

### Services Listening by Default

| Port | Service | Risk |
|------|---------|------|
| 8765 | EyeGod WebSocket Bridge | 🔴 Local network access; bind to 127.0.0.1 |
| 8766 | EyeGod HTTP Dashboard | 🔴 Local network access; bind to 127.0.0.1 |

**Recommendations:**
- Both services bind to `0.0.0.0` by default. Change to `127.0.0.1` if remote access isn't needed.
- Use a firewall: `sudo ufw enable`
- Default: `sudo ufw default deny incoming`

### Kali Purple Network Tools

Kali Purple includes tools that may be detected as hostile by network monitoring:
- Nmap, Wireshark, Metasploit, etc.
- Use only on networks you own or have explicit permission to test

---

## 🔄 Update Security

```bash
# Keep Kali Purple updated
sudo apt update && sudo apt full-upgrade -y

# With persistence, updates survive reboots
# Without persistence, updates are lost on reboot
```

> **Note:** Kernel updates may require re-building the ISO.

---

## 🖥️ Physical Security

| Threat | Mitigation |
|--------|------------|
| **HDD theft** | LUKS encryption renders data unreadable |
| **Evil maid attack** | LUKS + Nuke option for emergency wipe |
| **Cold boot attack** | Use RAM mode (toram) + shutdown when unattended |
| **USB HDD cloning** | Encrypted partitions can't be cloned without passphrase |

---

## 📝 Reporting Vulnerabilities

If you discover a security vulnerability:

1. **DO NOT** open a public GitHub issue
2. **DO NOT** discuss in public forums
3. **DO** send details to the repository maintainer via:
   - Open a [security advisory](https://github.com/constanza8999/EyeOfGod_ISO_V2/security/advisories)
   - Or email: [GitHub Issues](https://github.com/constanza8999/EyeOfGod_ISO_V2/issues) (mention "SECURITY" in title)

**What to include:**
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if available)

**Response time:** We aim to acknowledge within 48 hours and fix within 7 days.

---

## ✅ Security Checklist

Before using this ISO in a production or sensitive environment:

- [ ] Disable Secure Boot
- [ ] Set up LUKS encryption for persistence
- [ ] Change all default credentials
- [ ] Change SSH host keys (first boot)
- [ ] Configure firewall (ufw enable)
- [ ] Bind EyeGod services to localhost only
- [ ] Keep Kali Purple updated
- [ ] Back up the LUKS header: `cryptsetup luksHeaderBackup`
- [ ] Test recovery procedures
- [ ] Have a secure storage for backup passphrases

---

<p align="center">
  <i>⚡ Use responsibly. With great power comes great responsibility.</i>
</p>
