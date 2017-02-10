#!/bin/ksh

####################################################################
# mkDG.sh

####################################################################
# Author : Fabrice MOYEN (Benchmark Manager - Montpellier - France)
# Date : March, 13th 2009
# Release : V9.01

####################################################################
# Create a diskgroup file then to use with the -g nmon option
#

####################################################################

#-----------------------------------------------------------
# Load the fabtools.conf file

if [ -f $PWD/fabtools.conf ]
then
   REP_SCRIPT=$PWD
else
   REP_SCRIPT=$0
   NB_CHAR=`echo $REP_SCRIPT | wc -c`
   NB_CHAR=`expr $NB_CHAR - 6`
   REP_SCRIPT=`echo $REP_SCRIPT | cut -c -$NB_CHAR`
fi

. $REP_SCRIPT/fabtools.conf


#-----------------------------------------------------------
# Variables

FILEDIR="$REP_TOOLS/diskgroup"
FILE="$FILEDIR/DG_`uname -n`.txt"
TMPDIR="$FILEDIR/fabtmp_`uname -n`"
LINK="/etc/diskgroup.txt"

mkdir -p $FILEDIR
> $FILE
mkdir -p $TMPDIR

#-----------------------------------------------------------
# MAIN

for i in  `lspv | awk '{print $1 ":" $3}'`
do
  DISK=`echo $i | awk -F: '{print $1}'`
  VG=`echo $i | awk -F: '{print $2}'`

  if [ $VG != "None" ]
  then
    if [ ! -f $TMPDIR/$VG ]
    then
      > $TMPDIR/$VG
    fi

    echo "$DISK \c" >> $TMPDIR/$VG
  fi

done

cd $TMPDIR
for i in `ls $TMPDIR`
do
  echo "$i \c" >> $FILE
  cat $i >> $FILE
  echo >> $FILE
done

cd 
rm -r $TMPDIR

echo
echo "$FILE -> "
echo
cat $FILE
echo

ln -sf $FILE $LINK
echo "A symbolic link has been created onto / directory:"
ls -lad $LINK
echo
