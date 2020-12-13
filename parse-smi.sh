#!/bin/bash
#

# Wait for miners to deliver files
sleep 50

#DIR_TO_FILES="/home/metrics/minermetrics1/worker_files"
DIR_TO_FILES="/home/doc/Applications/minermetrics1/data"
FILE_EXT=".metrics"
WEBFILENAME="webfile.html"
CSSFILENAME="metrics.css"
MINERADDR="0xa4df0737ee0345271b41105e2e37a3eae471d772"
MINERS=( "gamer" "linux" "miner" )
APITOKEN=$(cat /etc/miner.apitoken)
PASSWORD=$(cat /etc/miner.pwd)
OWNEDETH=$(curl -s "https://api.etherscan.io/api?module=account&action=balance&address=$MINERADDR&tag=latest&apikey=$APITOKEN")

#DASHBOARD=$(curl -s https://api.ethermine.org/miner/$MINERADDR/dashboard)
STATS=$(curl -s https://api.ethermine.org/miner/$MINERADDR/currentStats)
CURRENTHASHRATE=$(bc <<< "scale=2; $(echo $STATS | jq .data.currentHashrate) / 1000000")
VALIDSHARES=$(echo $STATS | jq .data.validShares)
INVALIDSHARES=$(echo $STATS | jq .data.invalidShares)
ACTIVEWORKERS=$(echo $STATS | jq .data.activeWorkers)
UBALANCE=$(bc <<< "scale=6; $(echo $STATS  | jq .data.unpaid) / 1000000000000000000")
ETHPRICE=$(curl -s https://api.ethermine.org/poolStats | jq .data.price.usd)
CPM=$(echo $STATS  | jq .data.coinsPerMin)
CPM=$(bc <<< "scale=8; ${CPM: 0:${#CPM}-4} / 10 ^ ${CPM: -1}")
ETHOWNED=$(curl -s "https://api.etherscan.io/api?module=account&action=balance&address=$MINERADDR&tag=latest&apikey=$APITOKEN" | jq -r .result)
ETHOWNED=$(bc <<< "scale=8; $(echo $ETHOWNED  / 1000000000000000000)")
echo $ETHOWNED
GPUDATA=(NAME BUSID TEMP FAN GPUUTIL MEMUTIL MEMTOTAL MEMFREE MEMUSED POWDRAW POWLIMIT)
FIELDSTOSHOW=( 0 1 2 3 4 5 8 6 )
#MINERSTATS=$(curl -s https://api.ethermine.org/miner/$MINERADDR/worker/$WORKER/currentStats)

#nvidia-smi --query-gpu=name,pci.bus_id,temperature.gpu,fan.speed,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used,power.draw,power.limit --format=csv > linux.miner
#Current Eth owned 954856815755150031. Where does the decimal go?

cat  > $DIR_TO_FILES/$WEBFILENAME <<EOF
<html>
  <head>
    <meta http-equiv="refresh" content="60">
    <link rel="stylesheet" href="$CSSFILENAME" />
  </head>
  <body bgcolor=#000000>
    <table class=blueTable>
      <tr>
        <th colspan=1>$MINERADDR</th>
        <th colspan=1>Hash Rate: $CURRENTHASHRATE Mh/s</th>
        <th colspan=1>ETH: $ETHOWNED</th>        
      </tr>
    </table>
    <table class=blueTable>
      <tr>
        <td colspan=1 align="right">Workers</td>
        <td colspan=1 align="left">$ACTIVEWORKERS</td>
        <td colspan=1 align="right">Valid Shares</td>
        <td colspan=1 align="left">$VALIDSHARES</td>
        <td colspan=1 align="right">Invalid Shares</td>
        <td colspan=1 align="left">$INVALIDSHARES</td>                
      </tr>
      <tr>
        <td colspan=1 align="right">Unpaid Balance</td>
        <td colspan=1 align="left">$UBALANCE</td>
        <td colspan=1 align="right">ETH per minute</td>
        <td colspan=1 align="left">$CPM</td>
        <td colspan=1 align="right">1 ETH in USD</td>
        <td colspan=1 align="left">$ETHPRICE</td>                
      </tr>
      <tr>      
        <td colspan=6 style="background-color:#FFFFFF"></td>
      </tr>
    </table>
    </br>
EOF

for miner in ${MINERS[@]}
do
  MINERFILE="$DIR_TO_FILES/$miner.metrics"
  #echo $MINERFILE
  linenum=1
  gpu=0
  while read line;
  do
	  #echo "$linenum $line"
	  if [ "$linenum" -eq "1" ]
	  then
		  NUMGPU=${line:0:1}
		  MINERNAME=${line:1:5}
		  DATADATE=${line:6:28}
		  MINERSTATS=$(curl -s https://api.ethermine.org/miner/$MINERADDR/worker/$MINERNAME/currentStats)
		  MINERCURRENTHASHRATE=$(bc <<< "scale=2; $(echo $MINERSTATS | jq .data.currentHashrate) / 1000000")
		  MINERVALIDSHARES=$(echo $MINERSTATS | jq .data.validShares)
		  MINERINVALIDSHARES=$(echo $MINERSTATS | jq .data.invalidShares)
cat >> $DIR_TO_FILES/$WEBFILENAME <<EOF
    <table class=blueTable>
      <tr>
        <th colspan=1 width="20%">Miner: $MINERNAME</th>
        <th colspan=1>$NUMGPU GPUs</th>
        <th colspan=1>Hash Rate: $MINERCURRENTHASHRATE MH/s</th>
        <td colspan=1 align="right">$DATADATE</td>
      </tr>
    </table>
    <table class=blueTable>
      <tr>
        <td colspan=1 align="right" width="20%">Valid Shares</td>
        <td colspan=1 align="left" width="30%">$MINERVALIDSHARES</td>
        <td colspan=1 align="right" width="20%">Invalid Shares</td>
        <td colspan=1 align="left" width="30%">$MINERINVALIDSHARES</td>
        <td colspan=2></td>
      </tr>
    </table>
    <table class=blueTable>
EOF

	  elif [ "$linenum" -ne "2" ]
	  then
		  #read vars
		  IFS=',' read -r -a gpuvalues <<< "$line"
		  #echo "${gpuvalues[@]}"
		  for (( field=0; field<${#gpudata[@]}; field++ ))
		  do
			  echo "$field - ${gpudata[$field]} = ${gpuvalues[$field]}"
		  done
		  if [ "$linenum" -eq "3" ]
		  then
      echo "      <tr>" >> $DIR_TO_FILES/$WEBFILENAME		  
		    for field in ${FIELDSTOSHOW[@]}
		    do
		      echo "        <th colspan=1 align=\"center\">${GPUDATA[$field]}</th>" >> $DIR_TO_FILES/$WEBFILENAME
		    done
		    echo "      </tr>" >> $DIR_TO_FILES/$WEBFILENAME
		  fi
      echo "      <tr>" >> $DIR_TO_FILES/$WEBFILENAME		  
	    for field in ${FIELDSTOSHOW[@]}
	    do
  		  echo "        <td colspan=1 align=\"center\">${gpuvalues[$field]}</td>" >> $DIR_TO_FILES/$WEBFILENAME
  		done
      echo "      </tr>" >> $DIR_TO_FILES/$WEBFILENAME
		  ((gpu=gpu++))
	  fi
	  ((linenum=linenum+1))
  done < $MINERFILE
  echo "    <tr><td colspan=8 style="background-color:#FFFFFF"></td></tr></table>" >> $DIR_TO_FILES/$WEBFILENAME
done
echo "</body></html>" >> $DIR_TO_FILES/$WEBFILENAME

echo "$(ncftpput -V -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$CSSFILENAME)"
echo "$(ncftpput -V -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$WEBFILENAME)"








