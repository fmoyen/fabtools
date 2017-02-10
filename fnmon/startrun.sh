#!/bin/ksh
trap cleanup 1 2 3 6

#
# NEEDS TO BE ABLE TO DO SUDO IF USER IS NOT ROOT
# CF fabtools/repository/sudo FOR MORE INFORMATIONS
#

#----------------------------------------------------------------------------------------
cleanup ()
{
   echo
   echo "###########################################################"
   echo "STOPPING THE MONITORING"
   echo
   sudo fnmonstop $DIRNAME > /dev/null
   sudo fnmoncheck | grep -v YES
   rm /tmp/fnmoncheck
   exit 1
}

usage ()
{
   echo
   echo "usage: `basename $0` script_to_execute"
   echo
}

#----------------------------------------------------------------------------------------
if [ $# -ne 1 ]
then
  usage
  exit 2
fi


#----------------------------------------------------------------------------------------
SECOND=20
RUNNAME="SGBI"
SCRIPT=$1

#----------------------------------------------------------------------------------------
echo
echo "###########################################################"
echo "STARTING THE MONITORING"
echo
sudo fnmon -s $SECOND -r $RUNNAME +nmonnode -novi > /dev/null 

#----------------------------------------------------------------------------------------
comptrun=`cat /results/fnmon/runid`
nbr=`echo $comptrun | wc -m`
nbr=`expr $nbr - 1`
zero=`expr 4 - $nbr`
chainerun=""
for i in `seq 1 $zero`
do
  chainerun="0$chainerun"
done
chainerun="${chainerun}$comptrun"

sudo fnmoncheck | grep -v YES | tee /tmp/fnmoncheck

DIRNAME=`cat /tmp/fnmoncheck | awk '{print $NF}' | grep RUN_R${chainerun}`

#----------------------------------------------------------------------------------------
echo
echo "###########################################################"
echo "STARTING THE SCRIPT: $SCRIPT"
echo
$SCRIPT
echo

#----------------------------------------------------------------------------------------
cleanup
