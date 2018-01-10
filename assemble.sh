#!/bin/bash
#
export DIR_TO_FILES="/home/metrics"

echo "<table border=1>" > $DIR_TO_FILES/webfile.html

for FILENAME in "$(ls $DIR_TO_FILES/*.metrics)"; do
  echo "$FILENAME"
  FILEDATA=$(cat $FILENAME)
  echo "$FILEDATA"
done