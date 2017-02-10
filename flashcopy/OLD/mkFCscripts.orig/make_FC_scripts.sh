#!/bin/ksh

####################################################################
# Make FlashCopy Scripts

####################################################################
# Author : Fabrice MOYEN (Benchmark Manager - Montpellier - France)
#
# Release : V1.1 - September, 4th 2008
#  - industrialization of the tools
# Release : V1.0 - August, 17th 2007
#    -> First development
#

####################################################################
#
# script used to generate all the Flashcopy needed
# (make, resync, rmflash, etc.). 
#
# Need some txt configuration files with the LunID definition.
#
####################################################################

#-----------------------------------------------------------
# Load the fabtools.conf file
# for the moment, not planned to be in the bin directory
# so the path is hard-defined.

   REP_SCRIPT=$PWD/../../conf

. $REP_SCRIPT/fabtools.conf


#-----------------------------------------------------------
# Analyse the parameters of the scripts

if [ $# -ne 2 ]
then
  echo
  echo "usage : $0 <source> <destination>"
  echo EXITING
  exit 1
fi

END="_LUNID.txt"
DIR_WIN=/$REP_TOOLS/FCscripts/scripts_windows
DIR_AIX=/$REP_TOOLS/FCscripts/scripts_aix

mkdir -p $DIR_WIN 2>/dev/null
mkdir -p $DIR_AIX 2>/dev/null

##############################################
make_script() {
> $DIR_AIX/$FILE.sh

INC=0

#while read C A
while read A
do
   echo "$CMD \c" >> $DIR_AIX/$FILE.sh
   let INC+=1
   B=`awk 'NR==LIGNE { print $1 } ' LIGNE=$INC $DEST_FILE`
   echo "$A:$B" >> $DIR_AIX/$FILE.sh
done < $SOURCE_FILE

sed "s/dscli //" $DIR_AIX/$FILE.sh > $DIR_WIN/tempo.scr
sed "s/$//" $DIR_WIN/tempo.scr > $DIR_WIN/$FILE.scr
rm $DIR_WIN/tempo.scr
}


##############################################

SOURCE=$1
DEST=$2

SOURCE_FILE=${SOURCE}$END 
DEST_FILE=${DEST}$END 

##############################################
# mkflash -record -persist 

CMD="dscli mkflash -record -persist"
FILE=FC_mk_perm_${SOURCE}to${DEST}
make_script

##############################################
# mkflash  

CMD="dscli mkflash"
FILE=FC_make_${SOURCE}to${DEST}
make_script

##############################################
# rmflash -quiet

CMD="dscli rmflash -quiet"
FILE=FC_rmflash_${SOURCE}to${DEST}
make_script

##############################################
# resync -record -persist

CMD="dscli resyncflash -record -persist"
FILE=FC_resync_${SOURCE}to${DEST}
make_script


