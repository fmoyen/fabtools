#!/bin/ksh
#
# Start a trace and generate a report to "hunt" IO demotion
#
# check_demoted.sh v1.1:  s.chabrolles@fr.ibm.com
######################################################################


######################################################################
######################################################################
###   VARIABLES DECLARATION
######################################################################
######################################################################

MAKE_TRACE=1
TIME=2

WRK_DIR=tmp_demoted
TRACE_FILE=${WRK_DIR}/trace.out
TRCRPT_FILE=${WRK_DIR}/trcrpt_cio.out
TRCRPT_TMP=${WRK_DIR}/demot_trcrpt.tmp
TRCRPT_TMP2=${WRK_DIR}/demot_trcrpt2.tmp
CSV_OUT=${WRK_DIR}/demoted.csv
DEMOTED_REPORT="demoted_report."$(uname -n)"."$(date +%m%d%H%M%S)".out"

######################################################################
######################################################################
###   FUNCTION PART
######################################################################
######################################################################

START_TRACE () {
	TIME=$1
	echo
	echo "starting TRACE (for $TIME sec)"
	trace -aj 59B,59C -o $TRACE_FILE
	sleep $TIME
	trcstop && echo "TRACE stopped"
}

START_TRCRPT () {
	TRACE_FILE=$1
	echo
	echo "Analysing trace file : $TRACE_FILE"
	trcrpt -O cpuid=on,tid=on,pid=on,exec=on -o $TRCRPT_FILE $TRACE_FILE
}

clean_up () {
	trcstop
}

usage () {
	echo
	echo
	echo " $0 [ -t trace_file ] [ -T time in seconde ]"
	echo "	-t <trace_file>  \"=> to use a previously generated trace file\""
	echo "	-T <Time in sec> \"=> to sepcify the duration of the trace (default 2 sec.)\""
	echo
}

DEMOTED_REPORT () {

	awk -F";" 'NR > 1 { print $1 }' $CSV_OUT| sort | uniq -c | sort -r > $WRK_DIR/demoted_sortby_exec.out
	awk -F";" 'NR > 1 { print $3 }' $CSV_OUT| sort | uniq -c | sort -r > $WRK_DIR/demoted_sortby_SID.out

	while read NBIO SID ; do
		svmon -jS $SID | awk 'NR==3{ FSINO=$4 ; split($4,FILESYS,":") } ; NR==4 { FILE=$1 } END { print FILESYS[1]":"FILESYS[2]" "FILESYS[1]" "FILE }' | read FSINO FS FILE
		echo "$NBIO $SID $FSINO $FS $FILE"
	done < $WRK_DIR/demoted_sortby_SID.out | sort -r > $WRK_DIR/demoted_sortby_FILE.out
	
	TOTAL_IO=`awk '/IO read/ || /IO write/ { print }' $TRCRPT_FILE | wc -l`
	TOTAL_DEMOTED=`awk -F";" 'NR > 1 { print $1 }' $CSV_OUT | wc -l`
	PERCENT_DEMOTED=`echo "($TOTAL_DEMOTED * 100)  / $TOTAL_IO" | bc`
	echo
	echo "			 Demoted IO Report"
	echo "			===================="
	echo
	awk 'NR<8 { print }' $WRK_DIR/trcrpt_cio.out
	echo
	echo "trace duration : $TIME seconds"
	echo "trace file : $TRACE_FILE"
	echo 
	echo
	echo " 1) Statistics :"
	echo " ==============="
	echo 
	echo " > Total number of IOs : $TOTAL_IO"
	echo " > Total demoted IO : $TOTAL_DEMOTED  (${PERCENT_DEMOTED}%)"
	echo
	echo
	echo " - TOP 5 sort by EXEC :"
	echo
	awk 'NR <= 5{ printf "	%-7s %s",$1,$2"\n" }'  $WRK_DIR/demoted_sortby_exec.out
	echo
	echo
	echo " - TOP 10 sort by FS :"
	echo
	awk '{ print $4 }' $WRK_DIR/demoted_sortby_FILE.out | sort | uniq | while read FILESYS ; do
		awk ' BEGIN {DEMOTED_IO=0} $4==FILESYS { DEMOTED_IO=DEMOTED_IO + $1 } END { print DEMOTED_IO" "FILESYS }' FILESYS=$FILESYS $WRK_DIR/demoted_sortby_FILE.out | read DEMOTED_IO FILESYS 
		lsfs -q $FILESYS | awk 'NR==2 { MOUNT_POINT=$3 } ; NR==3 { split( $0,FSOPT,"\,") ; BLKSIZE=FSOPT[3] } END { print MOUNT_POINT BLKSIZE }' | read MOUNT_POINT BLKSIZE
		echo "$DEMOTED_IO $FILESYS $MOUNT_POINT  ($BLKSIZE)"
	done | sort -r | awk 'NR<=10 { printf "	%-7s %-15s %s	%s%s%s",$1,$2,$3,$4,$5,$6"\n" }'
	echo
	echo
	echo " - TOP 10 sort by FILE"
	echo 
	awk 'NR <=10 { printf "	%-7s %-15s %s",$1,$3,$NF"\n" }' $WRK_DIR/demoted_sortby_FILE.out

	echo
	echo
	echo " 2) Detailled Results :"
	echo " ======================"
	echo
	echo "Nb IO_size " | awk '{ printf (" %-26s %s",$1,$2"\n" )}'
	echo "demot. EXEC TID (Byte) SID FS(:inode) FILE" | awk '{ printf ("%-7s %-12s %-7s %-7s %-10s %-15s %s",$1,$2,$3,$4,$5,$6,$7"\n" )}'
	echo "----------------------------------------------------------------------------------------"
	uniq -c $CSV_OUT | sort -r | awk '$0!~/EXEC/ { split($2,CSVOUT,";") ; print $1" "CSVOUT[1]" "CSVOUT[2]" "CSVOUT[3]" "CSVOUT[4] }' | while read NBIO EXEC TID SID H_LENGTH ; do
		awk '$2==SID { print $3" "$NF }' SID=$SID $WRK_DIR/demoted_sortby_FILE.out | read FS FILE
		LENGTH=`echo "ibase=16 \n$H_LENGTH" | bc`
		echo "$NBIO $EXEC $TID $LENGTH $SID $FS $FILE" | awk '{ printf ("  %-5s %-10s %-10s %-5s %-10s %-15s %s",$1,$2,$3,$4,$5,$6,$7"\n" )}'
	done
}

######################################################################
######################################################################
###   GETOPT
######################################################################
######################################################################

while getopts ":t:T:" opt
do
        case $opt in
                t) TRACE_FILE=${OPTARG}
		MAKE_TRACE=0 ;;

		T) TIME=${OPTARG};;

                \? ) usage
                  return 1
        esac
done

######################################################################
######################################################################
###   MAIN PART
######################################################################
######################################################################

trap clean_up 1 2 3 6

[ ! -d $WRK_DIR ] && mkdir $WRK_DIR

[ $MAKE_TRACE -eq 1 ] && START_TRACE $TIME

START_TRCRPT $TRACE_FILE

echo "Phase 1/3 : Sorting and Writing temporary files"
awk '/demoted/ { gsub("\,","",$14); print $2" "$5" "$14}' $TRCRPT_FILE | sort | uniq > $TRCRPT_TMP

# resetting $TRCRPT_TMP2
> $TRCRPT_TMP2
while read EXEC TID VP ; do
	#awk '(/move/ || /demoted/) && $5~TID && $0~VP { print }' TID=$TID VP=$VP $TRCRPT_FILE >> $TRCRPT_TMP2
	awk '/move/ && $5~TID && $0~VP { DIO_MOVE=$0 } ; /demoted/ && $5~TID && $0~VP { print DIO_MOVE ; print $0 }' TID=$TID VP=$VP $TRCRPT_FILE  >> $TRCRPT_TMP2
done < $TRCRPT_TMP

echo "Phase 2/3 : Writing $CSV_OUT"
echo "EXEC;TID;SID;LENGTH" > $CSV_OUT
awk 'BEGIN{OFS=";"} /move/ { gsub("\,","",$17) ; print $2,$5,$17,$NF }' $TRCRPT_TMP2 >> $CSV_OUT

echo "Phase 3/3 : Building report"
echo

DEMOTED_REPORT > $DEMOTED_REPORT
echo " Report generated : $DEMOTED_REPORT"
echo
##########################

