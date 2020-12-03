#!/bin/bash
#
TESTVAR=asdf
echo "
<table>
  <tr>
    <td>test$TESTVAR</td>
  </tr>
</table>
" > testfile.out

cat > testfile2.out <<EOF
<table>
  <tr>
    <td>test$TESTVAR</td>
  </tr>
</table>
EOF

nvidia-smi  --query-gpu=name,pci.bus_id,temperature.gpu,fan.speed,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used,power.draw,power.limit --format=csv

nvidia-smi  --query-gpu=name,pci.bus_id,temperature.gpu,fan.speed,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used,power.draw,power.limit --format=csv > test.out
