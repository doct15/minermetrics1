#!/bin/bash
#
# Set the following env variables before running this script
# NUMGPU=0              - Number of GPUs
# COMPUTER="gamer"      - Name of miner
# GPUCARD="GTX 1080 ti" - Type of GPU Card

DATE=$(date '+%Y/%m/%d %H:%M:%S')

echo "<tr><th COLSPAN=5>$COMPUTER $DATE</th></tr>" | ssh metrics@10.0.0.2 "cat > $COMPUTER.metrics"
echo "<tr><th>GPU</th><th>CARD</th><th>SPEED</th><th>MEM</th><th>TEMP</th></tr>" | ssh metrics@10.0.0.2 "cat >> $COMPUTER.metrics"

for ((GPU=0;GPU<=NUMGPU;GPU++)); do

  SPEED=$(/mnt/c/Program\ Files/NVIDIA\ Corporation/NVSMI/nvidia-smi.exe --query-gpu=fan.speed --format=csv -i $GPU | grep -e [0-9+])
  SPEED=${SPEED:0:-1}

  MEM=$(/mnt/c/Program\ Files/NVIDIA\ Corporation/NVSMI/nvidia-smi.exe --query-gpu=memory.used --format=csv -i $GPU | grep -e [0-9+])
  MEM=${MEM:0:-1}

  TEMP=$(/mnt/c/Program\ Files/NVIDIA\ Corporation/NVSMI/nvidia-smi.exe --query-gpu=temperature.gpu --format=csv -i $GPU | grep -e [0-9+])
  TEMP=${TEMP:0:-1}

  echo "<tr><td>$GPU</td><td>$GPUCARD</td><td>$SPEED</td><td>$MEM</td><td>$TEMP c</td></tr>" | ssh metrics@10.0.0.2 "cat >> $COMPUTER.metrics"

done

# echo "</table>" | ssh metrics@10.0.0.2 "cat >> $COMPUTER.metrics"
echo "DONE" | ssh metrics@10.0.0.2 "cat >> $COMPUTER.metrics"
