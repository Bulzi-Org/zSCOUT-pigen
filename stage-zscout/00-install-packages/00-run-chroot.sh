#!/bin/bash -e
# Install Docker Engine + Compose, LimeSuite/SoapySDR (USB), Wavelet uSDR PCIe driver, Morse Micro driver

# ── Docker Engine ────────────────────────────────────────────────────────────
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add zadmin user to docker group
usermod -aG docker zadmin

# ── SoapySDR ─────────────────────────────────────────────────────────────────
apt-get install -y soapysdr-tools libsoapysdr-dev soapysdr-module-all

# ── LimeSuite (USB transport library for LMS7002M) ──────────────────────────
apt-get install -y limesuite limesuite-udev

# ── Wavelet Lab uSDR PCIe driver + userspace stack ───────────────────────────
# Packages: usdr-dkms  usdr-tools  libusdr0  soapysdr-module-usdr
# Source: https://github.com/wavelet-lab/usdr-lib/releases
USDR_VERSION="0.9.9~bookworm0"
USDR_TARBALL="usdr_${USDR_VERSION}.arm64.tar"
USDR_URL="https://github.com/wavelet-lab/usdr-lib/releases/download/v0.9.9/${USDR_TARBALL}"

USDR_TMPDIR="$(mktemp -d)"
trap 'rm -rf "${USDR_TMPDIR}"' EXIT

echo "[usdr] Downloading ${USDR_TARBALL}..."
if ! curl -fsSL --retry 3 --retry-delay 5 -o "${USDR_TMPDIR}/${USDR_TARBALL}" "${USDR_URL}"; then
  echo "ERROR: Failed to download Wavelet uSDR release tarball from ${USDR_URL}" >&2
  exit 1
fi

tar -xf "${USDR_TMPDIR}/${USDR_TARBALL}" -C "${USDR_TMPDIR}"
dpkg -i --force-reinstall "${USDR_TMPDIR}"/*.deb
apt-get install -f -y

# Verify udev rules were installed by the usdr-dkms package (FR-005)
if [ ! -f /etc/udev/rules.d/50-usdr-pcie-driver.rules ]; then
  echo "ERROR: 50-usdr-pcie-driver.rules was not installed by usdr-dkms — device node permissions will be wrong" >&2
  exit 1
fi

# Verify DKMS compiled the module successfully in this chroot (SC-004)
if ! dkms status 2>/dev/null | grep -q "usdr.*installed"; then
  echo "ERROR: DKMS did not report usdr_pcie_uram as installed — module may fail to load on boot" >&2
  dkms status 2>/dev/null >&2 || true
  exit 1
fi

# ── Morse Micro MM8108 driver ────────────────────────────────────────────────
# TODO: Replace with actual Morse Micro driver source (git repo or .deb URL)
# when vendor provides the package.
# Placeholder: create a marker so the driver can be installed post-build.
mkdir -p /opt/morse-micro
echo "# Morse Micro MM8108 driver placeholder" > /opt/morse-micro/README
echo "# Install the morse_driver module here." >> /opt/morse-micro/README
