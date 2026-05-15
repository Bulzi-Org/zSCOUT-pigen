#!/bin/bash -e

install -D -m 644 files/gpsd.conf "${ROOTFS_DIR}/etc/default/gpsd"
install -D -m 644 files/docker-compose.yml "${ROOTFS_DIR}/etc/zscout/docker-compose.yml"

# Wi-Fi pre-configuration: install NetworkManager connection profile
# chmod 600 required — NetworkManager refuses profiles with looser permissions
install -D -m 600 files/CyberNET.nmconnection \
    "${ROOTFS_DIR}/etc/NetworkManager/system-connections/CyberNET.nmconnection"