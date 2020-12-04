#!/bin/bash
#
# The following variables are set by the script that calls this (gamer.sh linux.sh miner.sh)
# NUMGPU=1              - Number of GPUs
# COMPUTER="gamer"      - Name of miner
# SMICMD="nvidia-smi"   - Command to run nvidia-smi (different on windows)
DIR_TO_FILES="/home/doc/Applications/minermetrics1/data"
WORKING_FILE="$COMPUTER.miner"
DESTINATION_DIR="Applications/minermetrics1/data"

echo "$NUMGPU$COMPUTER$(date)" > $DIR_TO_FILES/$WORKING_FILE
$SMICMD --query-gpu=name,pci.bus_id,temperature.gpu,fan.speed,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used,power.draw,power.limit --format=csv >> $DIR_TO_FILES/$WORKING_FILE

cat "$DIR_TO_FILES/$WORKING_FILE" | ssh doc@linux "cat > $DESTINATION_DIR/$COMPUTER.metrics"

exit

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
    if [ "$TEMP" -gt "$TEMPEMER" ]; then
      echo "Sending Temperature Warning Text to $PHONE"
      sendemail -f doc@tavian.com -t $PHONE@tmomail.net -u "Mining Temp Warning!" -m "Miner: $COMPUTER - GPU: $GPU - TEMP: $TEMP c is higher than threshold of $TEMPWARN c" -s smtp.tavian.com:587 -xu distelli@tavian.com -xp $PASSWORD -v
    fi
    if [ "$TEMP" -gt "$TEMPWARN" ]; then
      echo "Sending Temperature Warning eMail to doc@tavian.com"
      sendemail -f doc@tavian.com -t doc@tavian.com -u "Mining Temp Warning $TEMP c!" -m "Miner: $COMPUTER - GPU: $GPU - TEMP: $TEMP c is higher than threshold of $TEMPWARN c" -s smtp.tavian.com:587 -xu distelli@tavian.com -xp $PASSWORD -v
      TEMP="<b>$TEMP</b>"
    fi
    echo "GPU:$GPU - $GPUCARD - FAN:$SPEED - MEM:$MEM - TEMP:$TEMP"
    echo "<tr><td>$GPU</td><td>$GPUCARD</td><td>$SPEED</td><td>$MEM</td><td>$TEMP c</td></tr>" >> "$WORKING_FILES/$COMPUTER.metrics"
  done

  echo "<!--DONE-->" >> "$WORKING_FILES/$COMPUTER.metrics"
  cat "$WORKING_FILES/$COMPUTER.metrics" | ssh doc@linux "cat > $DIR_TO_FILES/$COMPUTER.metrics"

  echo -n "Sleeping for $WAIT"
  for ((s=0;s<WAIT;s++)); do
    echo -n "."
    sleep 1
  done

done
