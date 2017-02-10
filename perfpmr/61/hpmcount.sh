#!/bin/ksh
show_usage()
{
	echo "Usage: hpmcount.sh [-H] | <time in seconds>"
	echo "\t-H  do not run hpmcount"
	echo "\ttime  number of seconds for each group"
	exit 0
}

while getopts H flag 2>/dev/null; do
        case $flag in
		H) no_hpmcount=1;;
                \?) show_usage;;
        esac
done
shift OPTIND-1
sleeptime=${@:-5}

if [ -n "$no_hpmcount" ]; then
	exit 0
fi

groups="0 6 7 8 9 10 11 12 18 35 36 37 38 39 40 41 42 43 44 45 47 51 52 69 71 100 101 133 198 201"

#sample_length=30
stall_breakdown_groups="0 12 133 201 35 37 170 198 6 46 47"
# pm_utilization  0
# data_latencies  12
# pm_group_dispatch 133

> hpmcount.out
for group in $groups; do
	echo "group = $group" >> hpmcount.out
	/usr/bin/hpmcount -g $group -H sleep $sleeptime >> hpmcount.out
	echo "\n\n" >> hpmcount.out
done
