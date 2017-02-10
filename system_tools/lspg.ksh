#!/bin/ksh
# Author: Sebastien Chabrolles

SVMON_PG_OUT=/tmp/svmon.out

echo ""
date
echo "Retreiving Memory informations and calculating the statistics... ; Please Wait..."

svmon -S | awk '{ FIELD=NF-1 } ; $2=="-" && $FIELD>0 { print }' > $SVMON_PG_OUT

echo 
echo "    Vsid      Esid Type Description              PSize  Inuse   Pin Pgsp Virtual"
cat $SVMON_PG_OUT 

TOTAL_PGSP=`echo "\`awk  'BEGIN { RESULT=0 } { FIELD=NF-4 ; PGS=NF-1 ; gsub ("s","4",$FIELD) ; gsub ("m","64",$FIELD) ; gsub("L","16384",$FIELD) ; RESULT=RESULT + $PGS * $FIELD } END { print RESULT }' $SVMON_PG_OUT\` / 1024" | bc`

echo 
echo TOTAL IN PAGING SPACE = $TOTAL_PGSP MB
echo
rm -f $SVMON_PG_OUT
