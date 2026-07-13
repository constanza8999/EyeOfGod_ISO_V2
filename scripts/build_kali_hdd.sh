#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  EYE OF GOD V∞ × KALI PURPLE — BUILD SCRIPT                           ║
# ║  Kernel: linux-image-6.12.0-kali-amd64  (Kali Linux 2025.3)           ║
# ║  Target: HDD Externo / USB 3.x  —  BIOS + UEFI híbrido                ║
# ╚══════════════════════════════════════════════════════════════════════════╝
set -euo pipefail

# ── Trap para limpieza en caso de error ────────────────────────────────────────
CLEANUP_DIRS=()
cleanup() {
  local ec=$?
  if [ $ec -ne 0 ] && [ ${#CLEANUP_DIRS[@]} -gt 0 ]; then
    echo -e "\033[1;31m[ CLEANUP ]\033[0m Limpiando directorios temporales..."
    for d in "${CLEANUP_DIRS[@]}"; do
      [ -d "$d" ] && rm -rf "$d" 2>/dev/null && echo "  Eliminado: $d"
    done
  fi
  exit $ec
}
trap cleanup EXIT

# ── Colores ───────────────────────────────────────────────────────────────────
RED='\033[1;31m'; GLD='\033[38;5;220m'; GRN='\033[1;32m'
CYN='\033[1;36m'; MAG='\033[1;35m'; RST='\033[0m'

log()  { echo -e "${GLD}[BUILD]${RST} $*"; }
ok()   { echo -e "${GRN}[  OK ]${RST} $*"; }
fail() { echo -e "${RED}[FAIL ]${RST} $*"; exit 1; }
info() { echo -e "${CYN}[INFO ]${RST} $*"; }
warn() { echo -e "\033[38;5;208m[WARN ]${RST} $*"; }
step() { echo -e "\n${MAG}━━━ $* ━━━${RST}"; }

# ── Config ────────────────────────────────────────────────────────────────────
KALI_VERSION="2025.3"
KERNEL_VER="6.12.0-kali-amd64"
ISO_LABEL="EYEGOD_KALI_PURPLE"
ISO_OUT="EyeOfGod_KaliPurple_${KALI_VERSION}_HDD.iso"
BUILD_DIR="$(pwd)/eyegod_kali_build"
ISO_ROOT="${BUILD_DIR}/iso_root"
SQUASH_ROOT="${BUILD_DIR}/squash_root"
INITRAMFS_BUILD="${BUILD_DIR}/initramfs"
SRC_DIR="$(pwd)"                           # Dir con los archivos EyeGod
CLEAN_BUILD=false

# ── Procesar argumentos ───────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean|-c)
      CLEAN_BUILD=true
      shift
      ;;
    --help|-h)
      echo "Uso: sudo bash $0 [--clean] [DIRECTORIO_FUENTE]"
      echo "  --clean, -c    Elimina el directorio de build anterior antes de empezar"
      echo "  DIRECTORIO     Ruta con los archivos EyeGod (default: directorio actual)"
      exit 0
      ;;
    -*)
      echo "Opción desconocida: $1"
      echo "Uso: sudo bash $0 [--clean] [DIRECTORIO_FUENTE]"
      exit 1
      ;;
    *)
      SRC_DIR="$1"
      ;;
  esac
  shift
done

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "${RED}"
cat <<'BANNER'
  ╔══════════════════════════════════════════════════════════════╗
  ║   👁  EYE OF GOD V∞  ×  KALI PURPLE  —  HDD BUILD          ║
  ║       Kernel 6.12 | live-boot | overlayfs | LUKS            ║
  ╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${RST}"

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 1: VERIFICAR DEPENDENCIAS Y ENTORNO
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 1: Verificando dependencias y entorno"

# ── Verificar que no haya quedado basura de builds anteriores ────────────────
if [ -d "$BUILD_DIR" ] && ls "${BUILD_DIR}/"* >/dev/null 2>&1; then
  if [ "$CLEAN_BUILD" = true ]; then
    log "Limpiando build anterior: ${BUILD_DIR}"
    rm -rf "${BUILD_DIR}"
    ok "Build anterior eliminado."
  else
    warn "Directorio de build anterior detectado: ${BUILD_DIR}"
    warn "Usa --clean para eliminarlo automáticamente, o elimínalo manualmente."
    warn "Continuando con el build existente..."
  fi
fi

# ── Verificar que el directorio fuente exista ────────────────────────────────
if [ ! -d "$SRC_DIR" ] || [ "$SRC_DIR" = "/" ]; then
  fail "Directorio fuente inválido: ${SRC_DIR}. Pasa la ruta correcta como argumento."
fi
info "Directorio fuente: ${SRC_DIR}"

# ── Verificar que no haya caracteres raros en la ruta ────────────────────────
if echo "$SRC_DIR" | grep -qE '[{}]'; then
  warn "La ruta contiene llaves {} — posible error de expansión de variables."
  warn "Asegúrate de que la ruta sea correcta: ${SRC_DIR}"
fi

# ── Debe correrse en Kali Linux o Debian/Ubuntu ──────────────────────────────
if [ ! -f /etc/os-release ] || ! grep -qiE "kali|debian|ubuntu" /etc/os-release 2>/dev/null; then
  warn "No es Kali/Debian/Ubuntu — algunos pasos pueden fallar."
  warn "Se recomienda ejecutar este script en Kali Linux."
fi

# ── Verificar root (necesario para debootstrap) ──────────────────────────────
if [ "$EUID" -ne 0 ]; then
  fail "Este script requiere permisos de root (sudo). Ejecuta: sudo bash $0 $*"
fi

# ── Verificar dependencias ────────────────────────────────────────────────────
REQUIRED=(xorriso mksquashfs debootstrap)
MISSING=()
for cmd in "${REQUIRED[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || MISSING+=("$cmd")
done

if [ ${#MISSING[@]} -gt 0 ]; then
  info "Faltan: ${MISSING[*]}"
  info "Instalando dependencias..."
  apt-get update -qq
  apt-get install -y --no-install-recommends \
    xorriso squashfs-tools debootstrap \
    grub-pc-bin grub-efi-amd64-bin grub-efi-amd64 \
    mtools dosfstools live-build live-boot live-boot-initramfs-tools \
    cryptsetup-bin curl wget python3 python3-pip \
    memtest86+ 2>&1 | grep -E "(Installing|Unpacking|Setting up|ERROR)" || true
else
  ok "Dependencias verificadas."
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 2: CREAR ESTRUCTURA DE DIRECTORIOS
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 2: Creando estructura"

mkdir -p \
  "${ISO_ROOT}/boot/grub/fonts" \
  "${ISO_ROOT}/boot/grub/themes/eyegod-kali" \
  "${ISO_ROOT}/live" \
  "${ISO_ROOT}/install" \
  "${ISO_ROOT}/EFI/BOOT" \
  "${SQUASH_ROOT}/opt/eyegod/html" \
  "${SQUASH_ROOT}/etc/eyegod" \
  "${SQUASH_ROOT}/etc/systemd/system" \
  "${SQUASH_ROOT}/sbin" \
  "${SQUASH_ROOT}/var/log" \
  "${SQUASH_ROOT}/var/eyegod/subsystems" \
  "${SQUASH_ROOT}/root" \
  "${SQUASH_ROOT}/tmp"
ok "Directorios creados."

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 3: OBTENER KERNEL KALI 6.12
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 3: Obteniendo kernel Kali Linux 6.12"

VMLINUZ_DEST="${ISO_ROOT}/live/vmlinuz-${KERNEL_VER}"
INITRD_DEST="${ISO_ROOT}/live/initrd.img-${KERNEL_VER}"

# ── Método A: ya está en el sistema (si corremos en Kali) ────────────────────
if [ -f "/boot/vmlinuz-${KERNEL_VER}" ]; then
  cp "/boot/vmlinuz-${KERNEL_VER}"         "$VMLINUZ_DEST"
  cp "/boot/initrd.img-${KERNEL_VER}"      "$INITRD_DEST"  2>/dev/null || \
  cp "/boot/initrd-${KERNEL_VER}.img"      "$INITRD_DEST"  2>/dev/null || true
  ok "Kernel copiado desde el sistema host."

# ── Método B: descargarlo con apt ────────────────────────────────────────────
elif command -v apt-get >/dev/null 2>&1; then
  log "Descargando linux-image-${KERNEL_VER} con apt..."
  TMP_DEB_DIR="${BUILD_DIR}/deb_extract"
  mkdir -p "$TMP_DEB_DIR"
  cd /tmp
  apt-get download "linux-image-${KERNEL_VER}" 2>/dev/null || \
  apt-get download linux-image-amd64 2>/dev/null || true

  DEB=$(ls linux-image-*.deb 2>/dev/null | head -1)
  if [ -n "$DEB" ]; then
    dpkg-deb -x "$DEB" "${TMP_DEB_DIR}"
    find "${TMP_DEB_DIR}/boot" -name "vmlinuz-*" \
      -exec cp {} "$VMLINUZ_DEST" \; 2>/dev/null || true
    find "${TMP_DEB_DIR}/boot" -name "initrd*" \
      -exec cp {} "$INITRD_DEST" \;  2>/dev/null || true
    rm -rf "${TMP_DEB_DIR}" "$DEB"
    ok "Kernel extraído del paquete .deb"
  else
    warn "No se pudo descargar el paquete del kernel."
  fi
  cd - >/dev/null

# ── Método C: intentar con wget desde mirror Kali ─────────────────────────
else
  warn "Métodos automáticos agotados. Intentando fallback manual..."
fi

# ── Verificación y fallback progresivo ────────────────────────────────────────
if [ ! -f "$VMLINUZ_DEST" ]; then
  # Fallback 1: cualquier vmlinuz del sistema
  FALLBACK=$(find /boot -name "vmlinuz-*" 2>/dev/null | sort -V | tail -1)
  if [ -n "$FALLBACK" ]; then
    cp "$FALLBACK" "$VMLINUZ_DEST"
    INIT_FALLBACK="${FALLBACK/vmlinuz/initrd.img}"
    if [ -f "$INIT_FALLBACK" ]; then
      cp "$INIT_FALLBACK" "$INITRD_DEST"
    else
      # Intentar initrd- genérico
      INIT_FALLBACK2="$(dirname "$FALLBACK")/initrd.img-$(basename "$FALLBACK" | sed 's/vmlinuz-//')"
      [ -f "$INIT_FALLBACK2" ] && cp "$INIT_FALLBACK2" "$INITRD_DEST" || true
    fi
    warn "Usando kernel fallback: $FALLBACK"
    warn "⚠  Para Kali Purple real, reemplaza con linux-image-${KERNEL_VER}"
  else
    fail "No se encontró ningún kernel. Instala linux-image-amd64 primero."
  fi
fi

# ── Verificar que ambos archivos existen ──────────────────────────────────────
if [ ! -f "$VMLINUZ_DEST" ]; then
  fail "No se pudo obtener vmlinuz-${KERNEL_VER}"
fi
if [ ! -f "$INITRD_DEST" ]; then
  warn "No se pudo obtener initrd.img — se generará en boot si existe /sbin/mkinitramfs"
fi

# Symlinks canónicos
ln -sf "vmlinuz-${KERNEL_VER}"   "${ISO_ROOT}/live/vmlinuz"
ln -sf "initrd.img-${KERNEL_VER}" "${ISO_ROOT}/live/initrd.img" 2>/dev/null || true
ok "Kernel listo: $(ls -lh "$VMLINUZ_DEST" | awk '{print $5}' 2>/dev/null || echo 'N/A')"

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 4: CONSTRUIR SISTEMA RAÍZ (debootstrap Kali) O COPIAR EXISTENTE
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 4: Sistema raíz Kali Purple"

if [ -d "${SQUASH_ROOT}/usr/bin" ] && [ -f "${SQUASH_ROOT}/usr/bin/python3" ]; then
  ok "Sistema raíz ya existe, saltando debootstrap."
else
  log "Construyendo sistema raíz con debootstrap (puede tomar 15-30 minutos, depende de tu conexión)..."
  warn "Para Kali Purple completo, este paso instala paquetes base."
  warn "Para una ISO completa de Kali Purple, usa live-build en su lugar."

  # Verificar conectividad antes de debootstrap
  if ! curl --connect-timeout 5 -sI https://http.kali.org >/dev/null 2>&1; then
    warn "No hay conectividad con http.kali.org. El debootstrap puede fallar."
  fi

  if debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --include=python3,python3-pip,bash,curl,wget,openssh-client,net-tools,iproute2,cryptsetup \
    kali-rolling \
    "${SQUASH_ROOT}" \
    https://http.kali.org/kali 2>&1 | tail -10; then
    ok "debootstrap completado."
  else
    warn "debootstrap falló (¿sin acceso a mirror Kali?)."
    warn "Modo alternativo: copiando sistema host mínimo..."
    for d in bin sbin lib lib64 usr etc; do
      [ -d "/$d" ] && cp -a "/$d" "${SQUASH_ROOT}/" 2>/dev/null || true
    done
    ok "Sistema copiado del host (modo degradado)."
  fi
fi

# ── Instalar paquetes Python EyeGod dentro del chroot ────────────────────────
if [ -x "${SQUASH_ROOT}/usr/bin/python3" ]; then
  log "Instalando dependencias Python en squash root..."
  if chroot "${SQUASH_ROOT}" pip3 install --quiet \
    websockets aiohttp groq rich pyfiglet psutil 2>/dev/null; then
    ok "Dependencias Python instaladas."
  else
    warn "Algunas dependencias Python no se pudieron instalar (sin red?)."
  fi
fi

# ── Instalar kali-linux-purple dentro del chroot (si hay red) ───────────────
if chroot "${SQUASH_ROOT}" apt-get update -qq 2>/dev/null; then
  log "Instalando metapaquete kali-linux-purple..."
  if chroot "${SQUASH_ROOT}" apt-get install -y --no-install-recommends \
    kali-linux-purple kali-desktop-xfce live-boot live-config \
    linux-image-amd64 2>&1 | grep -E "(Install|Unpack|Setting|ERROR)" || true; then
    ok "Kali Purple instalado."
  else
    warn "Error instalando kali-linux-purple. Continuando con paquetes base."
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 5: COPIAR ARCHIVOS EYEGOD
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 5: Copiando archivos EyeGod"

# ── Verificar que el directorio fuente tenga contenido ────────────────────────
FILES_FOUND=0

for f in EyeGodV1000_10.py eyegod_bridge_v2000.py eyegod_iso_extensions.py \
          generate_subsystems.py requirements.txt; do
  if [ -f "${SRC_DIR}/${f}" ]; then
    cp "${SRC_DIR}/${f}" "${SQUASH_ROOT}/opt/eyegod/"
    ok "  → ${f}"
    FILES_FOUND=$((FILES_FOUND + 1))
  else
    info "  ✗ ${f} no encontrado en ${SRC_DIR}"
  fi
done

# HTMLs
for f in EyeGod_V2000_ULTRA.html eyegod_admin.html eyegod_checkout.html eyegod_license.html; do
  if [ -f "${SRC_DIR}/${f}" ]; then
    cp "${SRC_DIR}/${f}" "${SQUASH_ROOT}/opt/eyegod/html/"
    cp "${SRC_DIR}/${f}" "${SQUASH_ROOT}/opt/eyegod/"
    ok "  → ${f}"
    FILES_FOUND=$((FILES_FOUND + 1))
  fi
done

# ── PID 1 launcher ────────────────────────────────────────────────────────────
if [ -f "${SRC_DIR}/eyegod_pid1_launcher" ]; then
  cp "${SRC_DIR}/eyegod_pid1_launcher" "${SQUASH_ROOT}/sbin/eyegod_pid1_launcher"
  chmod +x "${SQUASH_ROOT}/sbin/eyegod_pid1_launcher"
  ok "  → eyegod_pid1_launcher"
  FILES_FOUND=$((FILES_FOUND + 1))
fi

# ── Systemd services ─────────────────────────────────────────────────────────
for svc in eyegod-kernel.service eyegod-bridge.service; do
  if [ -f "${SRC_DIR}/${svc}" ]; then
    cp "${SRC_DIR}/${svc}" "${SQUASH_ROOT}/etc/systemd/system/"
    ok "  → ${svc}"
    FILES_FOUND=$((FILES_FOUND + 1))
  fi
done

if [ $FILES_FOUND -eq 0 ]; then
  warn "No se encontraron archivos EyeGod en ${SRC_DIR}"
  warn "La ISO se generará sin los componentes EyeGod."
  warn "Asegúrate de ejecutar este script desde el directorio raíz del proyecto o pasar la ruta correcta."
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 6: CONFIGURACIÓN DEL SISTEMA
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 6: Configuración del sistema"

echo "EYEOFGOD" > "${SQUASH_ROOT}/etc/hostname"

# /etc/eyegod/config
cat > "${SQUASH_ROOT}/etc/eyegod/config" << 'CONF'
EYEGOD_VERSION=V_INFINITY
KALI_VERSION=2025.3
KERNEL=6.12.0-kali-amd64
WS_PORT=8765
HTTP_PORT=8766
SUBSYSTEM_COUNT=10000
CONSCIOUSNESS=SINGULARITY
AUTO_LAUNCH_BROWSER=true
CONF

# /etc/eyegod/secrets template
cat > "${SQUASH_ROOT}/etc/eyegod/secrets.template" << 'SEC'
# Copia a /etc/eyegod/secrets y rellena con tus credenciales
GROQ_API_KEY=YOUR_GROQ_API_KEY_HERE
ADMIN_SECRET=YOUR_ADMIN_SECRET_HERE
TELEGRAM_TOKEN=YOUR_TELEGRAM_TOKEN_HERE
SEC

# persistence.conf para live-boot
mkdir -p "${SQUASH_ROOT}/etc/live"
echo "/ union" > "${SQUASH_ROOT}/etc/live/persistence.conf" 2>/dev/null || true

ok "Sistema configurado."

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 7: SQUASHFS
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 7: Empaquetando filesystem.squashfs"

SQUASH_OUT="${ISO_ROOT}/live/filesystem.squashfs"
[ -f "$SQUASH_OUT" ] && rm -f "$SQUASH_OUT"

mksquashfs "${SQUASH_ROOT}" "$SQUASH_OUT" \
  -comp xz -Xbcj x86 -b 1M -noappend \
  -e "${SQUASH_ROOT}/proc" \
  -e "${SQUASH_ROOT}/sys" \
  -e "${SQUASH_ROOT}/dev" \
  -e "${SQUASH_ROOT}/run" \
  -e "${SQUASH_ROOT}/tmp" \
  2>&1 | grep -v "^$" | tail -5 || true

ok "Squashfs: $(du -sh "$SQUASH_OUT" | cut -f1)"

# ── Archivos de tamaño (necesarios para el instalador) ───────────────────────
du -sx --block-size=1 "${SQUASH_ROOT}" | cut -f1 > "${ISO_ROOT}/live/filesystem.size"
find "${SQUASH_ROOT}" -xdev -printf '%P\n' | sort > "${ISO_ROOT}/live/filesystem.manifest"

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 8: BOOTLOADER GRUB BIOS + UEFI
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 8: Instalando GRUB (BIOS + UEFI)"

# Copiar grub.cfg
[ -f "${SRC_DIR}/grub.cfg" ] && cp "${SRC_DIR}/grub.cfg" "${ISO_ROOT}/boot/grub/grub.cfg"
[ -f "${SRC_DIR}/grub_kali.cfg" ] && cp "${SRC_DIR}/grub_kali.cfg" "${ISO_ROOT}/boot/grub/grub.cfg"

# Copiar fuentes GRUB
for font_dir in /usr/share/grub /boot/grub; do
  [ -f "${font_dir}/unicode.pf2" ] && \
    cp "${font_dir}/unicode.pf2" "${ISO_ROOT}/boot/grub/fonts/" && break
done

# UEFI standalone
if command -v grub-mkstandalone >/dev/null 2>&1; then
  log "Generando BOOTX64.EFI (UEFI)..."
  grub-mkstandalone \
    -O x86_64-efi \
    --locales="" --themes="" --fonts="" \
    -o "${ISO_ROOT}/EFI/BOOT/BOOTX64.EFI" \
    "boot/grub/grub.cfg=${ISO_ROOT}/boot/grub/grub.cfg" \
    2>/dev/null && ok "BOOTX64.EFI generado." || info "UEFI standalone falló (no crítico)."
fi

# EFI image para xorriso
EFI_IMG="${BUILD_DIR}/efi.img"
dd if=/dev/zero of="$EFI_IMG" bs=1M count=8 status=none
if command -v mkfs.fat >/dev/null 2>&1; then
  mkfs.fat -F 12 -n "EFI" "$EFI_IMG" >/dev/null 2>&1
  mmd    -i "$EFI_IMG" ::/EFI ::/EFI/BOOT 2>/dev/null || true
  [ -f "${ISO_ROOT}/EFI/BOOT/BOOTX64.EFI" ] && \
    mcopy -i "$EFI_IMG" "${ISO_ROOT}/EFI/BOOT/BOOTX64.EFI" ::/EFI/BOOT/ 2>/dev/null || true
  ok "EFI image: $EFI_IMG"
fi

# Copiar módulos GRUB para BIOS
GRUB_BIOS_DIR=""
for d in /usr/lib/grub/i386-pc /usr/share/grub/i386-pc; do
  [ -d "$d" ] && GRUB_BIOS_DIR="$d" && break
done
if [ -n "$GRUB_BIOS_DIR" ]; then
  cp -r "$GRUB_BIOS_DIR" "${ISO_ROOT}/boot/grub/" 2>/dev/null || true
  ok "Módulos GRUB BIOS copiados."
fi

# memtest86+
for memtest in /boot/memtest86+.bin /boot/memtest86+x64.efi; do
  [ -f "$memtest" ] && cp "$memtest" "${ISO_ROOT}/boot/" && ok "memtest86+ copiado." && break
done

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 9: GENERAR ISO HÍBRIDA (BIOS + UEFI)
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 9: Generando ISO híbrida con xorriso"

# Buscar boot_hybrid.img para BIOS MBR
HYBRID_MBR=""
for p in \
  /usr/lib/grub/i386-pc/boot_hybrid.img \
  /usr/share/grub/i386-pc/boot_hybrid.img; do
  [ -f "$p" ] && HYBRID_MBR="$p" && break
done

if [ -z "$HYBRID_MBR" ]; then
  warn "No se encontró boot_hybrid.img. La ISO puede no ser booteable en BIOS."
fi

# Buscar core.img
CORE_IMG="${ISO_ROOT}/boot/grub/i386-pc/cdboot.img"
if [ ! -f "$CORE_IMG" ]; then
  CORE_IMG=$(find "${ISO_ROOT}/boot/grub" -name "cdboot.img" 2>/dev/null | head -1)
fi

if [ -z "$CORE_IMG" ]; then
  warn "No se encontró cdboot.img. La ISO puede no ser booteable en BIOS."
fi

# Construir comando xorriso
XORRISO_CMD=(
  xorriso -as mkisofs
  -iso-level 3
  -full-iso9660-filenames
  -volid "${ISO_LABEL}"
  -appid "EYE OF GOD V-INFINITY x KALI PURPLE ${KALI_VERSION}"
  -publisher "THE ARCHITECT / KALI LINUX"
  -preparer "EyeGod Build System"
  -output "${ISO_OUT}"
)

# BIOS boot
if [ -f "$CORE_IMG" ] && [ -n "$HYBRID_MBR" ]; then
  XORRISO_CMD+=(
    -b "boot/grub/i386-pc/eltorito.img"
    -no-emul-boot
    -boot-load-size 4
    -boot-info-table
    --grub2-boot-info
    --grub2-mbr "$HYBRID_MBR"
  )
elif [ -f "$CORE_IMG" ]; then
  warn "Falta boot_hybrid.img — continuando sin soporte MBR híbrido."
fi

# UEFI boot
if [ -f "$EFI_IMG" ]; then
  XORRISO_CMD+=(
    -eltorito-alt-boot
    -e --interval:appended_partition_2:all::
    -no-emul-boot
    -isohybrid-gpt-basdat
    -append_partition 2 0xef "$EFI_IMG"
  )
else
  warn "Falta EFI image — la ISO no será booteable en UEFI."
fi

XORRISO_CMD+=( "${ISO_ROOT}" )

# Mostrar comando completo (debug)
info "Ejecutando: xorriso -as mkisofs ..."
"${XORRISO_CMD[@]}" 2>&1 | grep -E "(ISO|Written|Error|warning|xorriso)" | tail -10

if [ -f "${ISO_OUT}" ]; then
  ok "ISO generada: ${ISO_OUT} ($(du -sh "${ISO_OUT}" | cut -f1))"
else
  fail "xorriso no generó la ISO. Revisa los mensajes arriba."
fi

# ══════════════════════════════════════════════════════════════════════════════
#  PASO 10: INSTRUCCIONES PARA HDD EXTERNO
# ══════════════════════════════════════════════════════════════════════════════
step "PASO 10: Preparar HDD Externo"

echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════════╗${RST}"
echo -e "${RED}║${GLD}  👁  BUILD COMPLETADO — EYE OF GOD V∞ × KALI PURPLE           ${RED}║${RST}"
echo -e "${RED}╠══════════════════════════════════════════════════════════════════╣${RST}"
echo -e "${RED}║${RST}  ISO: ${GLD}${ISO_OUT}${RST}"
echo -e "${RED}║${RST}  Kernel: ${CYN}linux-${KERNEL_VER}${RST}"
echo -e "${RED}║${RST}"
echo -e "${RED}║${GLD}  OPCIÓN A — LIVE en HDD externo (más simple):${RST}"
echo -e "${RED}║${RST}  sudo dd if=${ISO_OUT} of=/dev/sdX bs=4M status=progress && sync"
echo -e "${RED}║${RST}"
echo -e "${RED}║${GLD}  OPCIÓN B — HDD con persistencia:${RST}"
echo -e "${RED}║${RST}  1. Flashear ISO: dd if=${ISO_OUT} of=/dev/sdX bs=4M"
echo -e "${RED}║${RST}  2. Crear partición: sudo parted /dev/sdX mkpart primary ext4 5G 100%"
echo -e "${RED}║${RST}  3. Formatear:  sudo mkfs.ext4 -L persistence /dev/sdX3"
echo -e "${RED}║${RST}  4. Configurar: sudo mount /dev/sdX3 /mnt && echo '/ union' | sudo tee /mnt/persistence.conf"
echo -e "${RED}║${RST}  5. Bootear con 'PERSISTENCIA EN HDD EXTERNO' en el menú GRUB"
echo -e "${RED}║${RST}"
echo -e "${RED}║${GLD}  OPCIÓN C — Instalación completa en HDD externo:${RST}"
echo -e "${RED}║${RST}  Bootea el ISO → selecciona 'Instalar Kali Purple en HDD Externo'"
echo -e "${RED}║${RST}  ⚠  Asegúrate de seleccionar el HDD externo como destino"
echo -e "${RED}║${RST}"
echo -e "${RED}║${GLD}  PROBAR EN QEMU (sin HDD real):${RST}"
echo -e "${RED}║${RST}  qemu-system-x86_64 -m 4096 -enable-kvm -cdrom ${ISO_OUT} -boot d -vga virtio"
echo -e "${RED}║${RST}"
echo -e "${RED}║${MAG}  ⚠  Deshabilita Secure Boot en BIOS/UEFI antes de bootear  ⚠${RED}  ║${RST}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════╝${RST}"
echo ""
