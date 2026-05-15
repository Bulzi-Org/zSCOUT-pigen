#!/bin/bash -e
# GitHub CLI: install gh package from the pre-seeded apt repository

apt-get update
apt-get install -y gh

# Verify gh binary is present and executable
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh binary not found after installation — bailing out" >&2
  exit 1
fi

echo "[github-cli] gh installed: $(gh --version | head -1)"
