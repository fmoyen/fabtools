#!/bin/ksh

get_kdb()
{
	echo "****************  getvmpools.sh: 'vmpool *'  ****************"
	echo "vmpool *"| kdb > vmpools.save
	cat vmpools.save
	np=`cat vmpools.save | awk -v p=0 '{if(p==1&&length($1)==2){print $0;}else{if($1=="VMP"){p=1}}}'|wc -l`
	echo "\n****************  getvmpools.sh:  $np pools  ****************"

	p=0
	while [ $p -lt $np ]
	do
		echo "\n****************  getvmpools.sh: vmpool $p  ****************"
		echo "vmpool $p" | kdb
		let p=p+1;
	done
}

get_kdb > vmpools.out

exit 0
