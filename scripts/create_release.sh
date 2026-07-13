#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  EYE OF GOD V∞ × KALI PURPLE — RELEASE SCRIPT                         ║
# ║  Automates version tagging, changelog generation, and release creation ║
# ║  Usage: bash scripts/create_release.sh <version> [--push]              ║
# ║  Example: bash scripts/create_release.sh v2025.3.1 --push              ║
# ╚══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[1;31m'; GLD='\033[38;5;220m'; GRN='\033[1;32m'
CYN='\033[1;36m'; MAG='\033[1;35m'; RST='\033[0m'

log()  { echo -e "${GLD}[RELEASE]${RST} $*"; }
ok()   { echo -e "${GRN}[  OK  ]${RST} $*"; }
fail() { echo -e "${RED}[ FAIL ]${RST} $*"; exit 1; }
warn() { echo -e "\033[38;5;208m[WARN ]${RST} $*"; }
step() { echo -e "\n${MAG}━━━ $* ━━━${RST}"; }

# ── Config ───────────────────────────────────────────────────────────────────
PROJECT="Eye of God V∞ × Kali Purple"
REPO="constanza8999/EyeOfGod_ISO_V2"
DEFAULT_VERSION="v2025.3.1"

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "${RED}"
cat <<'BANNER'
  ╔══════════════════════════════════════════════════════════════╗
  ║   👁  EYE OF GOD V∞ × KALI PURPLE — RELEASE CREATOR        ║
  ╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${RST}"

# ── Parse arguments ───────────────────────────────────────────────────────────
VERSION="$DEFAULT_VERSION"
PUSH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --push)
      PUSH="--push"
      shift
      ;;
    --help|-h)
      echo "Uso: bash scripts/create_release.sh <version> [--push]"
      echo ""
      echo "Argumentos:"
      echo "  <version>   Version tag (default: $DEFAULT_VERSION)"
      echo "              Examples: v2025.3.1, v2025.4.0, v1.0.0"
      echo "  --push      Push the tag to GitHub immediately"
      echo ""
      echo "Ejemplos:"
      echo "  bash scripts/create_release.sh v2025.3.1              # Create tag locally"
      echo "  bash scripts/create_release.sh v2025.3.1 --push       # Create tag and push"
      echo "  bash scripts/create_release.sh                        # Create default tag"
      exit 0
      ;;
    -*)
      echo "Opción desconocida: $1"
      echo "Uso: bash scripts/create_release.sh <version> [--push]"
      exit 1
      ;;
    *)
      VERSION="$1"
      ;;
  esac
  shift
done

# ── Validate version format ───────────────────────────────────────────────────
if ! echo "$VERSION" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9A-Za-z.-]+$'; then
    warn "Formato de versión recomendado: vMAJOR.MINOR.PATCH (ej: v2025.3.1, v2025.3.1-rc1)"
    warn "Has introducido: $VERSION"
    echo ""
    read -r -p "$(echo -e "${GLD}¿Continuar con esta versión? [s/N]: ${RST}")" CONFIRM
    [[ "$CONFIRM" =~ ^[Ss]$ ]] || { echo "Abortado."; exit 0; }
fi

# ── Check working directory ───────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

if [ ! -d ".git" ]; then
    fail "Este no es un repositorio Git. Ejecuta desde la raíz del proyecto."
fi

# ── Check for uncommitted changes ─────────────────────────────────────────────
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    warn "Hay cambios sin commitear:"
    git status --short
    echo ""
    read -r -p "$(echo -e "${GLD}¿Commitear todo antes de continuar? [S/n]: ${RST}")" CONFIRM
    if [ -z "$CONFIRM" ] || [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        git add -A
        git commit -m "chore: prepare release $VERSION" || true
        ok "Cambios commiteados."
    else
        warn "Continuando con cambios sin commitear (no recomendado)."
    fi
fi

# ══════════════════════════════════════════════════════════════════════════════
#  STEP 1: GENERATE RELEASE NOTES
# ══════════════════════════════════════════════════════════════════════════════
step "STEP 1: Generating release notes"

RELEASE_NOTES=$(mktemp)
trap "rm -f '$RELEASE_NOTES'" EXIT

# Get commits since last tag, or all if no tags
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$LAST_TAG" ]; then
    COMMITS=$(git log --oneline --no-decorate "${LAST_TAG}..HEAD" 2>/dev/null || git log --oneline --no-decorate -20)
    COMMIT_RANGE="${LAST_TAG}..HEAD"
else
    COMMITS=$(git log --oneline --no-decorate -30)
    COMMIT_RANGE="initial"
fi

cat > "$RELEASE_NOTES" << NOTES_HEADER
# 👁 Eye of God V∞ × Kali Purple — Release ${VERSION}

> Kernel 6.12.0 · Kali Linux 2025.3 · BIOS+UEFI Hybrid Boot

## 📥 Download

- **ISO Image:** Built via GitHub Actions (see artifacts below)
- **Source Code:** https://github.com/${REPO}/tree/${VERSION}

## ✨ What's New

NOTES_HEADER

# Categorize commits
FEATS=""; FIXES=""; CHORES=""; DOCS=""; OTHERS=""
while IFS= read -r line; do
    HASH=$(echo "$line" | awk '{print $1}')
    MSG=$(echo "$line" | cut -d' ' -f2-)
    if echo "$MSG" | grep -qiE "^feat"; then
        FEATS="${FEATS}- ${MSG} ([${HASH}](https://github.com/${REPO}/commit/${HASH}))\n"
    elif echo "$MSG" | grep -qiE "^fix"; then
        FIXES="${FIXES}- ${MSG} ([${HASH}](https://github.com/${REPO}/commit/${HASH}))\n"
    elif echo "$MSG" | grep -qiE "^docs"; then
        DOCS="${DOCS}- ${MSG} ([${HASH}](https://github.com/${REPO}/commit/${HASH}))\n"
    elif echo "$MSG" | grep -qiE "^chore"; then
        CHORES="${CHORES}- ${MSG} ([${HASH}](https://github.com/${REPO}/commit/${HASH}))\n"
    else
        OTHERS="${OTHERS}- ${MSG} ([${HASH}](https://github.com/${REPO}/commit/${HASH}))\n"
    fi
done <<< "$COMMITS"

[ -n "$FEATS" ]  && echo -e "\n### 🚀 Features\n\n${FEATS}"  >> "$RELEASE_NOTES"
[ -n "$FIXES" ]  && echo -e "\n### 🐛 Bug Fixes\n\n${FIXES}"  >> "$RELEASE_NOTES"
[ -n "$DOCS" ]   && echo -e "\n### 📚 Documentation\n\n${DOCS}" >> "$RELEASE_NOTES"
[ -n "$CHORES" ] && echo -e "\n### 🔧 Maintenance\n\n${CHORES}" >> "$RELEASE_NOTES"
[ -n "$OTHERS" ] && echo -e "\n### 📦 Other Changes\n\n${OTHERS}" >> "$RELEASE_NOTES"

# Usage instructions
cat >> "$RELEASE_NOTES" << NOTES_FOOTER

## 🚀 Quick Start

### Linux
```bash
git clone https://github.com/${REPO}.git
cd ${PROJECT_DIR##*/}
sudo bash scripts/build_kali_hdd.sh --clean .
sudo dd if=EyeOfGod_KaliPurple_2025.3_HDD.iso of=/dev/sdX bs=4M status=progress
sudo bash scripts/setup_hdd_persistence.sh /dev/sdX --luks
```

### Windows (WSL2)
```powershell
.\\scripts\\wsl_build.ps1 -SetupWsl    # One-time setup
.\\scripts\\wsl_build.ps1 -Build        # Build ISO
.\\scripts\\flash_iso.ps1               # Flash to USB/HDD
```

## ⚠️ Important Notes
- **Secure Boot** must be disabled in BIOS/UEFI
- Minimum **32GB** external HDD/USB (128GB+ recommended)
- LUKS encryption recommended for sensitive persistence data

## 📚 Documentation
- [Architecture](https://github.com/${REPO}/blob/main/docs/ARCHITECTURE.md)
- [Build Guide](https://github.com/${REPO}/blob/main/docs/BUILD_GUIDE.md)
- [Boot Process](https://github.com/${REPO}/blob/main/docs/BOOT_PROCESS.md)
- [Persistence](https://github.com/${REPO}/blob/main/docs/PERSISTENCE.md)

---

*"The Eye does not distinguish between internal and external HDD. It sees all."*
NOTES_FOOTER

ok "Release notes generated."

# ══════════════════════════════════════════════════════════════════════════════
#  STEP 2: CREATE GIT TAG
# ══════════════════════════════════════════════════════════════════════════════
step "STEP 2: Creating git tag: ${VERSION}"

# Check if tag already exists
if git tag | grep -q "^${VERSION}$"; then
    warn "El tag ${VERSION} ya existe."
    read -r -p "$(echo -e "${GLD}¿Sobrescribir? [s/N]: ${RST}")" CONFIRM
    if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        git tag -d "$VERSION"
        git tag -a "$VERSION" -F "$RELEASE_NOTES"
        ok "Tag ${VERSION} recreado."
    else
        fail "Abortado. Usa una versión diferente."
    fi
else
    git tag -a "$VERSION" -F "$RELEASE_NOTES"
    ok "Tag ${VERSION} creado."
fi

# ══════════════════════════════════════════════════════════════════════════════
#  STEP 3: SHOW RELEASE NOTES
# ══════════════════════════════════════════════════════════════════════════════
step "STEP 3: Preview release notes"
echo ""
echo -e "${CYN}$(head -20 "$RELEASE_NOTES")${RST}"
echo -e "${CYN}... (${GLD}$(wc -l < "$RELEASE_NOTES") lines total${CYN})${RST}"
echo ""

# ══════════════════════════════════════════════════════════════════════════════
#  STEP 4: PUSH (optional)
# ══════════════════════════════════════════════════════════════════════════════
step "STEP 4: Push"

if [ "$PUSH" = "--push" ]; then
    log "Pushing tag ${VERSION} to origin..."
    git push origin "$VERSION"
    ok "Tag ${VERSION} pushed to GitHub."
    
    echo ""
    echo -e "${GLD}╔══════════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${GLD}║  ✅  RELEASE PUBLISHED                                         ║${RST}"
    echo -e "${GLD}╠══════════════════════════════════════════════════════════════════╣${RST}"
    echo -e "${GLD}║${RST}  Version: ${CYN}${VERSION}${RST}"
    echo -e "${GLD}║${RST}  Tag:     https://github.com/${REPO}/releases/tag/${VERSION}"
    echo -e "${GLD}║${RST}  GitHub Actions se encargará del build y la subida de assets."
    echo -e "${GLD}║${RST}"
    echo -e "${GLD}║${RST}  Sigue el progreso en:"
    echo -e "${GLD}║${RST}  https://github.com/${REPO}/actions"
    echo -e "${GLD}╚══════════════════════════════════════════════════════════════════╝${RST}"
else
    echo ""
    echo -e "${GLD}╔══════════════════════════════════════════════════════════════════╗${RST}"
    echo -e "${GLD}║  ✅  TAG CREADO LOCALMENTE                                     ║${RST}"
    echo -e "${GLD}╠══════════════════════════════════════════════════════════════════╣${RST}"
    echo -e "${GLD}║${RST}  Version: ${CYN}${VERSION}${RST}"
    echo -e "${GLD}║${RST}"
    echo -e "${GLD}║${RST}  Para publicar el release, ejecuta:"
    echo -e "${GLD}║${CYN}    git push origin ${VERSION}${RST}"
    echo -e "${GLD}║${RST}"
    echo -e "${GLD}║${RST}  O usa el flag --push la próxima vez:"
    echo -e "${GLD}║${CYN}    bash scripts/create_release.sh ${VERSION} --push${RST}"
    echo -e "${GLD}╚══════════════════════════════════════════════════════════════════╝${RST}"
fi

echo ""
log "Release ${VERSION} preparado."
