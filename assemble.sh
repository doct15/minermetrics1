#!/bin/bash
#
DIR_TO_FILES="/home/metrics/minermetrics1/worker_files"
WEBFILENAME="webfile.html"
CSSFILENAME="metrics.css"
PASSWORD=$(cat /etc/miner.pwd)
MINERADDR=$(cat /etc/miner.addr)
MINERS=( "linux" "gamer" "miner" )
WORKERS=( "ewok10" "ewok20" "ewok30" )

#MINERS=( "linux" "miner" )
#WORKERS=( "ewok10" "ewok30" )

PHONENUM=$(cat /etc/phone.number)
PHONEPWD=$(cat /etc/pom.pwd)
PAGERFILE="pager.timer"
#LOGFILE=$DIR_TO_FILES/log.txt
TIMEOUT_FILE=910
TIMEOUT_MINER=59
TRIES=10
TEMP_WARN=49

function page_msg () {
  # Paging Brian PHONENUM
  if [[ -z $1 ]]; then
    MSG="No Message"
  else
    MSG=$1
  fi
  if ! [ -e $DIR_TO_FILES/$PAGERFILE ]; then
    #echo "File doesn't exist" >> "$LOGFILE"
    touch $DIR_TO_FILES/$PAGERFILE
  else
    #echo "File exists" >> "$LOGFILE"
    #LS=$(ls -la $DIR_TO_FILES/$PAGERFILE)
    #echo "ls $LS" >> "$LOGFILE"
    FILETIME=$(date -d"$(stat -c '%y' $DIR_TO_FILES/$PAGERFILE)" +%s)
    #echo "filetime $FILETIME" >> "$LOGFILE"
    TIMEDIFF=$(($(date +%s)-FILETIME))
    #echo "date $(date +%s)" >> "$LOGFILE"
    if ((TIMEDIFF<600)); then
      return
    else
      touch $DIR_TO_FILES/$PAGERFILE
    fi
  fi
  sendemail -f doc@tavian.com -t $PHONENUM@tmomail.net -u "Miner Alert" -m "$MSG" -s smtp.tavian.com:587 -xu distelli@tavian.com -xp $PHONEPWD -v
}

echo "Starting Assembly."
echo "<html><head><link rel="stylesheet" href="$CSSFILENAME" /></head><body bgcolor=#000000>" > $DIR_TO_FILES/$WEBFILENAME
astack=0
for MINER in ${MINERS[@]}; do
  WORKER=${WORKERS["$astack"]}
  WORKEROK="OK"
  astack=$((astack + 1))
  FILENAME="$DIR_TO_FILES/$MINER.metrics"
  FILEDATA=""
  if [ ! -f $FILENAME ]; then
    echo "File $FILENAME doesn't exist."
    exit
  fi
  attempts=0
  while [ "${FILEDATA: -11}" != "<!--DONE-->" ] && [ "$attempts" -lt "$TRIES" ]; do
    FILEDATA=$(cat $FILENAME)
    sleep 1
    let attempts++
  done

  MINERTIME=${FILEDATA:24:19}
  CURTIME=$(date +%s)
  TIMEDIFF=$((CURTIME-$(date -d"$MINERTIME" +%s)))
  CUR_TEMP=${FILEDATA:196:2}
  if ((TIMEDIFF>TIMEOUT_MINER)); then
    echo "Miner reporting timed out!"
    echo "Sending emergency page!"
    page_msg "Miner time out. MINER.sh is not working?" 
    WORKEROK="Timeout"
  fi
  if ((CUR_TEMP<TEMP_WARN)); then
    echo "Miner temperature drop!"
    echo "Sending emergency page!"
    page_msg "Miner temp low. Claymore may have stopped?" 
    WORKEROK="Stopped"
  fi

  echo "<table class=blueTable>" >> $DIR_TO_FILES/$WEBFILENAME
  if [ "$attempts" -lt "$TRIES" ]; then
    echo "$FILEDATA" >> $DIR_TO_FILES/$WEBFILENAME

    RESPONSE=$(curl -s https://api.ethermine.org/miner/$MINERADDR/worker/$WORKER/currentStats)
    WORKERCURHASHRATE=$(bc <<< "scale=1; $(echo $RESPONSE | jq .data.currentHashrate) / 1000000" )
    WORKERAVGHASHRATE=$(bc <<< "scale=1; $(echo $RESPONSE | jq .data.averageHashrate) / 1000000" )
       WORKERLASTSEEN=$(echo $RESPONSE | jq .data.lastSeen)
            TIMESINCE="$(($(date +%s)-$WORKERLASTSEEN))"

    echo "<tr><td colspan=5></td></tr>" >> $DIR_TO_FILES/$WEBFILENAME

    if [ $MINER == "miner" ]; then
      echo "<tr><td colspan=5 style=height:0% ></td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
    fi

    echo "<tr><th colspan=2>Worker</th><th>CurHash</th><th>AvgHash</th><th>IsOK</th></tr>" >> $DIR_TO_FILES/$WEBFILENAME
    echo "<tr><td colspan=2>$WORKER</td><td>$WORKERCURHASHRATE MH/s</td><td>$WORKERAVGHASHRATE MH/s</td><td>$WORKEROK</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME

  else
    echo "<tr><th colspan=5>$MINER data temporarily unavailable</th></tr>" >> $DIR_TO_FILES/$WEBFILENAME
    cat $DIR_TO_FILES/$WEBFILENAME
  fi

  echo "</table><br>" >> $DIR_TO_FILES/$WEBFILENAME
done

ETHPRICE=$(curl -s https://api.ethermine.org/poolStats | jq .data.price.usd)
RESPONSE=$(curl -s https://api.ethermine.org/miner/$MINERADDR/currentStats)
HASHRATE=$(bc <<< "scale=2; $(echo $RESPONSE | jq .data.currentHashrate) / 1000000")
UBALANCE=$(bc <<< "scale=6; $(echo $RESPONSE  | jq .data.unpaid) / 1000000000000000000")
CPM=$(echo $RESPONSE  | jq .data.coinsPerMin)
CPM=$(bc <<< "scale=8; ${CPM: 0:${#CPM}-4} / 10 ^ ${CPM: -1}")

echo "<table class=blueTable>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><th colspan=5>Totals</th></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><td colspan=2 align="right">Hash Rate:</td><td colspan=3>$HASHRATE Mh/s</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><td colspan=2 align="right">Unpaid:</td><td colspan=3>$UBALANCE coins</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><td colspan=2 align="right">Coin/min:</td><td colspan=3>$CPM</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "<tr><td colspan=2 align="right">Ethereum:</td><td colspan=3>\$ $ETHPRICE</td></tr>" >> $DIR_TO_FILES/$WEBFILENAME
echo "</table>" >> $DIR_TO_FILES/$WEBFILENAME

echo "</table></body></html>" >> $DIR_TO_FILES/$WEBFILENAME
cat $DIR_TO_FILES/$WEBFILENAME

echo "$(ncftpput -V -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $CSSFILENAME)"
echo "$(ncftpput -V -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$WEBFILENAME)"



