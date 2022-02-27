#!/bin/bash
#
sleep 30

export DISPLAY=:0.0
#export XAUTHORITY=/run/user/119/gdm/Xauthority
export XAUTHORITY=/run/user/1000/gdm/Xauthority
FANSPEED=75
TRANSFERRATEOFFSET=1000
CLOCKOFFSET=20

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

sleep 10
cd /home/doc/gminer
./start.sh &

