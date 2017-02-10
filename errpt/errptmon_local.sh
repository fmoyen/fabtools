#!/bin/ksh

if [ $# -eq 1 ]
then
  TIME=$1
else
  TIME=10
fi

while true
do
  errpt > /tmp/faberrpt1
  if [ -f /tmp/faberrpt2 ]
  then
    diff /tmp/faberrpt1 /tmp/faberrpt2 > /tmp/fabdiff
#    if [ ! $? -eq 0 ]
    if [ -s /tmp/fabdiff ]
    then
      echo
      echo "########################"
      echo ERRPT MONITORING CONSOLE
      echo "########################"

      hostname
      echo ----------------
      grep "<" /tmp/fabdiff

    fi
  fi
  sleep $TIME
  cp /tmp/faberrpt1 /tmp/faberrpt2
  
done
