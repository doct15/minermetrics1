#!/bin/bash
#
export DIR_TO_FILES="/home/metrics"

echo "<table border=1>" > $DIR_TO_FILES/webfile.html

for FILENAME in "$(ls $DIR_TO_FILES/*.metrics)"; do
  echo "$FILENAME"
  FILEDATA=""
  while [ "${FILEDATA: -11}" != "<!--DONE-->" ]; do
    FILEDATA=$(cat $FILENAME)
    echo "$FILEDATA"
  done
  echo "$FILEDATA" >> $DIR_TO_FILES/webfile.html
done

echo "</table>" >> $DIR_TO_FILES/webfile.html