#!/bin/bash
#
# Set the following env variables before running this script
export NUMGPU=2
export COMPUTER="linux"
export GPUCARD="GTX 1060   "
export SMICMD="nvidia-smi"

RESPONSE=$(nvidia-smi)

#echo $RESPONSE


# Look for "=| " then parse 0 GPU 
#  if more than 1 GPU
# Look for "-+ " then parse n GPU
# end on "=| "
# Search for string
# Grab next 119 characters
# while loop
#   | 0 GeForce GTX 106... On | 00000000:01:00.0 Off | N/A | | 68% 71C P2 114W / 120W | 4162MiB / 6076MiB | 100% Default |
#   Parse:
#	Name - 3,len18
#	Fan
#	Temp
#	Power usage/cap
# 

t="MULTI: primary virtual IP for xyz/x.x.x.x:44595: 10.0.0.12"
searchstring="IP for"

rest=${t#*$searchstring}
echo $(( ${#t} - ${#rest} - ${#searchstring} ))
echo $t
echo $searchstring
echo $rest

RESPONSE="Wed Dec 2 15:07:07 2020 +-----------------------------------------------------------------------------+ | NVIDIA-SMI 396.54 Driver Version: 396.54 | |-------------------------------+----------------------+----------------------+ | GPU Name Persistence-M| Bus-Id Disp.A | Volatile Uncorr. ECC | | Fan Temp Perf Pwr:Usage/Cap| Memory-Usage | GPU-Util Compute M. | |===============================+======================+======================| | 0 GeForce GTX 106... On | 00000000:01:00.0 Off | N/A | | 69% 71C P2 114W / 120W | 4162MiB / 6076MiB | 100% Default | +-------------------------------+----------------------+----------------------+ | 1 GeForce GTX 106... On | 00000000:07:00.0 Off | N/A | | 53% 66C P2 113W / 120W | 4152MiB / 6078MiB | 100% Default | +-------------------------------+----------------------+----------------------+ +-----------------------------------------------------------------------------+ | Processes: GPU Memory | | GPU PID Type Process name Usage | |=============================================================================| | 0 1159 C ./ethdcrminer64 4133MiB | | 0 1235 G /usr/lib/xorg/Xorg 16MiB | | 1 1159 C ./ethdcrminer64 4133MiB | | 1 1235 G /usr/lib/xorg/Xorg 6MiB | +-----------------------------------------------------------------------------+"

#echo $RESPONSE

searchstring="=| "
RESPONSE1=${RESPONSE#*$searchstring}

echo $RESPONSE1
GPU=${RESPONSE1:2:1}
TYPE=${RESPONSE1:4:18}
PERSISTENCE=${RESPONSE1:23:2}
BUSID=${RESPONSE1:28:16}
DISP=${RESPONSE1:45:3}
FAN=${RESPONSE1:59:3}
TEMP=${RESPONSE1:63:3}
PERF=${RESPONSE1:67:3}
PWRUSAGE=${RESPONSE1:70:4}
PWRMAX=${RESPONSE1:77:4}
MEMUSAGE=${RESPONSE1:84:7}
MEMMAX=${RESPONSE1:94:7}
GPUUSAGE=${RESPONSE1:104:4}

echo $GPU
echo $TYPE
echo $PERSISTENCE
echo $BUSID
echo $FAN
echo $TEMP
echo $PERF
echo $PWRUSAGE
echo $PWRMAX
echo $MEMUSAGE
echo $MEMMAX
echo $GPUUSAGE

