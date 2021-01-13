#!/bin/bash
#
RESPONSE=$(ps -ax | grep ethdcrminer64)
sudo tail -f /proc/"${RESPONSE:1:4}"/fd/1
