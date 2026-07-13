#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  EYE OF GOD V∞ × KALI PURPLE — SETUP HDD EXTERNO CON PERSISTENCIA     ║
# ║  Ejecutar DESPUÉS de flashear la ISO al HDD                            ║
# ╚══════════════════════════════════════════════════════════════════════════╝
#
#  USO:
#    sudo bash setup_hdd_persistence.sh /dev/sdX          (sin cifrado)
#    sudo bash setup_hdd_persistence.sh /dev/sdX --luks   (con LUKS)
#
#  /dev/sdX = tu HDD externo (ej: /dev/sdb, /dev/sdc)
#  ⚠  La ISO ya debe estar flasheada al disco antes de ejecutar esto

set -euo pipefail

# ── Trap para limpieza en caso de error ────────────────────────────────────────
MOUNTED=()
cleanup() {
  local ec=$?
  if [ $ec -ne 0 ]; then
    echo -e "\033[1;31m[ CLEANUP ]\033[0m Error detectado, limpiando..."
    for m in "${MOUNTED[@]}"; do
      mountpoint -q "$m" 2>/dev/null && umount "$m" 2>/dev/null && echo "  Desmontado: $m"
    done
  fi
  exit $ec
}
trap cleanup EXIT

RED='\033[1;31m'; GLD='\033[38;5;220m'; GRN='\033[1;32m'
CYN='\033[1;36m'; MAG='\033[1;35m'; RST='\033[0m'
log()  { echo -e "${GLD}[HDD-SETUP]${RST} $*"; }
ok()   { echo -e "${GRN}[  OK  ]${RST} $*"; }
fail() { echo -e "${RED}[ FAIL ]${RST} $*"; exit 1; }
warn() { echo -e "\033[38;5;208m[WARN ]${RST} $*"; }

# ── Argumentos ────────────────────────────────────────────────────────────────
HDD=""
USE_LUKS=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --luks)
      USE_LUKS=true
      shift
      ;;
    --force|-f)
      FORCE=true
      shift
      ;;
    --help|-h)
      echo "Uso: sudo bash $0 /dev/sdX [--luks] [--force]"
      echo "  /dev/sdX    Dispositivo HDD externo (ej: /dev/sdb, /dev/sdc)"
      echo "  --luks      Activar cifrado LUKS en la partición de persistencia"
      echo "  --force, -f Saltar la confirmación interactiva"
      exit 0
      ;;
    -*)
      echo "Opción desconocida: $1"
      echo "Uso: sudo bash $0 /dev/sdX [--luks] [--force]"
      exit 1
      ;;
    *)
      HDD="$1"
      ;;
  esac
  shift
done

[ -z "$HDD" ]   && fail "Uso: sudo bash $0 /dev/sdX [--luks] [--force]"
[ "$EUID" -ne 0 ] && fail "Ejecutar como root: sudo bash $0 $HDD"
[ ! -b "$HDD" ] && fail "Dispositivo no encontrado: $HDD"

# ── Verificar cryptsetup si se necesita LUKS ──────────────────────────────────
if [ "$USE_LUKS" = true ]; then
  command -v cryptsetup >/dev/null 2>&1 || fail "cryptsetup no instalado. Ejecuta: apt install cryptsetup"
fi

# ── Verificar que NO sea un disco del sistema (protección) ────────────────────
for sys_disk in $(lsblk -lno NAME 2>/dev/null | grep -E '^(sd[a-z]$|nvme[0-9]n[0-9]$|vd[a-z]$|xvd[a-z]$|mmcblk[0-9]+$)' | head -10); do
  if [ "/dev/${sys_disk}" = "$HDD" ]; then
    # Verificar si tiene partición del sistema
    SYS_PARTS=$(lsblk -lno MOUNTPOINT "/dev/${sys_disk}" 2>/dev/null | grep -E '^/$|^/boot|^/home' | head -1)
    if [ -n "$SYS_PARTS" ]; then
      fail "${HDD} parece ser un disco del sistema (montado en ${SYS_PARTS}). ABORTANDO por seguridad."
    fi
  fi
done

echo -e "${RED}"
cat <<'BANNER'
  ╔══════════════════════════════════════════════════════════════╗
  ║  EYE OF GOD × KALI PURPLE — CONFIGURANDO HDD EXTERNO       ║
  ╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${RST}"

# ── Mostrar estado actual del disco ─────────────────────────────────────────
log "Estado actual de ${HDD}:"
log ""
parted "$HDD" print 2>/dev/null || lsblk "$HDD" -o NAME,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT 2>/dev/null || true
echo ""

# ── Detectar la última partición de la ISO ──────────────────────────────────
log "Detectando particiones existentes de la ISO..."
if ! command -v parted >/dev/null 2>&1; then
  fail "parted no está instalado. Instálalo con: apt-get install -y parted"
fi

LAST_PART_END=$(parted -m "$HDD" unit MiB print 2>/dev/null \
  | grep "^[0-9]" | sort -t: -k1 -n | tail -1 | cut -d: -f3 | tr -d ' ' | tr -d MiB)

if [ -z "$LAST_PART_END" ]; then
  fail "No se detectaron particiones. ¿Está la ISO flasheada en ${HDD}?"
fi
log "Última partición termina en: ${LAST_PART_END}MiB"

# ── Tamaño total disponible ──────────────────────────────────────────────────
DISK_SIZE=$(parted -m "$HDD" unit MiB print 2>/dev/null \
  | grep "^${HDD}:" | cut -d: -f2 | tr -d ' ' | tr -d MiB | cut -d. -f1)

if [ -z "$DISK_SIZE" ]; then
  # Fallback: obtener tamaño con lsblk
  DISK_SIZE=$(lsblk -bno SIZE "$HDD" 2>/dev/null | head -1)
  DISK_SIZE=$((DISK_SIZE / 1048576))  # bytes → MiB
fi

AVAILABLE=$(( DISK_SIZE - LAST_PART_END - 2 ))

if [ "$AVAILABLE" -lt 0 ]; then
  fail "No hay espacio libre en ${HDD}. Tamaño del disco: ${DISK_SIZE}MiB"
fi

log "Espacio disponible para persistencia: ~${AVAILABLE}MiB"

if [ "$AVAILABLE" -lt 500 ]; then
  fail "Espacio insuficiente. Necesitas al menos 500MiB (tienes ~${AVAILABLE}MiB)."
fi

PERSIST_START="${LAST_PART_END}"
PERSIST_END="${DISK_SIZE}"

# ── Confirmación interactiva ───────────────────────────────────────────────────
echo ""
echo -e "${GLD}═══ RESUMEN DE CONFIGURACIÓN ═══${RST}"
echo -e "  Disco      : ${CYN}${HDD}${RST}"
echo -e "  Tamaño     : ${DISK_SIZE}MiB"
echo -e "  Partición  : ${PERSIST_START}MiB → ${PERSIST_END}MiB (~${AVAILABLE}MiB)"
echo -e "  LUKS       : ${USE_LUKS}"
echo -e "${GLD}══════════════════════════════════${RST}"
echo ""

if [ "$FORCE" = false ]; then
  read -r -p "$(echo -e "${RED}⚠  ¿Continuar? Se creará una NUEVA PARTICIÓN en ${HDD}. [s/N]: ${RST}")" CONFIRM
  [[ "$CONFIRM" =~ ^[Ss]$ ]] || { echo "Abortado."; exit 0; }
fi

# ── Crear partición de persistencia ─────────────────────────────────────────
log "Creando partición de persistencia..."
parted -s "$HDD" mkpart primary ext4 "${PERSIST_START}MiB" "${PERSIST_END}MiB"
sleep 2
partprobe "$HDD" 2>/dev/null || true
sleep 1

# Detectar la nueva partición
NEW_PART=""
for try in 1 2 3; do
  NEW_PART=$(lsblk -lno NAME "$HDD" | grep -v "^$(basename $HDD)$" | tail -1)
  [ -n "$NEW_PART" ] && break
  sleep 1
done
NEW_PART="/dev/${NEW_PART}"
[ ! -b "$NEW_PART" ] && fail "No se pudo detectar la nueva partición en ${HDD}"
ok "Nueva partición: ${NEW_PART}"

# ── Sin LUKS: formato directo ─────────────────────────────────────────────────
if [ "$USE_LUKS" = false ]; then
  log "Formateando ${NEW_PART} como ext4 (label: persistence)..."
  mkfs.ext4 -L persistence "$NEW_PART"
  ok "Partición formateada."

  log "Montando y configurando persistence.conf..."
  MOUNT_POINT="/mnt/eyegod_persist_$$"
  mkdir -p "$MOUNT_POINT"
  mount "$NEW_PART" "$MOUNT_POINT"
  echo "/ union" > "${MOUNT_POINT}/persistence.conf"
  umount "$MOUNT_POINT"
  rmdir "$MOUNT_POINT"
  ok "persistence.conf configurado."

# ── Con LUKS: cifrado ─────────────────────────────────────────────────────────
else
  log "Configurando cifrado LUKS en ${NEW_PART}..."
  echo -e "${RED}⚠  Introduce la contraseña para el cifrado LUKS.${RST}"
  echo -e "${RED}⚠  NO LA PIERDAS — los datos serán irrecuperables sin ella.${RST}"
  cryptsetup luksFormat --type luks2 "$NEW_PART"
  ok "LUKS formateado."

  log "Abriendo volumen LUKS..."
  MAPPER_NAME="eyegod_persist_$$"
  cryptsetup luksOpen "$NEW_PART" "$MAPPER_NAME"

  log "Formateando volumen cifrado como ext4..."
  mkfs.ext4 -L persistence "/dev/mapper/${MAPPER_NAME}"
  ok "Volumen cifrado formateado."

  log "Configurando persistence.conf..."
  MOUNT_POINT="/mnt/eyegod_persist_$$"
  mkdir -p "$MOUNT_POINT"
  mount "/dev/mapper/${MAPPER_NAME}" "$MOUNT_POINT"
  echo "/ union" > "${MOUNT_POINT}/persistence.conf"
  umount "$MOUNT_POINT"
  rmdir "$MOUNT_POINT"

  cryptsetup luksClose "$MAPPER_NAME"
  ok "Volumen LUKS cerrado."
fi

# ── Verificación final ───────────────────────────────────────────────────────
echo ""
log "Verificando resultado final:"
lsblk "$HDD" -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT
echo ""

echo -e "${RED}╔══════════════════════════════════════════════════════════════════╗${RST}"
echo -e "${RED}║${GLD}  ✅  HDD EXTERNO CONFIGURADO CORRECTAMENTE                      ${RED}║${RST}"
echo -e "${RED}╠══════════════════════════════════════════════════════════════════╣${RST}"
if [ "$USE_LUKS" = false ]; then
  echo -e "${RED}║${RST}  Al bootear, selecciona en GRUB:                                 ${RED}║${RST}"
  echo -e "${RED}║${CYN}    💾 PERSISTENCIA EN HDD EXTERNO  [GUARDAR ESTADO]             ${RED}║${RST}"
else
  echo -e "${RED}║${RST}  Al bootear, selecciona en GRUB:                                 ${RED}║${RST}"
  echo -e "${RED}║${CYN}    🔐 PERSISTENCIA CIFRADA LUKS  [ENCRYPTED HDD]               ${RED}║${RST}"
  echo -e "${RED}║${RST}  Introduce tu contraseña LUKS cuando se solicite.               ${RED}║${RST}"
fi
echo -e "${RED}╠══════════════════════════════════════════════════════════════════╣${RST}"
echo -e "${RED}║${GLD}  ⚠  Deshabilita Secure Boot en BIOS antes de bootear  ⚠         ${RED}║${RST}"
echo -e "${RED}║${GLD}  ⚠  Selecciona el HDD externo como primer dispositivo de boot ⚠  ${RED}║${RST}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════╝${RST}"
