#!/bin/sh
#
# NEED : expect script expect_send_sshkey.sh
############################################

DIRECT=1
PROMPT=':root'
EXPECT_SEND_KEY=send_passwd.sh


trap cleanup 1 2 3 6

cleanup()
{
	echo "Caught Signal ... cleaning up."
	kill_ssh_tunnel
	echo "Done cleanup ... quitting."
	exit 1
}

kill_ssh_tunnel () {
	echo -n " Killing SSH tunnel"
	ps -eaf | grep "ssh -f[N]L $PORT:" | awk '{ print $2 }' | xargs -n1 kill
	[ $? -eq 0 ] && echo "    [ OK ]  "|| echo "      [ FAILED ] "

}

usage () {
	echo "
`basename $0` -k [public key FILE] -P [Passwd] [liste user@IP]

OPTIONS :
---------	-p [prompt] 	=> change the prompt used by expect (default \":root\")

		-i [IP] 	=> use [IP] as ssh rebond
		-r 		=> use rebond as ssh rebond
		-m 		=> use majorque as ssh rebond

"
	exit 1
}

test_ssh () {

echo
echo "#########################"
echo "#  TEST SSH CONNECTION  #"
echo "#########################"
echo

for MACHINES in `echo $MACHINE_LIST` ; do
	
	NB_FIELD=`echo $MACHINES | awk -F@ '{ print NF }'`
	
	case $NB_FIELD in
	
		1)
		USER=""
		IP_SRV=$MACHINES
		;;

		2)
		USER="`echo $MACHINES | awk -F@ '{ print $1 }'`@"
		IP_SRV=`echo $MACHINES | awk -F@ '{ print $2 }'`
		;;
		
		*)
		echo "Error in machines list..."
		usage
		;;

	esac
			
	if [ $DIRECT -eq 1 ] ; then
		IP_TARGET=$IP_SRV
		PORT=22
	else
		IP_TARGET=127.0.0.1
		PORT=2279
	fi
		
	echo ""
	print " => [ Connecting to $IP_SRV ]"
	if [ $DIRECT -ne 1 ] ; then
		#echo -n " Building SSH Tunnel" 
		ssh -fNL $PORT:$IP_SRV:22 $REBOND 
	fi
	
	sleep 1
	ssh -fN  -o StrictHostkeyChecking=no -o PasswordAuthentication=no -p $PORT ${USER}$IP_TARGET "uname" && print "     [ OK ]  "|| print "      [ FAILED ] "  
	#$EXPECT_SEND_KEY $KEY ${USER}$IP_TARGET $PASSWD $PROMPT $PORT

	[ $DIRECT -ne 1 ]&& kill_ssh_tunnel

done

}

check_param () {
	[ -z $PASSWD ] && usage
	[ -z $MACHINE_LIST ] && usage
}

PARAMS=`getopt rmi:p:P:k: "$@" `

[ $? -ne 0 ] && usage

eval set -- "$PARAMS"


while true ; do
   case "$1" in
   	-r|--rebond) DIRECT=0 && REBOND=root@rebond ; shift 1 ;;
	-m|--majorque) DIRECT=0 && REBOND=service@majorque ; shift 1 ;;
	-i|--ip) shift 
		 [ -n "$1" ] && DIRECT=0 && REBOND=$1 && shift 1 ;;
	-k|--key) shift 
		 [ -n "$1" ] && KEY=$1 && shift 1 ;;
	-p|--prompt) shift 
		 [ -n "$1" ] && PROMPT=$1 && shift 1 ;;
	-P|--passwd) shift 
		 [ -n "$1" ] && PASSWD=$1 && shift 1 ;;

	--) shift ; break ;;

   esac
done

MACHINE_LIST=$@

check_param

for MACHINES in `echo $MACHINE_LIST` ; do
	
	NB_FIELD=`echo $MACHINES | awk -F@ '{ print NF }'`
	
	case $NB_FIELD in
	
		1)
		USER=""
		IP_SRV=$MACHINES
		;;

		2)
		USER="`echo $MACHINES | awk -F@ '{ print $1 }'`@"
		IP_SRV=`echo $MACHINES | awk -F@ '{ print $2 }'`
		;;
		
		*)
		echo "Error in machines list..."
		usage
		;;

	esac
			
	if [ $DIRECT -eq 1 ] ; then
		IP_TARGET=$IP_SRV
		PORT=22
	else
		IP_TARGET=127.0.0.1
		PORT=2279
	fi
		
	echo ""
	echo " => [ Connecting to $IP_SRV ]"
	if [ $DIRECT -ne 1 ] ; then
		echo -n " Building SSH Tunnel" 
		ssh -fNL $PORT:$IP_SRV:22 $REBOND && echo "	[ OK ]  "|| echo "	[ FAILED ] "
	fi
	
	sleep 1
	echo " Sending SSH Key ..."
	$EXPECT_SEND_KEY $KEY ${USER}$IP_TARGET $PASSWD $PROMPT $PORT

	[ $DIRECT -ne 1 ]&& kill_ssh_tunnel

	echo ""
	echo "==============="
done

test_ssh
