#!/bin/bash -e
# Configure system services: I2C, SSH, WiFi/BT, gpsd, Docker auto-start

# ── Enable I2C ───────────────────────────────────────────────────────────────
raspi-config nonint do_i2c 0

# ── Enable SSH ───────────────────────────────────────────────────────────────
systemctl enable ssh

# ── Enable gpsd ──────────────────────────────────────────────────────────────
systemctl enable gpsd

# ── Enable Docker to start on boot ───────────────────────────────────────────
systemctl enable docker

# ── Create systemd service to run docker-compose on boot ─────────────────────
cat > /etc/systemd/system/zscout.service << 'EOF'
[Unit]
Description=zSCOUT Docker Compose Services
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/etc/zscout
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=120

[Install]
WantedBy=multi-user.target
EOF

systemctl enable zscout.service

# ── WiFi / Bluetooth ─────────────────────────────────────────────────────────
# WiFi and Bluetooth are enabled by default on CM5 with wireless.
# Users can configure WiFi SSID/password via:
#   - raspi-config on first boot
#   - wpa_supplicant.conf on the boot partition before first boot
#   - nmcli after boot (NetworkManager is installed)
rfkill unblock wifi 2>/dev/null || true
rfkill unblock bluetooth 2>/dev/null || true

# ── Wavelet uSDR PCIe module auto-load on boot ──────────────────────────────
echo "usdr_pcie_uram" > /etc/modules-load.d/usdr.conf
# ── Shell aliases in /etc/skel/.bashrc and zadmin's ~/.bashrc ─────────────────
# 1. Uncomment all standard alias lines (strip leading "# " from "# alias ..." lines)
# 2. Fix ll alias: ls -l → ls -Al (include hidden files, exclude . and ..)
for BASHRC in /etc/skel/.bashrc /home/zadmin/.bashrc; do
    if [ -f "${BASHRC}" ]; then
        sed -i 's/^#[[:space:]]*\(alias \)/\1/' "${BASHRC}"
        sed -i "s/alias ll=.*/alias ll='ls -Al'/" "${BASHRC}"
    fi
done