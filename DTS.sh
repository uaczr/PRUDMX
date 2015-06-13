#!/usr/bin/env bash

dtc -O dtb -o DMX-OVERLAY-00A0.dtbo -b 0 -@ dmx-overlay.dts

rm /lib/firmware/DMX-OVERLAY-00A0.dtbo

sleep 3

cp DMX-OVERLAY-00A0.dtbo /lib/firmware

sleep 3

cd /sys/devices/bone_capemgr*
echo 'DMX-OVERLAY' > slots

sleep 3

cat /sys/devices/bone_capemgr*/slots
