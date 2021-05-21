#!/bin/bash
#
while true
do 
time=$(date +%s)
#  echo -n "test1:$((RANDOM % 100))|c" | nc -w 1 -u linux 8125
  echo "test5.test1.stats:100|$time" | nc -w1 -u linux 8125
#  echo "test5.test3.stats:100 $time" | nc -w1 -u linux 8125
#  echo "test5.test4.stats:100|$time" | nc -w1 -u linux 8125
  echo -n "test6.test1:100|$time" | nc -w1 -u linux 8125
  echo -n "test6.test2:500|$time" | nc -w1 -u linux 8125
  echo -n "test6.test3:1000|$time" | nc -w1 -u linux 8125

#  echo -n "miner.MEMTOTAL:8119|c" | nc -w 1 -u linux 8125
#  echo -n "miner.TEST:100|c" | nc -w 1 -u linux 8125
#  echo -n "gamer.hashrate:$((RANDOM % 100))|c" | nc -w 1 -u 127.0.0.1 8125
#  echo -n "miner.hashrate:$((RANDOM % 200))|c" | nc -w 1 -u 127.0.0.1 8125
  sleep 1
done
