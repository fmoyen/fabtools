#!/bin/ksh
#
# COMPONENT_NAME: perfpmr
#
# FUNCTIONS: none
#
# ORIGINS: 27
#
# (C) COPYRIGHT International Business Machines Corp.  2000
# All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# tprof.sh
#
# invoke tprof to collect data for specified interval and again to produce report
#
export LANG=C

show_usage()
{
	echo "Usage: tprof.sh [-S path][-p program][-D][-E] [-f samp_freq] time_in_seconds"
 	echo "          time is total time to measure"
 	echo "          -p program is optional executable to be profiled,"
 	echo "          which, if specified, must reside in current directory"
	echo "          -E specifies that it uses hardware counters for sampling"
	echo "          -D specifies that the -D option is passed into tprof for detailed offset data"
	echo "          -f specifies sampling frequency for hardware counters (default 10ms)"
	echo "          -S path  specifies list of paths to search for binaries"
	exit 0
}

if [ $# -eq 0 ]; then
	show_usage
fi


# exit if tprof executable is not installed
if [ ! -x /usr/bin/tprof ]; then
  echo "     TPROF: /usr/bin/tprof command is not installed"
  echo "     TPROF:   This command is part of the optional"
  echo "                'bos.perf.tools' fileset."
  exit 1
fi

PGM=tprof
TPROFDFLAG=""
TPROFEFLAG=""
while getopts S:f:p:ED flag 2>/dev/null; do
	case $flag in
		S) spath="-S $OPTARG";;
		f) samp_frequency="-f $OPTARG";;
		p) PGM=$OPTARG;;
		E) TPROFEFLAG="-E";;
		D) TPROFDFLAG="-D";;
		\?) show_usage;;
	esac
done
shift OPTIND-1
SLEEP=$@


# collect raw data
do_purr()
{
if  /usr/sbin/smtctl >/dev/null 2>&1; then
        KERTYPE=`bootinfo -K`
        if [ "$KERTYPE" = 32 ]; then
                PURR=""
        else
                PURR="-R"
        fi
else
        PURR=""
fi
}

#PURR=""   # running with PURR again
do_purr

if [  "$TPROFEFLAG" != "-E" ]; then
	samp_frequency=""
fi

echo "\n     TPROF: Starting tprof for $1 seconds...."
if id | grep root >/dev/null; then
	tprof $spath $TPROFDFLAG $TPROFEFLAG $samp_frequency $PURR -T 20000000 -l -r tprof -F -c -A all -x sleep $SLEEP >tprof.out 2>&1
	echo "\n     TPROF: Starting tprof with no PURR for $1 seconds...."
	tprof $spath $TPROFDFLAG $TPROFEFLAG $samp_frequency -T 20000000 -l -r tprof_nopurr -F -c -A all -x sleep $SLEEP >tprof_nopurr.out 2>&1
else
	tprof $spath $PURR -l -r tprof -F -c -A all -x sleep $SLEEP >tprof.out 2>&1
fi
echo "     TPROF: Sample data collected...."


# reduce data
echo "     TPROF: Generating reports in background (renice -n 20)"
PID=$$
renice -n 10 -p $PID

if [ $PGM = "tprof" ]
then
 tprof $PURR -l -r tprof -skeuj >> tprof.out 2>&1
 tprof  $spath -l -r tprof_nopurr -zskeuj >> tprof_nopurr.out 2>&1
else
 tprof $spath $PURR -l -p $PGM -r tprof -kseuj >> tprof.out 2>&1
fi

if [ -f tprof.prof ]; then
    mv tprof.prof tprof.sum
fi

echo "     TPROF: Tprof report is in tprof.sum"
