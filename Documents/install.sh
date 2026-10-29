#!/usr/bin/env bash
#
# WiFi testing toolkit + adapter-driver setup for Kali / Parrot (Debian-based).
# Installs the aircrack-ng suite and, on request, builds the RTL8812AU and
# RTL8188FU out-of-tree drivers via DKMS. Safe to re-run.
#
# Usage:  sudo ./install.sh
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root:  sudo ./install.sh" >&2
  exit 1
fi

# Run git/clone as the user who invoked sudo, so files land in their home.
REAL_USER="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$REAL_USER" | cut -d: -f6)"
WORKDIR="${HOME_DIR}/wifi-drivers"

echo "[*] Updating package lists..."
apt-get update -y

echo "[*] Installing the WiFi testing toolkit..."
apt-get install -y \
  aircrack-ng hashcat hcxdumptool hcxtools wifite reaver bully \
  hostapd dnsmasq mdk4 macchanger \
  git dkms build-essential libelf-dev

echo "[*] Installing kernel headers (needed to build drivers)..."
if ! apt-get install -y "linux-headers-$(uname -r)"; then
  echo "    Exact headers not found; trying the generic metapackage."
  apt-get install -y linux-headers-generic || \
    echo "    WARNING: no headers installed. Driver builds below will fail until you install them and reboot."
fi

# Clone a repo, or update it if already present (idempotent).
clone_or_update() {
  local url="$1" dir="$2"
  if [[ -d "$dir/.git" ]]; then
    echo "[*] Updating $(basename "$dir")..."
    sudo -u "$REAL_USER" git -C "$dir" pull --ff-only || true
  else
    echo "[*] Cloning $(basename "$dir")..."
    sudo -u "$REAL_USER" git clone --depth 1 "$url" "$dir"
  fi
}

sudo -u "$REAL_USER" mkdir -p "$WORKDIR"
echo "[*] Driver sources will live in: $WORKDIR"

# --- RTL8812AU / 8814AU / 8821AU (Alfa AWUS036ACH and many dual-band cards) ---
read -rp "Build the RTL8812AU driver (Alfa ACH / dual-band Realtek)? [y/N] " ans812 || ans812=n
if [[ "${ans812,,}" == "y" ]]; then
  clone_or_update "https://github.com/aircrack-ng/rtl8812au.git" "$WORKDIR/rtl8812au"
  ( cd "$WORKDIR/rtl8812au" && make dkms_install )
fi

# --- RTL8188FU (TP-Link TL-WN725N v3 and similar) ---
read -rp "Build the RTL8188FU driver (TP-Link WN725N v3)? [y/N] " ans188 || ans188=n
if [[ "${ans188,,}" == "y" ]]; then
  clone_or_update "https://github.com/kelebek333/rtl8188fu.git" "$WORKDIR/rtl8188fu"
  ( cd "$WORKDIR/rtl8188fu" && ./dkms-install.sh )
fi

echo
echo "[+] Done. Verify the adapter:"
echo "      lsusb        # is the dongle listed?"
echo "      iwconfig     # does a wlanX interface appear?"
echo
echo "    Unplug and replug the adapter (or reboot) so a freshly built driver loads."
echo "    This script does NOT reboot for you."
