mode 76,24
title Gamer local miner
cmdow "Gamer local miner" /MOV 400 0
REM cd c:\Users\doc\Desktop\E-Miner\Claymore
cd c:\Users\doc\Desktop\E-Miner\gminer

REM EthDcrMiner64.exe -ewal a4df0737ee0345271b41105e2e37a3eae471d772 -epsw x -eworker gamer -epool us2.ethermine.org:4444 -allpools 1 -mode 1 -nofee 0 -mport 0

REM ###OLD STUFF BELOW###
REM EthDcrMiner64.exe -ewal a4df0737ee0345271b41105e2e37a3eae471d772 -epsw x -eworker ewok20 -epool us1.ethermine.org:4444 -allpools 1 -mode 1 -colors 0

REM EthDcrMiner64.exe -ewal a4df0737ee0345271b41105e2e37a3eae471d772 -epsw x -eworker ewok20 -epool us1.ethermine.org:4444 -allpools 1 -mode 0 -colors 1 -dwal doct15.ewok12 -dpsw w0rker -dpool stratum+tcp://stratum.decredpool.org:3343

miner.exe --algo ethash --mt 6 --server us2.ethermine.org --port 4444 --user 0x044Eb6E90BFFb22b4b3dBe6B58B61b2b38C08AAc.gamer
