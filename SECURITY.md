# 🔒 Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 2025.3 (current) | ✅ |
| Older | ❌ |

## Reporting a Vulnerability

If you discover a security vulnerability, please **DO NOT** open a public issue.

Instead:
1. Go to [Security Advisories](https://github.com/constanza8999/EyeOfGod_ISO_V2/security/advisories)
2. Click "New advisory"
3. Describe the vulnerability in detail

Or open a [GitHub Issue](https://github.com/constanza8999/EyeOfGod_ISO_V2/issues) with "SECURITY" in the title.

**Response time:** We aim to acknowledge within 48 hours.

## Important Notes

- **Secure Boot must be DISABLED** — Kali kernels are not signed
- **LUKS recommended** for sensitive data on persistence
- **Default credentials** must be changed on first boot
- **EyeGod services** (ports 8765, 8766) should be bound to localhost in production

See [docs/SECURITY.md](docs/SECURITY.md) for full security documentation.
