mode 136,24
title Miner miner
cmdow "Miner miner" /MOV 400 753
wsl -u doc /bin/bash -c 'cd /home/doc;ssh doc@miner "/home/doc/Applications/minermetrics1/logminer.sh"'

REM ###OLD VERS###
REM wsl -u doc /bin/bash -c 'cd /home/doc;ssh doc@miner "/home/doc/Applications/minermetrics1/logminer.sh";echo "";$SHELL'