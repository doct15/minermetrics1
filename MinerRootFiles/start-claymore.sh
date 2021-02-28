#!/bin/bash
#

export DISPLAY=:0.0
#export XAUTHORITY=/var/run/lightdm/root/\:0
export XAUTHORITY=/run/user/121/gdm/Xauthority
nvidia-smi -pm 1

sleep 3

/root/overclock.sh

sleep 4

cd /home/doc/Claymore
./start.sh &


