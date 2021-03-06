#!/bin/ksh

####################################################################
# getinfo Standalone

####################################################################
# Author : Fabrice MOYEN (Benchmark Manager - Montpellier - France)
# Release : V13.01 - Apr 4th, 2013
#   Added "lsmcode -c", "instfix -icq | grep :-:"
#   Added PowerHA configuration part
# Release : V12.01 - Jan 17th, 2012
#   Added VIOS specific commands (ioscli, lsmap)
# Release : V11.03 - May 27th, 2011
#   Added "who -b" to know the boot time info
#   Added errpt information
# Release : V11.02 - May 17th, 2011
#   Added AIX 5.3 support for collecting tunables
# Release : V11.01 - March 16th, 2011
#   added lsattr -El for ent and en devices
# Release : V10.03 - August 4th, 2010
#   added "instfix -i | egrep 'ML|SP'"
#   added "df -gP"
# Release : V10.02 - July 8th, 2010
#   added lsattr -El and lscfg -vpl for fscsi$i, vscsi$i and hdisk$i
# Release : V10.01 - February 17th, 2010
#   added the -F option for vmo, schedo, ioo, nfso, etc
# Release : V9.06 - December 16th, 2009
#   added instfix -i and emgr -l
# Release : V9.05 - November 26th, 2009
#   added svmon -G (to see large pages usage for example)
# Release : V9.04 - November 10th, 2009
#   added lspath
# Release : V9.03 - August 25th, 2009
#   added schedo -L
#   added schedo -a, vmo -a, no -a, ioo -a, nfso -a
# Release : V9.02 - June 15th, 2009
#   added lsattr -El fcs*
#   added lsattr -El fscsi*
# Release : V9.01 - June 4th, 2009
#   added netstat -rn
# Release : V1.21 - October 16th, 2008
#   added vmstat -v
# Release : V1.20 - October 5th, 2008
#   added manage_disk_drivers
# Release : V1.18 - October 1st, 2008
#   added lsslot -c slot, lsslot -c pci, fget_config -Av, mpio_get_config -A
# Release : V1.17 - September 8th, 2008
#   added lsluns
# Release : V1.16 - September 4th, 2008
#   added entstat -d ent*
#   added fcstat fcs*
# Release : V1.15 - April 9th, 2008
#   added instfix -i | grep SP
# Release : V1.14 - February 26th, 2008
#   added pcmpath query adapter / device and essmap
#   changed no/vmo/nfso/ioo -a by no/vmo/nfso/ioo -L
# Release : V1.13 - November 20th, 2007
#   added /etc/security/limits, lslv and lslv -l of all LV
# Release : V1.12 - October 5th, 2007
#   added the possibility to give the result directory in parameter
# Release : V1.11 - October 5th, 2007
#   Added the lsvg, lsvg -l and lsvg -p. 
#   Added the lspv.
#   Added the ls -la /dev
# Release : V1.10 - April 6th, 2007
#   change the name of the function "doit" into "todo"
#       (another tool is called" doit")
#   Added the exportfs command and the /etc/exports file
#   Added the echo of the command on screen
#   Added the totality of lastboot file
#   Added all the crontab files.
# Release : V1.9 - March 22nd, 2007
#   Add the etherchannel adapters status
# Release : V1.8 - March 20th, 2007
#   change "mkdir" to "mkdir -p"
# Release : V1.7

####################################################################
# Get all the informations needed on a system for a report.

####################################################################

#-----------------------------------------------------------
# Load the fabtools.conf file

#if [ -f $PWD/fabtools.conf ]
#then
   #REP_SCRIPT=$PWD
#else
   #REP_SCRIPT=$0
   #NB_CHAR=`echo $REP_SCRIPT | wc -c`
   #NB_CHAR=`expr $NB_CHAR - 8`
   #REP_SCRIPT=`echo $REP_SCRIPT | cut -c -$NB_CHAR`
#fi

#. $REP_SCRIPT/fabtools.conf


#-----------------------------------------------------------
# USAGE

function usage
{
   echo
   echo "usage : $0 [ result directory ]"
   echo
   echo "        just run it. You'll find the result file into $REP_RESULT"
   echo "          or"
   echo "        Give the directory and you'll fint the result file into it"
   echo 
   echo "        -h To display this help !"
   echo
   exit 1

}

#-----------------------------------------------------------
# VARIABLES

REP_RESULT=./getinfo

case $# in
   0)
   REP_RESULT=./getinfo
   ;;

   1)
   if [ $1 == "-h" ]
   then
      usage
   else
      REP_RESULT=$1
   fi
   ;;

   *)
   usage
   ;;

esac

FILE_RESULT="$REP_RESULT/`hostname`_`date +%d%b%y_%H%M%S`.txt"

TEMPO_CRON=/tmp/get_all_the_crontabs
TEMPO_LSVG=/tmp/get_all_the_VG_info
TEMPO_ENT=/tmp/get_all_the_ent_info
TEMPO_FCS=/tmp/get_all_the_fcs_info
TEMPO_FSCSI=/tmp/get_all_the_fscsi_info
TEMPO_VSCSI=/tmp/get_all_the_vscsi_info
TEMPO_HDISK=/tmp/get_all_the_hdisk_info
TEMPO_POWERHA=/tmp/get_powerha_info

#-----------------------------------------------------------
function todo 
{
echo -------------------------------------- >> $FILE_RESULT
echo $* >> $FILE_RESULT
echo $*
echo -------------------------------------- >> $FILE_RESULT
eval $* >> $FILE_RESULT 2>> $FILE_RESULT
echo >> $FILE_RESULT
}

#-----------------------------------------------------------
# Create the result directory
echo
echo Creation of the directory $REP_RESULT if needed
mkdir -p $REP_RESULT 2>/dev/null

echo Creation of the file $FILE_RESULT
touch $FILE_RESULT
echo

#-----------------------------------------------------------
# START COLLECTING THE INFORMATION

AIXLEVEL=`oslevel -s | cut -c 1-2`

echo START COLLECTING THE INFORMATIONS FOR `hostname`
echo

#-----------------------------------------------------------
# START OF FILE
echo -------------------------------------- >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo >> $FILE_RESULT
echo START OF FILE - START OF FILE - START OF FILE >> $FILE_RESULT
echo >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo >> $FILE_RESULT
echo >> $FILE_RESULT

echo "for i in \`lsdev -Ccadapter | grep fcs | awk '{print \$1}'\`" > $TEMPO_FCS
echo "do" >> $TEMPO_FCS
echo "echo" >> $TEMPO_FCS
echo "echo - - - - - - - - - - - -" >> $TEMPO_FCS
echo "echo fcstat \$i" >> $TEMPO_FCS
echo "echo - - - - - - - - - - - -" >> $TEMPO_FCS
echo "echo" >> $TEMPO_FCS
echo "fcstat \$i"  >> $TEMPO_FCS
echo "echo" >> $TEMPO_FCS
echo "echo - - - - - - - - - - - -" >> $TEMPO_FCS
echo "echo lsattr -El \$i" >> $TEMPO_FCS
echo "echo - - - - - - - - - - - -" >> $TEMPO_FCS
echo "echo" >> $TEMPO_FCS
echo "lsattr -El \$i"  >> $TEMPO_FCS
echo "done" >> $TEMPO_FCS
chmod 755 $TEMPO_FCS
todo "$TEMPO_FCS"
rm $TEMPO_FCS

echo "for i in \`lsdev | grep fscsi | awk '{print \$1}'\`" > $TEMPO_FSCSI
echo "do" >> $TEMPO_FSCSI
echo "echo" >> $TEMPO_FSCSI
echo "echo - - - - - - - - - - - -" >> $TEMPO_FSCSI
echo "echo lsattr -El \$i" >> $TEMPO_FSCSI
echo "echo - - - - - - - - - - - -" >> $TEMPO_FSCSI
echo "echo" >> $TEMPO_FSCSI
echo "lsattr -El \$i"  >> $TEMPO_FSCSI
echo "echo" >> $TEMPO_FSCSI
echo "echo - - - - - - - - - - - -" >> $TEMPO_FSCSI
echo "echo lscfg -vpl \$i" >> $TEMPO_FSCSI
echo "echo - - - - - - - - - - - -" >> $TEMPO_FSCSI
echo "echo" >> $TEMPO_FSCSI
echo "lscfg -vpl \$i"  >> $TEMPO_FSCSI

echo "done" >> $TEMPO_FSCSI
chmod 755 $TEMPO_FSCSI
todo "$TEMPO_FSCSI"
rm $TEMPO_FSCSI

echo "for i in \`lsdev | grep vscsi | awk '{print \$1}'\`" > $TEMPO_VSCSI
echo "do" >> $TEMPO_VSCSI
echo "echo" >> $TEMPO_VSCSI
echo "echo - - - - - - - - - - - -" >> $TEMPO_VSCSI
echo "echo lsattr -El \$i" >> $TEMPO_VSCSI
echo "echo - - - - - - - - - - - -" >> $TEMPO_VSCSI
echo "echo" >> $TEMPO_VSCSI
echo "lsattr -El \$i"  >> $TEMPO_VSCSI
echo "echo" >> $TEMPO_VSCSI
echo "echo - - - - - - - - - - - -" >> $TEMPO_VSCSI
echo "echo lscfg -vpl \$i" >> $TEMPO_VSCSI
echo "echo - - - - - - - - - - - -" >> $TEMPO_VSCSI
echo "echo" >> $TEMPO_VSCSI
echo "lscfg -vpl \$i"  >> $TEMPO_VSCSI

echo "done" >> $TEMPO_VSCSI
chmod 755 $TEMPO_VSCSI
todo "$TEMPO_VSCSI"
rm $TEMPO_VSCSI

echo "for i in \`lspv | awk '{print \$1}'\`" > $TEMPO_HDISK
echo "do" >> $TEMPO_HDISK
echo "echo" >> $TEMPO_HDISK
echo "echo - - - - - - - - - - - -" >> $TEMPO_HDISK
echo "echo lsattr -El \$i" >> $TEMPO_HDISK
echo "echo - - - - - - - - - - - -" >> $TEMPO_HDISK
echo "echo" >> $TEMPO_HDISK
echo "lsattr -El \$i"  >> $TEMPO_HDISK
echo "echo" >> $TEMPO_HDISK
echo "echo - - - - - - - - - - - -" >> $TEMPO_HDISK
echo "echo lscfg  -vpl \$i" >> $TEMPO_HDISK
echo "echo - - - - - - - - - - - -" >> $TEMPO_HDISK
echo "echo" >> $TEMPO_HDISK
echo "lscfg -vpl \$i"  >> $TEMPO_HDISK

echo "done" >> $TEMPO_HDISK
chmod 755 $TEMPO_HDISK
todo "$TEMPO_HDISK"
rm $TEMPO_HDISK

todo "uname -a"
todo "who -b"
todo "lsattr -El sys0"
todo "prtconf"
todo "lsmcode -c"
todo "oslevel -s"
todo "instfix -i | egrep 'ML|SP'"
todo "instfix -i | grep ML"
todo "instfix -i | grep SP"
todo "instfix -icq | grep :-:"
todo "instfix -i"
todo "emgr -l"
todo "lparstat -i"
todo "lsdev -C | grep -i processor | grep -i available | wc -l"
todo "lsattr -El mem0"
todo "vmstat -v"
todo "svmon -G"
todo "lsdev -C -S a"
todo "lsslot -c slot"
todo "lsslot -c pci"
todo "lsdev -Cc adapter -s pseudo -t ibm_ech"
todo "ls -la /dev"
todo "lsps -a"
todo "ulimit -a"
todo "cat /etc/security/limits"

if [ $AIXLEVEL != "53" ]
then
   todo "schedo -FL"
   todo "vmo -FL"
   todo "no -FL"
   todo "ioo -FL"
   todo "nfso -FL"
   todo "schedo -Fa"
   todo "vmo -Fa"
   todo "no -Fa"
   todo "ioo -Fa"
   todo "nfso -Fa"
else
   todo "schedo -L"
   todo "vmo -L"
   todo "no -L"
   todo "ioo -L"
   todo "nfso -L"
   todo "schedo -a"
   todo "vmo -a"
   todo "no -a"
   todo "ioo -a"
   todo "nfso -a"
fi

todo "ifconfig -a"
todo "netstat -rn"
todo "netstat -i"

echo "for i in \`netstat -i | awk '{print \$1}' | grep en | sort -u\`" > $TEMPO_ENT
echo "do" >> $TEMPO_ENT
echo "echo" >> $TEMPO_ENT
echo "echo - - - - - - - - - - - -" >> $TEMPO_ENT
echo "echo entstat -d \$i" >> $TEMPO_ENT
echo "echo - - - - - - - - - - - -" >> $TEMPO_ENT
echo "echo" >> $TEMPO_ENT
echo "entstat -d \$i"  >> $TEMPO_ENT
echo "done" >> $TEMPO_ENT
chmod 755 $TEMPO_ENT
todo "$TEMPO_ENT"
rm $TEMPO_ENT

echo "for i in \`lsdev -Ccadapter | grep ent | awk '{print \$1}'\`" > $TEMPO_ENT
echo "do" >> $TEMPO_ENT
echo "ENadapt=\`echo \$i | cut -c 1-2,4-\`" >> $TEMPO_ENT
echo "echo" >> $TEMPO_ENT
echo "echo - - - - - - - - - - - -" >> $TEMPO_ENT
echo "echo lsattr -El \$i" >> $TEMPO_ENT
echo "echo - - - - - - - - - - - -" >> $TEMPO_ENT
echo "echo" >> $TEMPO_ENT
echo "lsattr -El \$i"  >> $TEMPO_ENT
echo "echo" >> $TEMPO_ENT
echo "echo - - - - - - - - - - - -" >> $TEMPO_ENT
echo "echo lsattr -El \$ENadapt" >> $TEMPO_ENT
echo "echo - - - - - - - - - - - -" >> $TEMPO_ENT
echo "echo" >> $TEMPO_ENT
echo "lsattr -El \$ENadapt"  >> $TEMPO_ENT
echo "echo" >> $TEMPO_ENT

echo "done" >> $TEMPO_ENT
chmod 755 $TEMPO_ENT
todo "$TEMPO_ENT"
rm $TEMPO_ENT

todo "lspv"
todo "$REP_SCRIPT/lsluns"
todo "pcmpath query adapter"
todo "pcmpath query device"
todo "pcmpath query essmap"
todo "lspath"
todo "lsvg -o"
todo "manage_disk_drivers"
todo "fget_config -Av"
todo "mpio_get_config -A"

echo "for i in \`lsvg -o\`" > $TEMPO_LSVG
echo "do" >> $TEMPO_LSVG
echo "echo" >> $TEMPO_LSVG
echo "echo - - - - - - - - - - - -" >> $TEMPO_LSVG
echo "echo \$i" >> $TEMPO_LSVG
echo "echo - - - - - - - - - - - -" >> $TEMPO_LSVG
echo "echo" >> $TEMPO_LSVG
echo "echo lsvg" >> $TEMPO_LSVG
echo "lsvg \$i" >> $TEMPO_LSVG
echo "echo" >> $TEMPO_LSVG
echo "echo lsvg -l" >> $TEMPO_LSVG
echo "lsvg -l \$i" >> $TEMPO_LSVG
echo "echo" >> $TEMPO_LSVG
echo "echo lsvg -p" >> $TEMPO_LSVG
echo "lsvg -p \$i" >> $TEMPO_LSVG
echo "for j in \`lsvg -l \$i |  awk 'NR>2 {print \$1}' \`" >> $TEMPO_LSVG
echo "do" >> $TEMPO_LSVG
echo "echo" >> $TEMPO_LSVG
echo "echo lslv \$j" >> $TEMPO_LSVG
echo "lslv \$j" >> $TEMPO_LSVG
echo "echo" >> $TEMPO_LSVG
echo "echo lslv -l \$j" >> $TEMPO_LSVG
echo "lslv -l \$j" >> $TEMPO_LSVG
echo "echo" >> $TEMPO_LSVG
echo "done" >> $TEMPO_LSVG
echo "done" >> $TEMPO_LSVG
chmod 755 $TEMPO_LSVG
todo "$TEMPO_LSVG"
rm $TEMPO_LSVG

todo "df -kP"
todo "df -gP"
todo "mount"
todo "lsfs -q"
todo "cat /etc/filesystems"
todo "cat /etc/resolv.conf"
todo "cat /etc/netsvc.conf"
todo "cat /etc/exports"
todo "exportfs"
todo "lslpp -l"
todo "lssrc -a"
todo "ps -ef"
todo "cat /etc/inittab"
todo "cat /etc/hosts"
todo "cat /etc/tunables/lastboot"
todo "ls /usr/spool/cron/crontabs"

echo "for i in \`ls /usr/spool/cron/crontabs\`" > $TEMPO_CRON
echo "do" >> $TEMPO_CRON
echo "echo" >> $TEMPO_CRON
echo "echo - - - - - - - - - - - -" >> $TEMPO_CRON
echo "echo \$i" >> $TEMPO_CRON
echo "echo - - - - - - - - - - - -" >> $TEMPO_CRON
echo "cat /usr/spool/cron/crontabs/\$i" >> $TEMPO_CRON
echo "done" >> $TEMPO_CRON
chmod 755 $TEMPO_CRON
todo "$TEMPO_CRON"
rm $TEMPO_CRON

todo "errpt"
todo "errpt -a"

# Specific for VIO server
echo >> $FILE_RESULT
echo >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo >> $FILE_RESULT
echo "SPECIFIC FOR VIRTUAL IO SERVER (VIOS)" >> $FILE_RESULT
echo >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo >> $FILE_RESULT
echo >> $FILE_RESULT


todo "/usr/ios/cli/ioscli ioslevel"
todo "/usr/ios/cli/ioscli lsmap -all"
todo "/usr/ios/cli/ioscli lsmap -all -npiv"
todo "/usr/ios/cli/ioscli lsmap -all -net"

# Specific for PowerHA cluster node
echo >> $FILE_RESULT
echo >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo >> $FILE_RESULT
echo "SPECIFIC FOR POWERHA CLUSTER NODE" >> $FILE_RESULT
echo >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo >> $FILE_RESULT
echo >> $FILE_RESULT

todo "/usr/es/sbin/cluster/utilities/cllsclstr"
todo "/usr/es/sbin/cluster/utilities/cldump"
todo "cat /etc/snmpdv3.conf"
todo "/usr/es/sbin/cluster/utilities/clRGinfo -v -p -t"
todo "/usr/es/sbin/cluster/utilities/clmgr -v show rg"
todo "/usr/es/sbin/cluster/utilities/cllsfs -s"
todo "/usr/es/sbin/cluster/utilities/cllsif"
todo "/usr/es/sbin/cluster/utilities/cllspers"
todo "/usr/es/sbin/cluster/utilities/cllssvcs"
todo "/usr/es/sbin/cluster/utilities/cllsnode"
todo "/usr/es/sbin/cluster/utilities/cllsserv"

echo "for i in \`/usr/es/sbin/cluster/utilities/cllsserv | awk '{print \$2 \" \" \$3}'\`" > $TEMPO_POWERHA
echo "do" >> $TEMPO_POWERHA
echo "echo" >> $TEMPO_POWERHA
echo "echo - - - - - - - - - - - -" >> $TEMPO_POWERHA
echo "echo cat \$i" >> $TEMPO_POWERHA
echo "echo - - - - - - - - - - - -" >> $TEMPO_POWERHA
echo "echo" >> $TEMPO_POWERHA
echo "cat \$i"  >> $TEMPO_POWERHA
echo "done" >> $TEMPO_POWERHA
chmod 755 $TEMPO_POWERHA
todo "$TEMPO_POWERHA"
rm $TEMPO_POWERHA

todo "/usr/es/sbin/cluster/utilities/cllsappmon"

echo "for i in \`/usr/es/sbin/cluster/utilities/cllsappmon | awk '{print \$1}'\`" > $TEMPO_POWERHA
echo "do" >> $TEMPO_POWERHA
echo "echo" >> $TEMPO_POWERHA
echo "echo - - - - - - - - - - - -" >> $TEMPO_POWERHA
echo "echo cllsappmon \$i" >> $TEMPO_POWERHA
echo "echo - - - - - - - - - - - -" >> $TEMPO_POWERHA
echo "echo" >> $TEMPO_POWERHA
echo "/usr/es/sbin/cluster/utilities/cllsappmon \$i"  >> $TEMPO_POWERHA
echo "for j in \`/usr/es/sbin/cluster/utilities/cllsappmon \$i | awk '{print \$3 \" \" \$11 \" \" \$12}'\`" >> $TEMPO_POWERHA
echo "do" >> $TEMPO_POWERHA
echo "echo" >> $TEMPO_POWERHA
echo "echo - - - - - - - - - - - -" >> $TEMPO_POWERHA
echo "echo cat \$j" >> $TEMPO_POWERHA
echo "echo - - - - - - - - - - - -" >> $TEMPO_POWERHA
echo "echo" >> $TEMPO_POWERHA
echo "cat \$j"  >> $TEMPO_POWERHA
echo "done" >> $TEMPO_POWERHA
echo "done" >> $TEMPO_POWERHA
chmod 755 $TEMPO_POWERHA
todo "$TEMPO_POWERHA"
#rm $TEMPO_POWERHA

todo "/usr/es/sbin/cluster/utilities/cllsres"
todo "/usr/es/sbin/cluster/utilities/clrgorder"
todo "/usr/es/sbin/cluster/utilities/clrgdependency -t PARENT_CHILD -sp"
todo "/usr/es/sbin/cluster/utilities/clrgdependency -t START_AFTER -sp"
todo "/usr/es/sbin/cluster/utilities/clrgdependency -t STOP_AFTER -sp"

#-----------------------------------------------------------
# END OF FILE
echo >> $FILE_RESULT
echo >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo >> $FILE_RESULT
echo END OF FILE - END OF FILE - END OF FILE >> $FILE_RESULT
echo >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT
echo -------------------------------------- >> $FILE_RESULT


#-----------------------------------------------------------
# Reminder of the directory name

echo --------------------------------------
echo "Remind you the RESULT directory/file name"
echo $FILE_RESULT
echo
