#!/bin/bash -e
# stage-zscout prerun — copy rootfs from previous stage
if [ ! -d "${ROOTFS_DIR}" ]; then
    copy_previous
fi
