#!/bin/ksh
#
# COMPONENT_NAME: perfpmr
#
# FUNCTIONS: none
#
# ORIGINS: IBM
#
# (C) COPYRIGHT International Business Machines Corp. 2000
# All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# svmon.sh
#
WPARG=0
WPARARGG=ALL
WPARPG=0
WPARARGPG=ALL

show_usage()
{
	echo "Usage: svmon.sh [-o outputfile] [-w <wparname|ALL>] [-W <wparname|ALL>]"
	echo "default output file is svmon.out"
}

# exit if svmon executable is not installed
if [ ! -f /usr/bin/svmon ]; then
  echo "     SVMON: /usr/bin/svmon command is not installed"
  echo "     SVMON:   This command is part of the 'bos.perf.tools' fileset."
  exit 1
fi


while getopts o:w:W: flag ; do
        case $flag in
                o)     filename=$OPTARG;;
		w)     WPARARGG=$OPTARG;WPARG=1;;
		W)     WPARARGPG=$OPTARG;WPARPG=1;;
                \?)    show_usage
        esac
done
if [ -z "$filename" ]; then
	filename=svmon.out
fi

echo "Date/Time:   `date`" >> $filename
echo "\n" >> $filename
if [ $WPARG -eq 1 ]
then
	echo "svmon -G -@ ALL" >> $filename
	echo "----------" >> $filename
	svmon -G -@ ALL >> $filename
	if [ $? -eq 1 ]
	then
		svmon -G >> $filename
	fi
else
	echo "svmon -G" >> $filename
	echo "----------" >> $filename
	svmon -G >> $filename
fi
if [ $WPARG -eq 1 ]
then
	if [ $WPARPG -eq 1 ]
	then
		echo "svmon -Pnsm -@ $WPARARGPG" >> $filename
		echo "----------" >> $filename
		svmon -Pnsm -@ $WPARARGPG >> $filename
		if [ $? -eq 1 ]
		then
			svmon -Pnsm  >> $filename
		fi
	else
		echo "svmon -Pnsm -@ ALL" >> $filename
		echo "----------" >> $filename
		svmon -Pnsm -@ ALL >> $filename
		if [ $? -eq 1 ]
		then
			svmon -Pnsm  >> $filename
		fi
	fi
else
	echo "svmon -Pnsm" >> $filename
	echo "----------" >> $filename
	svmon -Pnsm  >> $filename
fi

#
# list the 'mmap mapped to sid'
#
#grep 'mmap mapped to sid' svmon.tmp |
#while read P1 P2 P3 P4 P5 P6 SID P7; do
#    echo "\n"	>> $filename
#    echo "svmon -S $SID"	>> $filename
#    echo "---------------"	>> $filename
#    svmon -S $SID	>> $filename
#done
if [ $WPARG -eq 1 ]
then
	svmon -lS -@ ALL > ${filename}.S
	if [ $? -eq 1 ]
	then
		svmon -lS > ${filename}.S
	fi
else
	svmon -lS > ${filename}.S
fi
#/usr/bin/rm -f svmon.tmp
