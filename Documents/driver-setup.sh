#!/usr/bin/env bash
#
# External WiFi adapter: identify it, then install the right out-of-tree driver.
#
# On Parrot OS most of these drivers ship preinstalled. On Kali they usually do
# NOT, so if your external adapter does not show up, build its driver here.
#
# Drivers built from the aircrack-ng forks (best monitor-mode + injection support):
#   rtl8812au   https://github.com/aircrack-ng/rtl8812au   (also 8821au)
#   rtl8814au   https://github.com/aircrack-ng/rtl8814au
#   rtl8188eus  https://github.com/aircrack-ng/rtl8188eus   (also 8188eu)
#
# Usage:  sudo ./driver-setup.sh
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root:  sudo ./driver-setup.sh" >&2
  exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$REAL_USER" | cut -d: -f6)"
WORKDIR="${HOME_DIR}/wifi-drivers"

install_prereqs() {
  echo "[*] Installing build prerequisites..."
  apt-get update -y
  apt-get install -y git dkms build-essential libelf-dev "linux-headers-$(uname -r)" \
    || apt-get install -y git dkms build-essential libelf-dev linux-headers-generic
}

# Clone fresh or update in place (idempotent), as the real user.
clone_or_update() {
  local url="$1" dir="$2"
  if [[ -d "$dir/.git" ]]; then
    echo "[*] Updating $(basename "$dir")..."
    sudo -u "$REAL_USER" git -C "$dir" pull --ff-only || true
  else
    echo "[*] Cloning $url ..."
    sudo -u "$REAL_USER" git clone --depth 1 "$url" "$dir"
  fi
}

build_driver() {
  local name="$1" url="$2"
  install_prereqs
  sudo -u "$REAL_USER" mkdir -p "$WORKDIR"
  clone_or_update "$url" "$WORKDIR/$name"
  echo "[*] Building and registering $name with DKMS (survives kernel updates)..."
  ( cd "$WORKDIR/$name" && make dkms_install )
  echo
  echo "[+] $name installed. Unplug and replug the adapter (or reboot) so it loads."
}

# Option 1: identify the adapter and the driver currently bound to it.
identify_adapter() {
  echo "================ USB devices (look for your adapter) ================"
  lsusb || true
  echo
  echo "================ Wireless interfaces and their drivers ============="
  local found=0
  for dev in /sys/class/net/*; do
    [[ -e "$dev/wireless" || -e "$dev/phy80211" ]] || continue
    found=1
    local iface drv
    iface="$(basename "$dev")"
    drv="$(basename "$(readlink -f "$dev/device/driver" 2>/dev/null || echo unknown)")"
    echo "  interface: $iface    driver: $drv"
  done
  [[ $found -eq 0 ]] && echo "  No wireless interface found. The adapter has no working driver yet."
  echo
  echo "Chipset hints from lsusb (match to a driver below):"
  echo "  Realtek 8812au/8821au  -> option 2 (rtl8812au)"
  echo "  Realtek 8814au         -> option 3 (rtl8814au)"
  echo "  Realtek 8188eus/8188eu -> option 4 (rtl8188eus)"
  echo "  Atheros AR9271 / MediaTek MT7612U -> in-kernel, no build needed"
  echo
  echo "Tip: 'sudo dmesg | tail -20' right after plugging in shows what the kernel saw."
}

while true; do
  cat <<'MENU'

====== External WiFi adapter: identify and install driver ======
  1) Identify my adapter (lsusb + current driver)
  2) Install rtl8812au  (Realtek 8812au / 8821au, e.g. Alfa AWUS036ACH)
  3) Install rtl8814au  (Realtek 8814au, high-power dual-band)
  4) Install rtl8188eus (Realtek 8188eus / 8188eu)
  5) Quit
MENU
  read -rp "Choose [1-5]: " choice || choice=5
  case "$choice" in
    1) identify_adapter ;;
    2) build_driver "rtl8812au"  "https://github.com/aircrack-ng/rtl8812au.git" ;;
    3) build_driver "rtl8814au"  "https://github.com/aircrack-ng/rtl8814au.git" ;;
    4) build_driver "rtl8188eus" "https://github.com/aircrack-ng/rtl8188eus.git" ;;
    5) echo "Bye."; exit 0 ;;
    *) echo "Pick 1-5." ;;
  esac
done
