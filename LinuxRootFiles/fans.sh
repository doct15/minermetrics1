#!/bin/bash
#

export DISPLAY=:0.0
export XAUTHORITY=/var/run/lightdm/root/\:0
#export XAUTHORITY=/var/run/lightdm/.Xauthority
FANSPEED=90

for i in 0 1
do
  nvidia-settings -a "[gpu:$i]/GPUFanControlState=1" -a "[fan:$i]/GPUTargetFanSpeed=$FANSPEED"
done

