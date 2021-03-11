#!/bin/bash
#

# Wait for miners to deliver files
#sleep 22

set -x

#DIR_TO_FILES="/home/metrics/minermetrics1/worker_files"
DIR_TO_FILES="/home/doc/Applications/minermetrics1/data"
FILE_EXT=".metrics"
WEBFILENAME="dashboard.html"
CSSFILENAME="dashboard.css"
MINERADDR="0xa4df0737ee0345271b41105e2e37a3eae471d772"
MINERS=( "gamer" "linux" "miner" )
PHONENUM=$(cat /etc/phone.number)
PHONEPWD=$(cat /etc/pom.pwd)
PAGERFILE="pager.timer2"
PASSWORD=$(cat /etc/miner.pwd)
OWNEDETH=$(curl -s "https://api.etherscan.io/api?module=account&action=balance&address=$MINERADDR&tag=latest&apikey=$APITOKEN")

#DASHBOARD=$(curl -s https://api.ethermine.org/miner/$MINERADDR/dashboard)
STATS=$(curl -s https://api.ethermine.org/miner/$MINERADDR/currentStats)
CURRENTHASHRATE=$(echo $STATS | jq .data.currentHashrate)
VALIDSHARES=$(echo $STATS | jq .data.validShares)
INVALIDSHARES=$(echo $STATS | jq .data.invalidShares)
ACTIVEWORKERS=$(echo $STATS | jq .data.activeWorkers)
UBALANCE=$(echo $STATS  | jq .data.unpaid)
ETHPRICE=$(curl -s https://api.ethermine.org/poolStats | jq .data.price.usd)
CPM=$(echo $STATS  | jq .data.coinsPerMin)
#CPM=$(bc <<< "scale=8; ${CPM: 0:${#CPM}-4} / 10 ^ ${CPM: -1}")
ETHOWNED=$(curl -s "https://api.etherscan.io/api?module=account&action=balance&address=$MINERADDR&tag=latest&apikey=$APITOKEN" | jq -r .result)
GPUDATA=(NAME BUSID TEMP FAN GPUUTIL MEMUTIL MEMTOTAL MEMFREE MEMUSED POWDRAW POWLIMIT)
FIELDSTOSHOW=( 0 1 2 3 4 5 8 6 )
#MINERSTATS=$(curl -s https://api.ethermine.org/miner/$MINERADDR/worker/$WORKER/currentStats)

function page_msg () {
  # Paging Brian PHONENUM
  if [[ -z $1 ]]; then
    MSG="No Message"
  else
    MSG=$1
  fi
  if ! [ -e $DIR_TO_FILES/$PAGERFILE ]; then
    #echo "File doesn't exist" >> "$LOGFILE"
    touch $DIR_TO_FILES/$PAGERFILE
  else
    #echo "File exists" >> "$LOGFILE"
    #LS=$(ls -la $DIR_TO_FILES/$PAGERFILE)
    #echo "ls $LS" >> "$LOGFILE"
    FILETIME=$(date -d"$(stat -c '%y' $DIR_TO_FILES/$PAGERFILE)" +%s)
    #echo "filetime $FILETIME" >> "$LOGFILE"
    TIMEDIFF=$(($(date +%s)-FILETIME))
    #echo "date $(date +%s)" >> "$LOGFILE"
    if ((TIMEDIFF<600)); then
      return
    else
      touch $DIR_TO_FILES/$PAGERFILE
    fi
  fi
  sendemail -f doc@tavian.com -t $PHONENUM@tmomail.net -u "Miner Alert" -m "$MSG" -s smtp.tavian.com:587 -xu distelli@tavian.com -xp $PHONEPWD -v
  rm $DIR_TO_FILES/$PAGERFILE
}

#nvidia-smi --query-gpu=name,pci.bus_id,temperature.gpu,fan.speed,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used,power.draw,power.limit --format=csv > linux.miner
#Current Eth owned 954856815755150031. Where does the decimal go?

cat  > $DIR_TO_FILES/$WEBFILENAME <<EOF

<html><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8";>
<meta http-equiv="refresh" content="75">
    <link rel="stylesheet" href="dashboard.css">
  </head>
  <body bgcolor="#262428">

    <form name="refreshForm">
      <input type="hidden" name="visited" value="0" />
    </form>

    <div id="header1_div" class="miner_header">
      <p></p>
    </div> 

    <canvas id="logo" width="96" height="68" class="logo_canvas">
Your browser does not support the HTML5 canvas tag.</canvas>

    <div id="tab1" class="tab_style_inactive" onclick="set_tab_t1_active()" style="top:110;">
      <span class="tab_font">gamer</span>
    </div>
    <div id="tab2" class="tab_style_inactive" onclick="set_tab_t2_active()">
      <span class="tab_font">linux</span>
    </div>
    <div id="tab3" class="tab_style_inactive" onclick="set_tab_t3_active()">
      <span class="tab_font">miner</span>
    </div>

    <div id="db1_div" class="full_dashboard">
      <div id="db1_divh" class="miners_header">
        <p></p>
      </div>
      <canvas id="gpu00" width="260" height="160" class="canvas_style">
Your browser does not support the HTML5 canvas tag.</canvas>
    </div>

    <div id="db2_div" class="full_dashboard">
      <div id="db2_divh" class="miners_header">
        <p></p>
      </div>
      <canvas id="gpu10" width="260" height="160" class="canvas_style">
Your browser does not support the HTML5 canvas tag.</canvas>
      <canvas id="gpu11" width="260" height="160" class="canvas_style">
Your browser does not support the HTML5 canvas tag.</canvas>
    </div>

    <div id="db3_div" class="full_dashboard">
      <div id="db3_divh" class="miners_header">
        <p></p>
      </div>
      <canvas id="gpu20" width="260" height="160" class="canvas_style">
Your browser does not support the HTML5 canvas tag.</canvas>
      <canvas id="gpu21" width="260" height="160" class="canvas_style"">
Your browser does not support the HTML5 canvas tag.</canvas>
      <canvas id="gpu22" width="260" height="160" class="canvas_style"">
Your browser does not support the HTML5 canvas tag.</canvas>
      <canvas id="gpu23" width="260" height="160" class="canvas_style">
Your browser does not support the HTML5 canvas tag.</canvas>
      <canvas id="gpu24" width="260" height="160" class="canvas_style"">
Your browser does not support the HTML5 canvas tag.</canvas>
      <canvas id="gpu25" width="260" height="160" class="canvas_style"">
Your browser does not support the HTML5 canvas tag.</canvas>
    </div>

    <script>
      // #262428 widget background and (inactive) tab background
      // #353337 active tab background
      // #19171A top left logo
      //
      // Below is data to be supplied from linux parsing script
      //
      var MINERADDR = "0xa4df0737ee0345271b41105e2e37a3eae471d772";
      var HASHRATE = $CURRENTHASHRATE;
      var ETH = $ETHOWNED;
      var WORKERS = $ACTIVEWORKERS;
      var VALIDSHARES = $VALIDSHARES;
      var INVALIDSHARES = $INVALIDSHARES;
      var UNPAID = $UBALANCE;
      var CPM = $CPM;
      var ETHPRICE = $ETHPRICE;
      var MINERS = [ "gamer", "linux", "miner" ]
EOF

RESPONSE=$(dos2unix -q $DIR_TO_FILES/gamer.metrics)
GPUDATA=(NAME BUSID TEMP FAN GPUUTIL MEMUTIL MEMTOTAL MEMFREE MEMUSED POWDRAW POWLIMIT)
FIELDSTOSHOW=( 0 1 2 3 9 10 )
echo "      var GPUS = [" >> $DIR_TO_FILES/$WEBFILENAME
for miner in ${MINERS[@]}
do
  MINERFILE="$DIR_TO_FILES/$miner.metrics"
  linenum=1
  gpu=0
  while read line;
  do
	  #echo "$linenum $line"
	  if [ "$linenum" -eq "1" ]
	  then
		  NUMGPU=${line:0:1}
		  MINERNAME=${line:1:5}
		  DATADATE=${line:6:28}
		  MINERSTATS=$(curl -s https://api.ethermine.org/miner/$MINERADDR/worker/$MINERNAME/currentStats)
		  MINERCURRENTHASHRATE=$(echo $MINERSTATS | jq .data.currentHashrate)
		  MINERVALIDSHARES=$(echo $MINERSTATS | jq .data.validShares)
		  MINERINVALIDSHARES=$(echo $MINERSTATS | jq .data.invalidShares)
      AMINERGPUS+=("$NUMGPU")
      AMINERHASHRATES+=("$MINERCURRENTHASHRATE")
      AMINERDATE+=("$DATADATE")
      AMINERVALIDSHARES+=("$MINERVALIDSHARES")
      AMINERINVALIDSHARES+=("$MINERINVALIDSHARES")
    elif [ "$linenum" -gt "2" ]
    then
		  #read vars
		  IFS=',' read -r -a gpuvalues <<< "$line"
      a=${gpuvalues[3]}
      gpuvalues[3]=${a:0:3}
      a=${gpuvalues[9]}
      gpuvalues[9]=${a:0:4}
      a=${gpuvalues[10]}
      gpuvalues[10]=${a:0:4}
      echo -n "        [ \"$miner\", " >> $DIR_TO_FILES/$WEBFILENAME
	    for field in ${FIELDSTOSHOW[@]}
	    do
        if [ $field -lt 2 ]
        then
  		    echo -n "\"${gpuvalues[$field]}\", " >> $DIR_TO_FILES/$WEBFILENAME
        else
          echo -n "${gpuvalues[$field]}, " >> $DIR_TO_FILES/$WEBFILENAME
        fi
        #sleep 1
  		done
      echo " ], " >> $DIR_TO_FILES/$WEBFILENAME
		  ((gpu=gpu++))
	  fi
	  ((linenum=linenum+1))
  done < $MINERFILE
done
echo "  ];" >> $DIR_TO_FILES/$WEBFILENAME

cat >> $DIR_TO_FILES/$WEBFILENAME <<EOF
      var MINERGPUS = [ ${AMINERGPUS[0]}, ${AMINERGPUS[1]}, ${AMINERGPUS[2]} ];
      var MINERHASHRATES =[ ${AMINERHASHRATES[0]}, ${AMINERHASHRATES[1]}, ${AMINERHASHRATES[2]} ];
      var MINERDATE = [ "${AMINERDATE[0]}", "${AMINERDATE[1]}", "${AMINERDATE[2]}" ];
      var MINERVALIDSHARES = [ ${AMINERVALIDSHARES[0]} , ${AMINERVALIDSHARES[1]} , ${AMINERVALIDSHARES[2]} ];
      var MINERINVALIDSHARES = [ ${AMINERINVALIDSHARES[0]}, ${AMINERINVALIDSHARES[1]}, ${AMINERINVALIDSHARES[2]} ];
      //
      // End of supplied data
      //

      // Normalize some data
      ETH = (ETH/1000000000000000000).toFixed(8);
      UNPAID = (UNPAID/1000000000000000000).toFixed(6);
      CPM = CPM.toFixed(8);;
      HASHRATE = (HASHRATE/1000000).toFixed(2);

      // Identify divs and canvas
      var t1 = document.getElementById("tab1");
      var t2 = document.getElementById("tab2");
      var t3 = document.getElementById("tab3");
      var d1 = document.getElementById("db1_div");
      var d1h = document.getElementById("db1_divh");
      var d2 = document.getElementById("db2_div");
      var d2h = document.getElementById("db2_divh");
      var d3 = document.getElementById("db3_div");
      var d3h = document.getElementById("db3_divh");
      //var ch = document.getElementById("header1_canvas");
      //var chctx = ch.getContext("2d");
      //var dc1 = document.getElementById("dash1_canvas");
      //var dc1ctx = dc1.getContext("2d");
      //var dc2 = document.getElementById("dash2_canvas");
      //var dc2ctx = dc2.getContext("2d");
      //var dc3 = document.getElementById("dash3_canvas");
      //var dc3ctx = dc3.getContext("2d");
      var cgpu00 = document.getElementById("gpu00");
      var gpu00ctx = cgpu00.getContext("2d");
      gpu00ctx.fillStyle="#262428";
      gpu00ctx.fillRect(0,0,cgpu00.width,cgpu00.height);
      var cgpu10 = document.getElementById("gpu10");
      var gpu10ctx = cgpu10.getContext("2d");
      gpu10ctx.fillStyle="#262428";
      gpu10ctx.fillRect(0,0,cgpu10.width,cgpu10.height);
      var cgpu11 = document.getElementById("gpu11");
      var gpu11ctx = cgpu11.getContext("2d");
      gpu11ctx.fillStyle="#262428";
      gpu11ctx.fillRect(0,0,cgpu11.width,cgpu11.height);
      var cgpu20 = document.getElementById("gpu20");
      var gpu20ctx = cgpu20.getContext("2d");
      gpu20ctx.fillStyle="#262428";
      gpu20ctx.fillRect(0,0,cgpu20.width,cgpu20.height);
      var cgpu21 = document.getElementById("gpu21");
      var gpu21ctx = cgpu21.getContext("2d");
      gpu21ctx.fillStyle="#262428";
      gpu21ctx.fillRect(0,0,cgpu21.width,cgpu21.height);
      var cgpu22 = document.getElementById("gpu22");
      var gpu22ctx = cgpu22.getContext("2d");
      gpu22ctx.fillStyle="#262428";
      gpu22ctx.fillRect(0,0,cgpu22.width,cgpu22.height);
      var cgpu23 = document.getElementById("gpu23");
      var gpu23ctx = cgpu23.getContext("2d");
      gpu23ctx.fillStyle="#262428";
      gpu23ctx.fillRect(0,0,cgpu23.width,cgpu23.height);
      var cgpu24 = document.getElementById("gpu24");
      var gpu24ctx = cgpu24.getContext("2d");
      gpu24ctx.fillStyle="#262428";
      gpu24ctx.fillRect(0,0,cgpu24.width,cgpu24.height);
      var cgpu25 = document.getElementById("gpu25");
      var gpu25ctx = cgpu25.getContext("2d");
      gpu25ctx.fillStyle="#262428";
      gpu25ctx.fillRect(0,0,cgpu25.width,cgpu25.height);

      var pi = Math.PI;

      // dc1ctx.fillStyle="black";
      // dc1ctx.fillRect(0,0,dc1.width,dc1.height);

      window.onload=init();

      function init(){
        var active_tab=document.refreshForm.visited.value;
        if (active_tab == "0") {
          //console.log("zero")
          //set_tab_t1_active();
          active_tab="1";
        }
          draw_logo();

          t1.style.top = "110";
          //t1.onclick = function(){set_tab_t1_active()};
          t2.style.top = "141";
          //t2.onclick = function(){set_tab_t2_active()};
          t3.style.top = "172";           
          //t3.onclick = function(){set_tab_t3_active()};

          write_header();

          write_miner_header(d1h,0);
          write_miner_header(d2h,1);
          write_miner_header(d3h,2);

          do_widget(gpu00ctx, GPUS[0][1], GPUS[0][2], GPUS[0][3], GPUS[0][4], GPUS[0][5], GPUS[0][6]);
          do_widget(gpu10ctx, GPUS[1][1], GPUS[1][2], GPUS[1][3], GPUS[1][4], GPUS[1][5], GPUS[1][6]);
          do_widget(gpu11ctx, GPUS[2][1], GPUS[2][2], GPUS[2][3], GPUS[2][4], GPUS[2][5], GPUS[2][6]);
          do_widget(gpu20ctx, GPUS[3][1], GPUS[3][2], GPUS[3][3], GPUS[3][4], GPUS[3][5], GPUS[3][6]);
          do_widget(gpu21ctx, GPUS[4][1], GPUS[4][2], GPUS[4][3], GPUS[4][4], GPUS[4][5], GPUS[4][6]);
          do_widget(gpu22ctx, GPUS[5][1], GPUS[5][2], GPUS[5][3], GPUS[5][4], GPUS[5][5], GPUS[5][6]);
          do_widget(gpu23ctx, GPUS[6][1], GPUS[6][2], GPUS[6][3], GPUS[6][4], GPUS[6][5], GPUS[6][6]);
          do_widget(gpu24ctx, GPUS[7][1], GPUS[7][2], GPUS[7][3], GPUS[7][4], GPUS[7][5], GPUS[7][6]);
          do_widget(gpu25ctx, GPUS[8][1], GPUS[8][2], GPUS[8][3], GPUS[8][4], GPUS[8][5], GPUS[8][6]);

          //console.log( active_tab );
          switch (active_tab){
            case "1":
              set_tab_t1_active();
              break;
            case "2":
              set_tab_t2_active();
              break;
            case "3":
              set_tab_t3_active();
              break;
          }
      }

      function draw_logo(){
        var clogo = document.getElementById("logo");
        var logoctx = clogo.getContext("2d");
        logoctx.font = "19px Arial";
        logoctx.fillStyle="LightGrey";
        logoctx.strokeStyle="LightGrey";
        logoctx.fillText("McG",48,40);
        logoctx.beginPath();
        logoctx.moveTo(10,20);
        logoctx.lineTo(10,48);
        logoctx.lineTo(38,48);
        logoctx.lineTo(38,20);
        logoctx.lineTo(24,58);
        logoctx.lineTo(10,20);
        logoctx.stroke();
      }

      function do_widget(context, name, busid, temp, fan, poweruse, powermax){
          // document.write(name + busid + "<br>")
          drawHeader(context,name,busid);
          // drawFan(context,x,y,fanspeed)
          drawFan(context,428,272,fan);
          // drawThermoMeter(ctx,bottomleftx,bottomlefty,tempmax,tempmin,temp,roundedcornerpixels,tempwidth);
          drawThermoMeter(context,22,125,84,20,temp,5,20);
          // drawPower(context,x,y,powermax,powermin,poweruse,scale)
          drawPower(context,150,65,powermax,0,poweruse,.35);
      }

      function set_tab_t1_active(){
        //console.log("Set Active Tab 1");
        t1.className = "tab_style_active";
        t2.className = "tab_style_inactive";
        t3.className = "tab_style_inactive";
        d1.style.display = "block";
        d2.style.display = "none";
        d3.style.display = "none";
        document.refreshForm.visited.value = "1";
      }

      function set_tab_t2_active(){
        //console.log("Set Active Tab 2");
        t1.className = "tab_style_inactive";
        t2.className = "tab_style_active";
        t3.className = "tab_style_inactive";
        d1.style.display = "none";
        d2.style.display = "block";
        d3.style.display = "none";
        document.refreshForm.visited.value = "2";
      }

      function set_tab_t3_active(){
        //console.log("Set Active Tab 3");
        t1.className = "tab_style_inactive";
        t2.className = "tab_style_inactive";
        t3.className = "tab_style_active";
        d1.style.display = "none";
        d2.style.display = "none";
        d3.style.display = "block";
        document.refreshForm.visited.value = "3";
      }

      function write_header(){
        htext=document.getElementById("header1_div");
        htext.innerHTML=\`
          <table class="table_font" width="100%">
            <tr>
              <td colspan=2>\${MINERADDR}</td>
              <td align=right>Hash Rate:</td><td>\${HASHRATE}</td>
              <td align=right>ETH:</td><td>\${ETH}</td>
            </tr>
            <tr style="color: Grey;">
              <td align=right width="30%">Workers:</td><td width="20%">\${WORKERS}</td>
              <td align=right width="15%">Valid Shares:</td><td width="10%">\${VALIDSHARES}</td>
              <td align=right width="15%">Invalid Shares:</td><td width="10%">\${INVALIDSHARES}</td>
            </tr>
            <tr style="color: Grey;">
              <td align=right>Unpaid balance:</td><td>\${UNPAID}</td>
              <td align=right>ETH per min:</td><td>\${CPM}</td>
              <td align=right>1 ETH in USD:</td><td>$ \${ETHPRICE}</td>
            </tr>
          </table>
        \`;
      }

      function write_miner_header(div, miner){
        var MINERHASHRATE=(MINERHASHRATES[miner]/1000000).toFixed(2)
        div.innerHTML=\`
          <table class="table_font" width="100%">
            <tr>
              <td colspan=2 width="30%">Miner: \${MINERS[miner]}</td>
              <td align=right width="15%">Hash Rate:</td><td width="10%">\${MINERHASHRATE}</td>
              <td align=right colspan=2 style="font-size: 10pt;" width="25%">Date: \${MINERDATE[miner]}</td>
            </tr>
            <tr style="color: Grey;">
              <td colspan=2></td>
              <td align=right>Valid Shares:</td><td width="10%">\${MINERVALIDSHARES[miner]}</td>
              <td align=right>Invalid Shares:</td><td width="10%">\${MINERINVALIDSHARES[miner]}</td>
            </tr>
          </table>
        \`;        

        //context.font = "16px Arial";
        //context.fillStyle="LightGrey";
        //context.fillText("Miner: " + MINERS[miner],5,18);
        //context.fillText("Hash Rate: " + (MINERHASHRATES[miner]/1000000).toFixed(2),420,18);
        //context.font = "14px Arial";
        //context.fillText("Date: " + MINERDATE[miner],600,18);
        //context.font = "12px Arial";
        //context.fillText("Valid Shares: " + MINERVALIDSHARES[miner],420,50);
        //context.fillText("Invalid Shares: " + MINERINVALIDSHARES[miner],600,50);
      }

      //function write_miner_header(context, miner){
      //  context.font = "16px Arial";
      //  context.fillStyle="LightGrey";
      //  context.fillText("Miner: " + MINERS[miner],5,18);
      //  context.fillText("Hash Rate: " + (MINERHASHRATES[miner]/1000000).toFixed(2),420,18);
      //  context.font = "14px Arial";
      //  context.fillText("Date: " + MINERDATE[miner],600,18);
      //  context.font = "12px Arial";
      //  context.fillText("Valid Shares: " + MINERVALIDSHARES[miner],420,50);
      //  context.fillText("Invalid Shares: " + MINERINVALIDSHARES[miner],600,50);
      //}

  function drawHeader(context,name,busid){
    context.fillStyle="Ivory";
    context.font = "12px Arial";
    context.fillText(name,7,20);
    context.fillText(busid,152,20);
  }

  function drawPower(context,x,y,powermax,powermin,poweruse,scale){
    context.save();
    context.translate(x,y);
    context.save();
    context.scale(scale,scale);
    //pixelshigh=powermax-powermin;
    pixelshigh=151;
    pixelswidth=pixelshigh*.7;
    vline=pixelshigh*.4;
    hline=pixelswidth*.2;
    context.strokeStyle="Grey";
    context.fillStyle="blue";
    context.beginPath();
    context.moveTo(x,y);
    context.lineTo(x-hline,y);
    context.lineTo(x+hline,y-vline*1.5);
    context.lineTo(x+hline,y-vline*.5);
    context.lineTo(x+hline*2,y-vline*.5);
    context.lineTo(x,y+vline);
    context.lineTo(x,y);
    context.fill();
    context.stroke();
    context.restore();
    context.restore();
    context.fillStyle="Ivory";
    context.font = "12px Arial";
    context.fillText(poweruse + ' / ' + powermax + 'w',x+27,y+63);
    context.fillStyle="LightGrey";
    context.font="9px Arial";
    context.fillText('AC power',x+36,y+77);
  }

  function drawThermoMeter(context,x,y,tempmax,tempmin,temp,rc,tempwidth){
    // drawThermoMeter(ctx,bottomleftx,bottomlefty,tempmax,tempmin,temp,roundedcornerpixels,tempwidth);

    context.fillStyle="LightGrey";
    context.strokeStyle="LightGrey";

    // Setup gradient for Thermometer
    var grdtemp = context.createLinearGradient(x,y-tempmax+tempmin-rc,x,y);
    grdtemp.addColorStop(1,"yellow");
    grdtemp.addColorStop(0,"red");
    context.beginPath();
    context.moveTo(x,y);
    context.lineTo(x,y-tempmax+tempmin);
    context.arc(x+rc,y-tempmax+tempmin,rc,pi,pi*1.5);
    context.lineTo(x+rc+tempwidth,y-tempmax+tempmin-rc);
    context.arc(x+rc+tempwidth,y-tempmax+tempmin,rc,pi*1.5,0);
    context.lineTo(x+rc+rc+tempwidth,y);
    context.lineTo(x,y);
    context.stroke();
    context.font = "10px Arial";
    context.beginPath(); // min tick
    context.moveTo(x+rc+rc+tempwidth+rc,y);
    context.lineTo(x+rc+rc+tempwidth+rc+rc,y);
    context.stroke();
    context.beginPath(); // temp tick
    context.moveTo(x+rc+rc+tempwidth+rc,y-temp+tempmin-rc);
    context.lineTo(x+rc+rc+tempwidth+rc+rc,y-temp+tempmin-rc);
    context.stroke();
    context.fillStyle=grdtemp;
    context.fillRect(x + 1, y-temp+tempmin-rc, tempwidth + rc + rc - 2, temp - tempmin + rc);
    context.fillStyle="LightGrey";
    context.fillText(tempmin + "\u00B0",x+rc+rc+tempwidth+rc+rc+rc,y+rc/2);
    context.fillStyle="Ivory"
    context.fillText(temp + "\u00B0",x+rc+rc+tempwidth+rc+rc+rc,y-temp+tempmin-rc+rc/2);
    context.fillStyle="LightGrey"
    context.font="9px Arial";
    context.fillText('Temperature',x-rc-rc,y+rc*3+2);
  }

  // Draw fan blade
  function drawFanBlade(context){
    // called by the drawFan() function
    context.beginPath();
    context.arc(-59,-20,50,1.94*pi,1.6*pi,1);
    context.arc(-7,-18,64,1.3*pi,1.49*pi);
    context.arc(-23,-43,42,1.62*pi,.12*pi);
    context.arc(0,0,31,1.6*pi,1.4*pi,1);
    context.fill();
    context.stroke();
  }

  function drawFan(context,x,y,speed){
    // drawFan(context,x,y,fanspeed)
    var fanScale=.3;
    context.save();
    context.fillStyle="Grey"
    context.strokeStyle="Grey"
    context.scale(fanScale,fanScale);

    for (degrees=0; degrees<360; degrees=degrees+60){
      var rad = degrees * (pi/180);
      context.save();
      context.translate(x,y);
      context.rotate(rad);
      drawFanBlade(context);
      context.restore();
    }

    context.save();
    context.fillStyle="Black";
    context.strokeStyle="Black";
    context.translate(x,y);
    context.beginPath();
    context.arc(0,0,31,0,2*pi);
    context.fill();
    context.stroke();
    context.beginPath();
    context.lineWidth=2;
    context.arc(0,0,91,0,2*pi);
    context.stroke();
    context.restore();
    context.restore();
    context.fillStyle="Ivory";
    context.font = "12px Arial";
    context.fillText(speed + "%",x*fanScale-12,y*fanScale+46);
    context.fillStyle="LightGrey";
    context.font="9px Arial";
    context.fillText('Fan speed',x*fanScale-22,y*fanScale+60);
  }


    </script>
  </body>
</html>
EOF

echo "$(ncftpput -t 20 -r 1 -V -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$CSSFILENAME)"

if [ "$?" == 1 ]
then
  echo "ftp server timeout."
  #Placeholder for text code
  page_msg "ftp server timeout"
  exit
fi

echo "$(ncftpput -t 20 -r 1 -V -u gpumetrics -p $PASSWORD 01f5156.netsolhost.com . $DIR_TO_FILES/$WEBFILENAME)"

set +x
