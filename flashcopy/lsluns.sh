#!/bin/ksh
#
# Author: Sebastien Chabrolles
###################################################################################
# Variables User

FC_paire_ID_File="/opt/ibm/dscli/backup.id"
FC_timestp_dir="/opt/ibm/dscli"
DSCLI_DIR="/opt/ibm/dscli"

###################################################################################

CONNECT_STORAGE=0
FLASH_COPY=0
NB_LUNS=0

TITLE='NBPath  DSSN    LunID   Size     RAID     Hdisk    VolGroup'
TITLE_LINE='---------------------------------------------------------------'

####################################################################################
# Fonctions

usage () {
	echo 
	echo " Usage :"
	echo "$0 [ -f | -d hdisk ]"
	echo 
 	exit 1
}

lsflash_storage () {
	
	echo "Contacting Storage to retrieve FlashCopy informations ..."
	$DSCLI_DIR/dscli lsflash -l 0000-FFFF | awk 'NR>3 { print $1"	"$12 }' > /tmp/lsflash.out
	echo "Done."

	TITLE="${TITLE}	Active_FC 	OutOfSync"
	TITLE_LINE="${TITLE_LINE}-----------------------------"
}

lsluns_device () {

	DEVICEID=`echo $1 | cut -c6-`
	FC_OLD=""

	echo ""
	echo " $1"
	echo "#########"
	echo
	
	
	pcmpath query essmap | awk '$1==DISK{ RAID=$NF ; DSSN=substr($5,1,7) ; LUNID=substr($5,8,4) ; TYPEDS=$6$7 ; SIZE=$8 } END { print TYPEDS" "SIZE" " DSSN" " LUNID " " RAID }' DISK=$1 | read TYPEDS SIZE DSSN LUNID RAID
	
	VG=`lspv $1 | awk 'NR==1 { print $NF }'`

	echo " AIX:"
	echo "	AIX Volume Group : $VG"
        echo "	File Systemes :"
        lspv -l $1 | awk 'NR>2 { print "\t\t\t"$NF }'
        echo
	echo " Storage:"
	echo "	Storage type : $TYPEDS"
        echo "	Storage S/N  : $DSSN"
        echo 
        echo "	LUN ID : $LUNID"
        echo "	RAID type : $RAID"
        echo "	Lun Size : $SIZE"
	echo
	echo " SAN Connections :" 
	echo
	
	echo "	FC	STATE	FC_WWN			DS_WWN			DS_IOPORT"	
	echo "	---------------------------------------------------------------------------"
	odmget -q "name=$1" CuPath | awk ' $1=="parent" { gsub("\"","",$NF) ; FC=$NF } ; $1~/connection/ { gsub ("\"","",$NF) ; split ($NF,WWN,",") ;  DS_WWN=WWN[1] } ; $1=="path_id" { print FC " path"$NF " " DS_WWN }' | while read FC FCPATH DS_WWN ; do	
		#IOPORTS=`pcmpath query essmap | awk '$1==HDISK && $4==FCcard && $2==FCPATH { print $14 }' HDISK=$1 FCcard=$FC FCPATH=$FCPATH| sort -u | awk -F- '{ gsub("R","",$1) gsub("B","",$2) gsub("H","",$3) gsub("Z","",$4) gsub("A","0",$4) gsub("B","1",$4) gsub("C","2",$4) gsub("D","3",$4); print "I" $1-1 $2-1 $3-1 $4 }'`
		typeset -Z4 IOPORTS=`pcmpath query essmap | awk '$1==HDISK && $4==FCcard && $2==FCPATH { print $15 }' FCcard=$FC FCPATH=$FCPATH HDISK=$1`
		
			FC_WWN=`pcmpath query wwpn | awk '$1==FC { print $NF }' FC=$FC`
		
			STATE=`pcmpath query device $DEVICEID | awk '$2~FC && $2~FCPATH { print $3}' FC=$FC FCPATH=$FCPATH` 	
		
			[ ! "$FC_OLD" = "" ] && [ ! "$FC_OLD" = "$FC" ] && echo
			echo "	$FC	$STATE	$FC_WWN	$DS_WWN	I$IOPORTS"
			FC_OLD=$FC
		done
	exit 0
}

####################################################################################

while getopts "d:fh" opt
do
        case $opt in
		d ) lsluns_device ${OPTARG} ;;
                f ) CONNECT_STORAGE=1 && lsflash_storage ;;
                h ) usage ;;
		\? ) usage
                  return 1
        esac
done

lspv > /tmp/lspv.out

if [ -f $FC_paire_ID_File ] && [ $CONNECT_STORAGE -ne 1 ] ; then
	FLASH_COPY=1
	TITLE="${TITLE}	FC_pairID	FC_BackupDate (MM/DD...)"
	TITLE_LINE="${TITLE_LINE}-----------------------------------------"
fi

echo ""
echo "$TITLE"
echo "$TITLE_LINE"

pcmpath query essmap | awk 'NR>2 { gsub ("\\*"," ") ; DSSN=substr($5,1,7) ; LUNID=substr($5,8,4) ; print  DSSN " " LUNID " " $8 " " $NF " "$1 }' | uniq -c | while read NBPATH DSSN LUNID SIZE RAID HDISK
do
	VG=`/usr/bin/grep -w $HDISK /tmp/lspv.out | /usr/bin/awk '{ print $3 }'`
        #VG2=`grep -w $VG /tmp/mmlsnsd.out | awk '{ print $1 }'`
        
	if [ $FLASH_COPY -eq 1 ] ; then 
		FC=`grep -w $LUNID $FC_paire_ID_File`
		
		
		if [ "$FC" != "" ] ; then
			FC_LUNID=`echo $FC | awk -F\: '{ print $NF }'`
			TMSTP_FILE=`grep -l $FC_LUNID ${FC_timestp_dir}/Timestp_FC* | head -n1`
				if [ "$TMSTP_FILE" != "" ] ; then 
					BKP_DATE=`tail -n1 $TMSTP_FILE | awk -F= '{ print $NF }'`
				else
					BKP_DATE=''
				fi
		else
			BKP_DATE=''
		fi
	fi
		
	[ $CONNECT_STORAGE -eq 1 ] && FC=`grep -w $LUNID /tmp/lsflash.out`
	
	let NB_LUNS+=1
	echo "  $NBPATH   $DSSN   $LUNID   $SIZE   $RAID   $HDISK    $VG 	$FC	$BKP_DATE"
done

echo
echo "Nb Luns : $NB_LUNS"
echo

rm -f /tmp/lspv.out
rm -f /tmp/lsflash.out
exit 0
~
