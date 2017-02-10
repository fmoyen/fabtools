#!/bin/ksh
#set -x

####################################################################
#  Flashcopy Information

####################################################################
# Author : Sebastien CHABROLLES (Benchmark Manager - Montpellier - France)
# Modification : Fabrice MOYEN (Benchmark Manager - Montpellier - France)

# Release : V1.0 -  March, 27st 2007

####################################################################
# Give information about the flashcopy operation in progress 
# the time to end, the bandwidth, etc.

####################################################################

SEQNUM=$1

if [ $# -ne 1 ]
then 
  echo 
  echo "usage : $0 <SeqNum>"
  echo
  exit 1
fi

LSFLASH_TMP_FILE=/tmp/lsflash.out
TRACK_REMAINING=0

while :
do
	echo ""
	/opt/ibm/dscli/dscli lsflash -l 0000-FFFF > $LSFLASH_TMP_FILE 
	date
	echo "FC_pair 	OutOfSync"
	echo "--------------------------"
	awk '$3==SEQNUM && NR>3 { print $1"	"$12 }' SEQNUM=$SEQNUM $LSFLASH_TMP_FILE | grep -v "	0"
	CODRET=$?
	if [ $CODRET -ne 0 ]
	then
		echo ""
		echo "FlashCopy Copy Finished"
		rm -f $LSFLASH_TMP_FILE
		exit 0
	else
		TRACK_REMAINING_OLD=$TRACK_REMAINING
		TRACK_REMAINING=`awk '$3==SEQNUM && NR>3 { TRACK_REMAINING=TRACK_REMAINING + $12 } ; END { print TRACK_REMAINING } ' SEQNUM=$SEQNUM $LSFLASH_TMP_FILE` 
		SIZE_REMAINING=`echo "$TRACK_REMAINING / 16384" | bc`	
	
		echo "--"
		echo "Out Of Sync : $SIZE_REMAINING GB"

		if [ $TRACK_REMAINING_OLD -ne 0 ] ; then
			TRACK_DELTA=`expr $TRACK_REMAINING_OLD - $TRACK_REMAINING`
			SPEED=`echo "scale = 2; ( $TRACK_DELTA / 16 ) / 60" | bc`
			TIME_REMAINING=`echo "scale = 1 ; $TRACK_REMAINING / $TRACK_DELTA" | bc`
			echo "--"
			echo "Estimated Speed : ${SPEED} MB/s"
			echo "Estimated Time Remaining : $TIME_REMAINING min"	
		fi
		sleep 60
	fi
done
