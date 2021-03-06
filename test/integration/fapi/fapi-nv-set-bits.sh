#!/bin/bash

set -e
source helpers.sh

start_up

setup_fapi

function cleanup {
    tss2_delete --path /
    shut_down
}

trap cleanup EXIT

NV_PATH="/nv/Owner/NvBitmap"
BITMAP="0x0102030405060608"

tss2_provision

tss2_createnv --path $NV_PATH --type "noDa, bitfield" --size 0 --authValue ""

tss2_nvsetbits --nvPath $NV_PATH --bitmap $BITMAP

expect <<EOF
# Try with missing nvPath
spawn tss2_nvsetbits --bitmap $BITMAP
set ret [wait]
if {[lindex \$ret 2] || [lindex \$ret 3] != 1} {
    Command has not failed as expected\n"
    exit 1
}
EOF

expect <<EOF
# Try with missing bitmap
spawn tss2_nvsetbits --nvPath $NV_PATH
set ret [wait]
if {[lindex \$ret 2] || [lindex \$ret 3] != 1} {
    Command has not failed as expected\n"
    exit 1
}
EOF

expect <<EOF
# Try with wrong bitmap
spawn tss2_nvsetbits --nvPath $NV_PATH --bitmap abc
set ret [wait]
if {[lindex \$ret 2] || [lindex \$ret 3] != 1} {
    Command has not failed as expected\n"
    exit 1
}
EOF

exit 0