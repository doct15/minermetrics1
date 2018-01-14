#!/bin/bash
#
# Set the following env variables before running this script
# NUMGPU=0              - Number of GPUs
# COMPUTER="gamer"      - Name of miner
# GPUCARD="GTX 1080 ti" - Type of GPU Card
DIR_TO_FILES="minermetrics1/worker_files"
WORKING_FILES="temp"
WAIT=25

while true; do

  DATE=$(date '+%Y/%m/%d %H:%M:%S')

  echo "Waking up $DATE - $COMPUTER GPU Metrics"

  echo "<tr><th COLSPAN=5>$COMPUTER $DATE</th></tr>" > "$WORKING_FILES/$COMPUTER.metrics"
  echo "<tr><th>GPU</th><th>CARD</th><th>SPEED</th><th>MEM</th><th>TEMP</th></tr>" >> "$WORKING_FILES/$COMPUTER.metrics"

  for ((GPU=0;GPU<=NUMGPU;GPU++)); do
    SPEED=$("$SMICMD" --query-gpu=fan.speed --format=csv -i $GPU | grep -e [0-9+])
    MEM=$("$SMICMD" --query-gpu=memory.used --format=csv -i $GPU | grep -e [0-9+])
    TEMP=$("$SMICMD" --query-gpu=temperature.gpu --format=csv -i $GPU | grep -e [0-9+])
    if [ $COMPUTER != "linux" ]; then
      SPEED=${SPEED:0:-1}
      MEM=${MEM:0:-1}
      TEMP=${TEMP:0:-1}
    fi
    echo "GPU:$GPU - $GPUCARD - FAN:$SPEED - MEM:$MEM - TEMP:$TEMP"
    echo "<tr><td>$GPU</td><td>$GPUCARD</td><td>$SPEED</td><td>$MEM</td><td>$TEMP c</td></tr>" >> "$WORKING_FILES/$COMPUTER.metrics"
  done

  echo "<!--DONE-->" >> "$WORKING_FILES/$COMPUTER.metrics"
  cat "$WORKING_FILES/$COMPUTER.metrics" | ssh metrics@10.0.0.2 "cat > $DIR_TO_FILES/$COMPUTER.metrics"

  echo -n "Sleeping for $WAIT"
  for ((s=0;s<WAIT;s++)); do
    echo -n "."
    sleep 1
  done

done
