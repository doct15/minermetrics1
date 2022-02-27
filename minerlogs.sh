#!/bin/bash
#
RESPONSE=$(ps -ax | grep "\.\/miner")
sudo tail -f /proc/"${RESPONSE:1:4}"/fd/1
