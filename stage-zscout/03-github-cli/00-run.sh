#!/bin/bash -e
# GitHub CLI apt repository: add GPG keyring and sources.list entry (host-side)
# Runs outside the chroot; writes directly into ROOTFS_DIR.

install -m 0755 -d "${ROOTFS_DIR}/usr/share/keyrings"
install -m 0755 -d "${ROOTFS_DIR}/etc/apt/sources.list.d"

echo "[github-cli] Fetching GitHub CLI apt keyring..."
if ! curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o "${ROOTFS_DIR}/usr/share/keyrings/githubcli-archive-keyring.gpg"; then
  echo "ERROR: Failed to download GitHub CLI apt keyring" >&2
  exit 1
fi
chmod go+r "${ROOTFS_DIR}/usr/share/keyrings/githubcli-archive-keyring.gpg"

echo "deb [arch=arm64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  > "${ROOTFS_DIR}/etc/apt/sources.list.d/github-cli.list"

echo "[github-cli] Keyring and sources.list written successfully."
