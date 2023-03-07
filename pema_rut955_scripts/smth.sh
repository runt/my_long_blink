#!/bin/bash
# created by jr on 2023-02-15
# latest update on 2023-03-06

# this script adds elaspsed seconds in in1MTH file ( file.mth ) for defined ON state
# format for the file is just one line of text :
# datetime >seconds<  seconds in ON state
# e.g.
# "2023-03-07_14:16:36 649 seconds in ON state"

# you can set the seconds value as starting point for adding next seconds
# this script is called from the IOJuggler service, which shall be configured on web UI
# for the Teltonika router, see the documentation how to set IOJuggler and how to call
# a script when selected event happens


# change here configuration ----------------------------------------------
# ubus path of the input
in1Path="ioman.gpio.din2"     
# what state is considered as ON, can be changes on teltonika web configuration page too
in1ON="1"

# ------------------------------------------------------------------------
# do not change from here ------------------------------------------------
# ------------------------------------------------------------------------
in1Prev="/root/${in1Path}.prevstate"
in1MTH="/root/${in1Path}.mth"
in1File="/root/${in1Path}.log"

# awk programs -----------------------------------------------------------
awk_ON_OFF="/root/awk_parse_ON_OFF"
datetime=`date +%F_%T`
timestamp=`date +%s`

# get state for the selected input using the ubus command
ubusStatus=`ubus -S call ${in1Path} status`

# save the state to the file
echo "${datetime} ${ubusStatus} ${timestamp}" >${in1File}

# parse input state from the log file
currentOut=$(awk -v ONState=${in1ON} -v MTHFile=${in1MTH} -f ${awk_ON_OFF} <${in1File})

# get previous state and timestamp
previousState=$(awk '{ print $2 }' <${in1Prev})
previousTimestamp=$(awk '{print $1}' <${in1Prev})

# check if adding to mth is necessary
# adding is necessary only whe previous state was ON 
# ( ON goes to OFF, ON stays on ON, ON-ON state change should not happen, because in IOJoggler calls this script on every edge change )
if [[ "$previousState" == "ON" ]]
then
  secondsElapsed=$(expr $timestamp - $previousTimestamp)
  previousMTH=$(awk '{ print $2 }' <$in1MTH)
  newMTH=$(expr $previousMTH + $secondsElapsed)
  echo "${datetime} ${newMTH} seconds in ON state" >$in1MTH
fi

# save current state as previous
echo "${timestamp} ${currentOut}" >$in1Prev