#!/bin/sh
set -eux

ipxe-make bin/ipxe.pxe
test -f /out/ipxe.pxe

ipxe-make bin/undionly.pxe DEBUG=scsi,iscsi OUTPUT_DIR=/out2
test -f /out2/undionly.pxe

ipxe-chainload http://myserver.lan/main.ixpe bin/ipxe.usb
test -f /out/ipxe.usb

ipxe-chainload http://myserver.lan/main.ixpe bin/ipxe.iso OUTPUT_DIR=/out2
test -f /out2/ipxe.iso
