#!/bin/bash
#
export DIR_TO_FILES="/home/metrics"
export WEBFILENAME="webfile.html"
PASSWORD=$(cat /etc/miner.pwd)

while true; do

  echo "Starting Assembly."

  echo "<table border=1>" > $DIR_TO_FILES/$WEBFILENAME

  for FILENAME in "$(ls $DIR_TO_FILES/*.metrics)"; do
    echo "$FILENAME"
    FILEDATA=""
    while [ "${FILEDATA: -11}" != "<!--DONE-->" ]; do
      FILEDATA=$(cat $FILENAME)
      echo "$FILEDATA"
    done
    echo "$FILEDATA" >> $DIR_TO_FILES/$WEBFILENAME
  done

  echo "</table>" >> $DIR_TO_FILES/$WEBFILENAME

  cat $DIR_TO_FILES/$WEBFILENAME
  echo "ncftpput -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$WEBFILENAME"
  echo "$(ncftpput -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$WEBFILENAME)"

  echo "Waiting..."
  sleep 30

done