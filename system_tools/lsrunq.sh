#!/bin/ksh
# Author: Sebastion Chabrolles
myPID=$$
echo
echo "CMD	PID	Uptime	CPU_time	THCNT	in_RunQ" | awk ' { printf ("%-10s %-10s %-15s %-10s %-10s %s",$1,$2,$3,$4,$5,$6"\n") }'
echo "--------------------------------------------------------------------"
ps -emo pid,tid,comm,etime,time,thcount,ppid,state | awk '$1 != "-" && $7 != MYPID { if (NB_THREAD != 0 ) { print PID"\t"NB_THREAD } ; PID=$3"\t"$1"\t"$4"\t"$5"\t"$6 ; NB_THREAD=0 } ; $NF=="R" { NB_THREAD=NB_THREAD + 1 }' MYPID="$myPID" | awk ' { printf ("%-10s %-10s %-15s %-10s %-10s %s",$1,$2,$3,$4,$5,$6"\n") }'
echo 
