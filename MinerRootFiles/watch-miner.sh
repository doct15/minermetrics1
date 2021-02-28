#!/bin/bash
#
PID=$(pgrep -f ethdcrminer64)
if [ -z "$PID" ]
then
  echo "Process doesn't exist"
else
  tail -f /proc/$PID/fd/1
fi

