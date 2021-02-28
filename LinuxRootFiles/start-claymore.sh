#!/bin/bash
#

export DISPLAY=:0.0
#export XAUTHORITY=/var/run/lightdm/root/\:0
export XAUTHORITY=/run/user/121/gdm/Xauthority
nvidia-smi -pm 1

sleep 2

/root/overclock.sh

sleep 2

cd /home/doc/Claymore
./start.sh &


