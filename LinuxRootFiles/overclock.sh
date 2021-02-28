#!/bin/bash
#

export DISPLAY=:0.0
export XAUTHORITY=/var/run/lightdm/root/\:0
FANSPEED=90
TRANSFERRATEOFFSET=1200
CLOCKOFFSET=80

for i in 0 1
do
  nvidia-settings -a "[gpu:$i]/GPUMemoryTransferRateOffset[3]=$TRANSFERRATEOFFSET"
  nvidia-settings -a "[gpu:$i]/GPUGraphicsClockOffset[3]=$CLOCKOFFSET"
  nvidia-settings -a "[gpu:$i]/GPUMemoryTransferRateOffset[2]=$TRANSFERRATEOFFSET"
  nvidia-settings -a "[gpu:$i]/GPUGraphicsClockOffset[2]=$CLOCKOFFSET"
  #nvidia-smi -i $i -pl 190 <Set max watt, not necessary
  #nvidia-settings -a "[gpu:$i]/GPUFanControlState=1" -a "[fan:$i]/GPUTargetFanSpeed=$FANSPEED"
  nvidia-settings -a "[gpu:$i]/GPUFanControlState=0"
done

