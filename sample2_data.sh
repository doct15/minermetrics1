#!/bin/sh
#
# About
# -----
# This script sends simple system-metrics to a remote graphite server.
#
#
# Metrics
# -------
# The metrics currently include the obvious things such as:
#
#   * System uptime.
#   * Percentages of disk fullness for all mount-points.
#   * Swap In/Out status.
#   * Process-count and fork-count.
#   * NTP-skew.
#
# The metrics can easily be updated on a per-host basis via the inclusion
# of local scripts.
#
#
# Extensions
# ----------
# Any file matching the pattern /etc/graphite_send.d/*.sh will be executed
# and the output will be used to add additional metrics to be sent.
#
# The shell-scripts will be assumed to output values such as:
#    metric.name1  33
#    metric.name2  value
#
# The hostname and the time-period will be added to the  data before it
# is sent to the graphite host.
#
#
# Usage
# -----
# Configure the host/port of the graphite server in the file
# via /etc/default/graphite_send:
#
#   echo HOST=1.2.3.4 >  /etc/default/graphite_send
#   echo PORT=2004    >> /etc/default/graphite_send
#
# Then merely run `graphite_send`, as root, and the metrics will be sent.
#
# If you wish to see what is being sent run:
#
#    VERBOSE=1 graphite_send
#
#
# License
# -------
# Copyright (c) 2014 by Steve Kemp.  All rights reserved.
#
# This script is free software; you can redistribute it and/or modify it under
# the same terms as Perl itself.
#
# The LICENSE file contains the full text of the license.
#


#
# Setup a sane path
#
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export PATH
export HOST=linux
export PORT=8125
export VERBOSE=1

#
#  If we have a configuration file then load it, if not then abort.
#
#if [ -e /etc/default/graphite_send ]; then
#    .  /etc/default/graphite_send
#else
#    echo "You must configure the remote host:port to send data to"
#    echo "Please try:"
#    echo " "
#    echo "  echo HOST=1.2.3.4 > /etc/default/graphite_send"
#    echo "  echo PORT=2003    >>/etc/default/graphite_send"
#    exit 1
#fi




###
##
## A simple function to send data to a remote host:port address.
##
###
send()
{
    if [ ! -z "$VERBOSE"  ]; then
        echo "Sending : $1"
    fi

    #
    # If we have nc then send the data, otherwise alert the user.
    #
    if ( which nc >/dev/null 2>/dev/null ); then
        #echo $1 | nc $HOST $PORT --send-only -w1 -t1
	echo $1 | nc $HOST $PORT -w1 -u
    else
        echo "nc (netcat) is not present.  Aborting"
    fi

}



###
##
##  Collect metrics, and send them.
##
##  We aim to be generic here, and allow missing files/tools to
## guide us on the metrics to send.
##
##  i.e. We shoudln't assume things are present because this might
## run on Debian, CentOS, etc.
##
####


#
# Get the current hostname
#
host=$(hostname --short)

#
# The current time - we want all metrics to be reported at the
# same time.
#
time=$(date +%s)


##
## Fork-count
##
if [ -e /proc/stat ]; then
    forked=`awk '/processes/ {print $2}' /proc/stat`
    send "$host.process.forked:$forked|$time"
fi


##
## Process-count
##
if ( which ps >/dev/null 2>/dev/null ); then
    pcount=`ps -Al | wc -l`
    send "$host.process.count:$pcount|$time"
fi


##
## The percentage of disk free on each mount-point
##
df --portability 2>/dev/null | grep ^/ |  while read i
do
   name=$(echo $i | awk '{print $1}' | awk -F/ '{print $NF}')
   perc=$(echo $i | awk '{print $5}' | tr -d \% )
   send "$host.mount.$name:$perc|$time"
done


##
## Swap
##
if ( which vmstat >/dev/null 2>/dev/null ); then
    INN=`vmstat -s | grep 'pages swapped in'  | awk '{print $1}'`
    OUT=`vmstat -s | grep 'pages swapped out' | awk '{print $1}'`
    send "$host.swap.in:$INN|$time"
    send "$host.swap.out:$OUT|$time"
fi


##
## Uptime.
##
if [ -e /proc/uptime ]; then
    uptime=$(awk -F\. '{print $1}' < /proc/uptime)
    send "$host.uptime:$uptime|$time"
fi


##
## Load average
##
if [ -e /proc/loadavg ]; then
    avg1=$(awk '{print $1}' < /proc/loadavg)
    send "$host.load:$avg1|$time"
fi


##
## Number of login sessions
##
if ( which w >/dev/null 2>/dev/null ); then
    users=$(w --no-header | wc -l)
    send "$host.users:$users|$time"
fi



##
## For each interface transmit/receive in bytes
##
## This is nasty so we only send data if we're sure about it.
##
for i in $(/sbin/ifconfig  | grep encap. | awk '{print $1}'); do
    rx=$(/sbin/ifconfig $i | grep "RX bytes"  | awk '{print $2}' | awk -F: '{print $2}')
    tx=$(/sbin/ifconfig $i | grep "TX bytes"  | awk '{print $2}' | awk -F: '{print $2}')
    if [ ! -z "$rx" ]; then
        send "$host.net.$i.rx:$rx|$time"
    fi
    if [ ! -z "$tx" ]; then
        send "$host.net.$i.tx:$tx|$time"
    fi
done


##
##  If we have ntpdate installed look for the skew.
##
if ( which ntpdate >/dev/null 2>/dev/null); then

    #
    #  We only run if  (mod($minute, 2) == 0)
    #
    #  This is to avoid being rate-limited by the remote NTP-server(s).
    #
    min=$(date +%M)
    mod=$(expr $min % 2)

    if [ "$mod" = "0" ]; then
        skew=$(ntpdate -q -u pool.ntp.org | grep adjust | awk '{print $(NF-1)}' | tr -d -)
        send "$host.ntp-skew:$skew|$time"
    fi
fi


##
##  If we have dpkg/apt-get then show package counts and pending
## upgrades.
##
if ( which dpkg >/dev/null 2>/dev/null ); then
    packages=$(dpkg --list |grep ^ii | wc -l)
    send "$host.packages.installed:$packages|$time"
fi
if ( which apt-get >/dev/null 2>/dev/null ); then
    pending=$(apt-get upgrade --simulate | grep ^Inst | wc -l )
    send "$host.packages.pending-updates:$pending|$time"
fi



###
##
##  Now we load per-host metrics
##
##
##  For every script matching the pattern /etc/graphite_send.d/*.sh
## we execute them.
##
##  It is assumed the output will be:
##
##      host.metric.name1 233
##      host.metric.name2 233
##      host.metric.name1 233
##
##  We add on "$hostname", and we add on the time-period, then we submit
##
###
for i in /etc/graphite_send.d/*.sh ; do

    if [ -x $i ]; then

        # run the script, capturing the output
        $i |  while read line
        do
            metric=$(echo $line | awk '{print $1}')
            value=$(echo $line | awk '{print $2}')

            send "$host.$metric:$value|$time"
        done

    fi
done

