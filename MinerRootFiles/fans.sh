#!/bin/bash
#

export DISPLAY=:0.0
#export XAUTHORITY=/var/run/lightdm/root/\:0
export XAUTHORITY=/run/user/121/gdm/Xauthority
FANSPEED=77

for i in 0 1 2 3 4 5
do
  nvidia-settings -a "[gpu:$i]/GPUFanControlState=1" -a "[fan:$i]/GPUTargetFanSpeed=$FANSPEED"
done
