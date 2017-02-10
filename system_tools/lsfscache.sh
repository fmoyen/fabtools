#!/bin/ksh

SVMON_OUT=/tmp/svmon.out
FS=""

while getopts ":f:" opt
do
	case $opt in
		f)	FS=${OPTARG} ;;
	esac
done
echo ""
echo "Retreiving Memory informations; Please Wait..." 
svmon -Sc | awk 'NR>2 { gsub ("s","4",$5) ; gsub ("m","64",$5) ; gsub ("L","16384",$5) ; print }' > $SVMON_OUT

ls_file_cache () {
	
	LIST_VSID=/tmp/list_vsid.tmp
	LV=`mount | awk '$2==FILESYSTEM { print $1 }' FILESYSTEM="$FS"`
	echo
	echo "Device: $LV"
	awk '$4~LV { SIZE=$5 * $6 ; split ($4,DEVICENODE,":") ; print SIZE" "$1" "DEVICENODE[2] }' LV=${LV}: /tmp/svmon.out | sort -nr > $LIST_VSID

	cat $LIST_VSID | while read SIZE VSID INODE ; do
		svmon -S $VSID -j | awk 'NR=4{ FILENAME=$1 } ; END{ print SIZE/1024" MB  Inode: "INODE"  "FILENAME } ' SIZE=$SIZE INODE=$INODE
	done
	rm -f $LIST_VSID
	exit 0
}

[ "$FS" != "" ] && ls_file_cache

LISTE_LV=`awk '$6!="0" { split ( $4 , A , ":") ; print A[1] }' $SVMON_OUT | sort -u`

echo "Analyze and sorting Results by FS"

echo ""
for i in $LISTE_LV ; do
	if [ $i == "remote" ] ;then
		FS=REMOTE_FS
	else
        	FS=`mount | grep -w $i | awk '{ print $2 }'`
	fi
        SIZE=`echo "\`grep -w $i $SVMON_OUT | awk  'BEGIN { RESULT=0 } { RESULT=RESULT + $6 * $5 } END { print RESULT }'\` / 1024" | bc`
        echo "$SIZE MB		$FS" 
done | sort -nr 

rm -f $SVMON_OUT
