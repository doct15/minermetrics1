#!/bin/bash
#
# Set the following env variables before running this script
# NUMGPU=0              - Number of GPUs
# COMPUTER="gamer"      - Name of miner
# GPUCARD="GTX 1080 ti" - Type of GPU Card
DIR_TO_FILES="minermetrics1/worker_files"
WORKING_FILES="temp"
WAIT=55
TEMPWARN=83
TEMPEMER=85
PASSWORD=$(cat /etc/pom.pwd)
PHONE=$(cat /etc/phone.number)

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
  cat "$WORKING_FILES/$COMPUTER.metrics" | ssh miner@linux "cat > $DIR_TO_FILES/$COMPUTER.metrics"

  echo -n "Sleeping for $WAIT"
  for ((s=0;s<WAIT;s++)); do
    echo -n "."
    sleep 1
  done

done
