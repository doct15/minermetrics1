#!/bin/bash
#
export DIR_TO_FILES="/home/metrics"

for filename in "$(ls $DIR_TO_FILES*.metrics)"; do
  echo "$filename"
done