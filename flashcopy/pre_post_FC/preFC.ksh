#!/bin/ksh

####################################################################
# Pre flashcopy (preFC)

####################################################################
# Author : Fabrice MOYEN (Benchmark Manager - Montpellier - France)

# Release : V1.0 -  August, 22nd 2007

####################################################################
# To run before doing a flascopy operation (make, resync) on a 
# Volume group.
# It will do a unmount of the FS of the VG and then a varyoffvg. 
#
# parameter : the name of the VG.
####################################################################

#set -x

SCRIPT=$0

function usage
{
   echo
   echo "usage: $SCRIPT volume_group_name"
   echo
}

if [ $# -ne 1 ]
then
  usage
  exit
fi

VG=$1

#------------------------------------------------------------
# UNMOUTING THE FILESYSTEMS 

echo
echo "------------------------------------"
echo Unmounting all the opened filesystems under VG=$VG

lsvg -l $VG | awk 'NR>2' | grep -v "N/A" | grep -v closed > /dev/null
#cat fab | awk 'NR>2' | grep -v "N/A" | grep -v closed > /dev/null
FINI=`echo $?`

while [ $FINI -eq 0 ] 
do
   sleep 1
   MOUNTED_FS=`lsvg -l $VG | awk 'NR>2' | grep -v "N/A" | grep -v closed | cut -c 63-`
   #MOUNTED_FS=`cat fab | awk 'NR>2' | grep -v "N/A" | grep -v closed | cut -c 63-`

   for i in $MOUNTED_FS
   do
     umount $i >/dev/null 2>/dev/null
     echo ".\c"
   done

   lsvg -l $VG | awk 'NR>2' | grep -v "N/A" | grep -v closed > /dev/null
   #cat fab | awk 'NR>2' | grep -v "N/A" | grep -v closed > /dev/null
   FINI=`echo $?`
done

echo
echo everything under VG=$VG is unmounted
echo 
echo "lsvg -l $VG"
lsvg -l $VG

#------------------------------------------------------------
# VARYOFFVG OF $VG

echo
echo "------------------------------------"
echo Varyoffvg of the VG=$VG
varyoffvg $VG
#echo "varyoffvg $VG"

lsvg -o | grep $VG > /dev/null
FINI=`echo $?`

echo
if [ $FINI -ne 0 ]
then
  echo "VG=$VG OFFLINE"
else
  echo "#####################################"
  echo "WARNING - PROBLEM - WARNING - PROBLEM"
  echo "the VG=$VG is not Offline"
  echo "do a manual check"
  echo "WARNING - PROBLEM - WARNING - PROBLEM"
  echo "#####################################"
fi

echo
echo "lsvg -o"
lsvg -o


