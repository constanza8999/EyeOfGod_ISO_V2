# 🤝 Contributing Guide

> Thank you for your interest in contributing to Eye of God V∞ × Kali Purple!

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

---

## 📜 Code of Conduct

By participating in this project, you agree to:

- **Be respectful** — Disagreement is fine, personal attacks are not
- **Be constructive** — Criticism should be specific and actionable
- **Be inclusive** — We welcome contributors of all backgrounds
- **Focus on security** — Never test exploits on systems without permission

---

## 🚀 Getting Started

### Prerequisites
- Kali Linux, Debian, or Ubuntu (or WSL2 on Windows)
- Git
- Bash scripting knowledge
- (Optional) PowerShell for Windows scripts

### Setup
```bash
# Fork the repository
# Then clone your fork:
git clone https://github.com/YOUR_USERNAME/EyeOfGod_ISO_V2.git
cd EyeOfGod_ISO_V2

# Add upstream remote
git remote add upstream https://github.com/constanza8999/EyeOfGod_ISO_V2.git

# Create a branch for your changes
git checkout -b feature/my-improvement
```

---

## 🔧 Development Workflow

### 1. Find Something to Work On

Check [Issues](https://github.com/constanza8999/EyeOfGod_ISO_V2/issues) for:

- `good first issue` — Beginner-friendly tasks
- `help wanted` — Tasks needing contributors
- `enhancement` — Feature requests
- `bug` — Bug reports

Or propose something new by opening an issue first.

### 2. Make Your Changes

**Areas you can contribute to:**

| Area | Description | Examples |
|------|-------------|----------|
| 🐧 **Build Script** | `build_kali_hdd.sh` | Package selection, performance, error handling |
| 💾 **Persistence** | `setup_hdd_persistence.sh` | New encryption types, partition schemes |
| 🎮 **GRUB Config** | `grub.cfg` | New boot entries, themes, graphics |
| 🪟 **Windows Support** | `*.ps1`, `*.bat` | Better tool detection, UI improvements |
| 📚 **Documentation** | `docs/*.md`, `wiki/*.md` | Guides, translations, diagrams |
| 🧪 **Testing** | QEMU scripts | Automated testing, CI/CD |

### 3. Test Your Changes

```bash
# For build script changes:
# Test with --clean flag
sudo bash scripts/build_kali_hdd.sh --clean .

# For persistence changes:
# Test in QEMU with virtual HDD
qemu-system-x86_64 -m 4096 -enable-kvm \
    -cdrom EyeOfGod_KaliPurple_2025.3_HDD.iso \
    -drive file=test.qcow2,format=qcow2

# For Windows scripts:
# Test syntax
powershell -NoProfile -Command "& { . .\scripts\flash_iso.ps1; Write-Host 'Syntax OK' }"
```

### 4. Commit & Push

```bash
# Stage your changes
git add -A

# Commit with descriptive message
git commit -m "type: brief description" -m "Detailed explanation of what and why"

# Push to your fork
git push origin feature/my-improvement
```

**Commit types:**
- `feat:` — New feature
- `fix:` — Bug fix
- `docs:` — Documentation
- `refactor:` — Code restructuring
- `perf:` — Performance improvement
- `test:` — Adding tests
- `style:` — Formatting (no logic change)

### 5. Open a Pull Request

1. Go to your fork on GitHub
2. Click **"Pull Request"**
3. Select your branch → `main`
4. Fill in the PR template
5. Submit

---

## ✅ Pull Request Process

### PR Checklist

Before submitting, ensure:

- [ ] Changes work on Linux (tested)
- [ ] Changes work on Windows/WSL if applicable (tested)
- [ ] Documentation updated (README, docs, or wiki)
- [ ] Bash scripts pass shellcheck: `shellcheck scripts/*.sh`
- [ ] PowerShell scripts pass: `Invoke-ScriptAnalyzer`
- [ ] No secrets, tokens, or sensitive data included
- [ ] Commit messages follow conventions
- [ ] Branch is rebased on `main`

### Review Process

1. A maintainer will review within 3-5 business days
2. Address any feedback or change requests
3. Once approved, a maintainer will merge

---

## 📏 Coding Standards

### Bash Scripts (`*.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

# ── Functions ───────────────────────────────────────────────────────
# Prefix functions with namespace
log()  { echo -e "${GLD}[PREFIX]${RST} $*"; }

# ── Variables ──────────────────────────────────────────────────────
# Upper case for constants
readonly MAX_RETRIES=3

# Lower case for locals
local current_attempt=0

# Comments: Use ── separators for sections
# ── Validation ──────────────────────────────────────────────────────
```

**Rules:**
- Use `#!/usr/bin/env bash` (not `#!/bin/bash`)
- Always use `set -euo pipefail`
- Use functions for reusable logic
- Color output with ANSI escape codes
- Exit with meaningful error messages

### PowerShell Scripts (`*.ps1`)

```powershell
<#
.SYNOPSIS
    Brief description
.DESCRIPTION
    Detailed description
.PARAMETER Name
    Parameter description
.EXAMPLE
    Usage example
#>

function Write-Info { Write-Host "[INFO]" -ForegroundColor Cyan -NoNewline; Write-Host " $args" }
```

**Rules:**
- Use comment-based help
- Follow PowerShell verb-noun naming convention
- Use `-WhatIf` support for destructive operations
- Support `-Force` for skipping confirmations
- Handle errors with try/catch

### GRUB Config

- Use comments with section separators
- Keep entries organized by category
- Add descriptive text in entry titles
- Use classes for theming (`--class kali --class eyegod`)

---

## 🧪 Testing Checklist

### Build Script Tests
```bash
# Test with various arguments
sudo bash scripts/build_kali_hdd.sh --help     # Must show help, exit 0
sudo bash scripts/build_kali_hdd.sh --clean .  # Must start clean build
sudo bash scripts/build_kali_hdd.sh            # Must fail (no SRC_DIR)
```

### Persistence Script Tests
```bash
# Test argument parsing
sudo bash scripts/setup_hdd_persistence.sh --help    # Show help
sudo bash scripts/setup_hdd_persistence.sh           # Fail (no disk)
sudo bash scripts/setup_hdd_persistence.sh /dev/null # Fail (not a block device)
```

### Windows Script Tests
```powershell
# Syntax check
.\scripts\flash_iso.ps1 -Help
.\scripts\wsl_build.ps1 -Help
# These should show help without executing
```

---

## 📚 Documentation

### Where to Put Docs

| Content | Location |
|---------|----------|
| User guide | `docs/` |
| Architecture | `docs/ARCHITECTURE.md` |
| Code comments | Inline in scripts |
| Wiki pages | `wiki/` directory |
| Main README | `README.md` (English) |
| Quick start (Spanish) | `README_KALI_HDD.md` |

### Documentation Style

- Use **clear, simple language**
- Include **code examples** where applicable
- Use **diagrams** for complex flows (ASCII art or Mermaid)
- Keep English as the primary language
- Include translations in separate files

---

## 🙏 Thank You!

Every contribution counts — whether it's fixing a typo, improving documentation, adding a feature, or reporting a bug. You're awesome!

---

<p align="center">
  <i>Next: <a href="SECURITY.md">Security →</a></i>
</p>
