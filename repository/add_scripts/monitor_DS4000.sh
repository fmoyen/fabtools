#!/bin/ksh 

##################################################################
# Monitoring of one DS4000
# Author : F. MOYEN
# October, 3rd 2008
##################################################################

SECOND=$1
COUNT=$2
RUN=$3
RACINE=$4

ControllerA=10.15.4.5
ControllerB=10.15.4.6

RESULT="$RACINE/DS4000/$RUN"

mkdir -p $RESULT > /dev/null 2>&1

/usr/sbin/SMcli $ControllerA $ControllerB -c "set session performanceMonitorInterval=$SECOND performanceMonitorIterations=$COUNT; save storagesubsystem performanceStats file=\"$RESULT/ds4000.txt\";" > $RESULT/ds4000.log 2>$1
