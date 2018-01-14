#!/bin/bash
#
DIR_TO_FILES="/home/metrics/worker_files"
WEBFILENAME="webfile.html"
CSSFILENAME="metrics.css"
PASSWORD=$(cat /etc/miner.pwd)
MINERADDR=$(cat /etc/miner.addr)
MINERS=( "gamer" "linux" "miner" )
WORKERS=( "ewok20" "ewok10" "ewok30" )

echo "Starting Assembly."

#echo "<html><head> <meta http-equiv="refresh" content="30" /> </head>" > $DIR_TO_FILES/$WEBFILENAME
echo "<html><head><link rel="stylesheet" href="metrics.css" /></head>" > $DIR_TO_FILES/$WEBFILENAME
echo "<table style=blueTable>" >> $DIR_TO_FILES/$WEBFILENAME

astack=0
for MINER in ${MINERS[@]}; do
  WORKER=${WORKERS["$astack"]}
  astack=$((astack + 1))
  FILENAME="$DIR_TO_FILES/$MINER.metrics"
  FILEDATA=""
  if [ ! -f $FILENAME ]; then
    echo "File $FILENAME doesn't exist."
    exit
  fi
  while [ "${FILEDATA: -11}" != "<!--DONE-->" ]; do
    FILEDATA=$(cat $FILENAME)
    #echo "$FILEDATA"
    sleep 2
  done
  echo "$FILEDATA" >> $DIR_TO_FILES/$WEBFILENAME
  WORKERCURHASHRATE=$(bc <<< "scale=1; $(curl -s https://api.ethermine.org/miner/$MINERADDR/worker/$WORKER/currentStats | jq .data.currentHashrate) / 1000000" )
  WORKERAVGHASHRATE=$(bc <<< "scale=1; $(curl -s https://api.ethermine.org/miner/$MINERADDR/worker/$WORKER/currentStats | jq .data.averageHashrate) / 1000000" )
  echo "<tr><th colspan=2>Worker</th><th>CurHash</th><th>AvgHash</th><th>IsOK</th></tr>" >> $DIR_TO_FILES/$WEBFILENAME
  echo "<tr><td colspan=2>$WORKER</td><td>$WORKERCURHASHRATE MH/s</td><td>$WORKERAVGHASHRATE MH/s</td><td></td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
  echo "<tr><td colspan=5></td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
done

ETHPRICE=$(curl -s https://api.ethermine.org/poolStats | jq .data.price.usd)
RESPONSE=$(curl -s https://api.ethermine.org/miner/$MINERADDR/currentStats)
HASHRATE=$(bc <<< "scale=2; $(echo $RESPONSE | jq .data.currentHashrate) / 1000000")
UBALANCE=$(bc <<< "scale=6; $(echo $RESPONSE  | jq .data.unpaid) / 1000000000000000000")
CPM=$(echo $RESPONSE  | jq .data.coinsPerMin)
CPM=$(bc <<< "scale=8; ${CPM: 0:${#CPM}-4} / 10 ^ ${CPM: -1}")

echo "<tr><th colspan=5>Totals</th></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><td colspan=2 align="right">Hash Rate:</td><td colspan=3>$HASHRATE Mh/s</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><td colspan=2 align="right">Unpaid:</td><td colspan=3>$UBALANCE coins</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><td colspan=2 align="right">Coin/min:</td><td colspan=3>$CPM</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><td colspan=2 align="right">Ethereum:</td><td colspan=3>\$ $ETHPRICE</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME

echo "</table></html>" >> $DIR_TO_FILES/$WEBFILENAME
cat $DIR_TO_FILES/$WEBFILENAME

echo "$(ncftpput -V -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$CSSFILENAME)"

echo "$(ncftpput -V -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$WEBFILENAME)"



