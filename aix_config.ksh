#!/usr/bin/ksh
#
HOST=$(hostname)
NOM_BENCH=mon_bench
USAGE=$0

#
#interface
#functions:definitions

#init() : usage : init
#	creates two files, whose paths are contained in vars
#	TINDEX and TIDIOT
#	returns an error message and terminates the script if anything prevents him from
#	creating one and or the other
#end init()

#helpheader() : usage : helpheader un parametre
#	writes in the file referenced by the var TIDIOT an html header 
#	containing the name of the bench 
#end helpheader()

#helpfooter() : usage : helpfooter
#	writes in the file referenced by the var TIDIOT html end of file markers 
#end helpfooter()

#help() : usage : help
#
#end help()

#head() : usage : head
#	writes in the file referenced by the var TINDEX the information header
#end head()

#close() : usage : close
#	finishes writing in the file referenced by the var TBODY
#	creates the final files and removes the temporary ones created
#end close()

#h1() : usage : h1 $1
# 	
#end h1()

#h2() : usage : h2 $1 $2 $3
#
#end h2()

#h3() : usage : h3 $1 $2 $3
#
#end h3()

#h4()
#
#end h4()

#startlist() : usage : startlist
#	adds in the file referenced by the var TINDEX a list start marker
#end startlist()

#stoplist() : usage : stoplist
#	adds in the file referenced by the var TINDEX an end of list marker 
#end stoplist()

#list_volume_groups() : usage : list_volume_groups
#	lists the contents of the volume groups
#end list_volume_groups()




#implementation

#var
	umask 477
	DEBUG=${DEBUG:-""}
	#the DEBUG var can be used to trace the functionment of this script
	#to do so initialize it with a print instruction and export it
	#before running this script 
	
	TINDEX="/tmp/TINDEX.tmp.$$"
	TBODY="/tmp/TBODY.tmp.$$"
	TIDIOT="/tmp/TIDIOT.tmp.$$"
	IDIOT="$HOST.cmdref.html"
	export I1=0
	export I2=0
	export I3=0
	[ "$1" = "-t" ] && FORMAT="txt" || FORMAT="html"
	#determines the output format of the result
	#defaut is html, the -t flag sets it to raw text 

	trap "rm -f ${TINDEX} ${TBODY} ${TIDIOT}" 0 1 2 3 15
	#destroys temporary files if the script is killed before its end
#var end 

#functions

	init()
	{
		$DEBUG
		touch $TINDEX
		
		if (( $? != 0 ))
		then
			echo "Failed to open index file..dying"
			exit 1
		fi
		
		touch $TIDIOT
		
		if (( $? != 0 ))
		then
			echo "Failed to open help file..dying"
			exit 1
		fi
		
	}

	
	helpheader()
	{
		(
		echo "<HTML>"
        	echo "<HEAD>"
       		echo "<TITLE>$1</TITLE>"
        	echo "</HEAD>"
        	echo "<BODY>"
        	echo "<CENTER>"
        	echo "<H1>"
        	echo "<FONT COLOR=\"red\">"
        	echo "$NOM_BENCH"
        	echo "<HR>"
        	echo "Command Information"
        	echo "</FONT>"
        	echo "</H1>"
        	echo "</CENTER>"
        	echo "<HR>"
        	echo "" | awk '{for (i=1;i<21;i++) printf("<BR>")}'
        	echo "<HR>"
        	) >>${TIDIOT}
	}


	helpfooter()
	{
		(
		echo "<FONT COLOR=\"red\">"
		echo "<H3><A NAME=\"noref\">NO COMMAND AVAILABLE FOR THIS ITEM</A></H3>"
		echo "</FONT>"
 	        echo "<HR>"
        	echo "" | awk '{for (i=1;i<21;i++) printf("<BR>")}'
        	echo "<HR>"
        	echo "</BODY>"
        	echo "</HTML>"
        	) >>${TIDIOT}
	}

	
	help()
	{
        	# $1=reference
        	# $2=command
        	(
                	echo "<H3><A NAME=\"$1\">command: $2</A></H3>"
                	echo "" | awk '{for (i=1;i<21;i++) printf("<BR>")}'
                	echo "<HR>"
        	) >>${TIDIOT}
	}


	head()
	{
		$DEBUG
		(
		if [ "${FORMAT}" = "txt" ]
		        then
        	        	echo "$NOM_BENCH"
                		echo
                		echo "System informations"
                		echo
                		echo "AIX configuration for host $1"
                		echo
                		echo "Creation date : $(date '+%d %B %Y')"
				echo "^L"
                		echo "Table Of Contents"
        		else
                		echo "<HTML>"
                		echo "<HEAD>"
                		echo "<TITLE>$1</TITLE>"
                	echo "</HEAD>"
                	echo "<BODY>"
                	echo "<a name=head></H1>"
                	echo "<CENTER>"
                	echo "<H1>"
                	echo "<FONT COLOR=\"red\">"
                	echo "<HR>"
                	echo "<XMP>"
                	echo "$NOM_BENCH"
                	echo "System informations"
                	echo "</XMP>"
                	echo "</H1>"
                	echo "</FONT>"
                	echo "</CENTER>"
                	echo "<HR>"
                	echo "<H1>AIX configuration for host $1</H1>"
                	echo "</H1>"
                	echo "<XMP>"
                	echo "Creation date : $(date '+%d %B %Y')"
             		echo "OS LEVEL: AIX $(oslevel)"
			echo "MAINTENANCE LEVEL:"
			instfix -i|grep AIX_ML
                	echo "</XMP>"
	               	echo "<H1>Table Of Contents"
                	echo "<HR>"
                	echo "</H1>"
 			echo "<A href=#map>Mapping of the LVs over the PVs</a>"
			echo "<br><A href=#disques>Dispatching of the LVs upon the VGs</a>"               	
			echo "<br><A href=#ssaloop>SSA Adapters on the system</a>"
			echo "<UL>"
        	fi
       		) >$TINDEX
	}
	

	close()
	{
        	(
        	if [ "${FORMAT}" = "txt" ]
        	then
                	echo "$NOM_BENCH"
        	else
                	echo "</UL>"
                	echo "<HR>" >>$TINDEX
                	echo "<HR>"
                	echo "<I>$NOM_BENCH</I>"
                	echo "</BODY>"
                	echo "</HTML>"
        	fi
        	) >>$TBODY
        
		helpfooter

        	if [ "${FORMAT}" = "txt" ]
        	then
                	echo "^L" >>$TINDEX
        	fi
        	cp $TINDEX ./$HOST.${FORMAT}
        	cat $TBODY >> ./$HOST.${FORMAT}
        	cp $TIDIOT ./${IDIOT}
	}

	

	h1()
	{
        	$DEBUG
        	I1=`expr "${I1}" + 1`
        	I2=0
        	I3=0
        	(
        	if [ "${FORMAT}" = "txt" ]
        	then
                	HEAD=`echo "${I1}. $1"`
                	echo "${HEAD}" >>$TINDEX
                	echo ${HEAD}
                	echo;echo
        	else
                	CH="${I1}"
                	#echo "<H2><A NAME=\"toc${CH}\" HREF=\"#s${CH}\">${CH}. $1</A></H2>" >>$TINDEX
                	echo "<H2>"
                	echo "<A NAME=\"s${CH}\" HREF=\"${IDIOT}#noref\">${CH} $1</A><BR>"
                	echo "</H2>"
        	fi
        	) >>$TBODY
	}


	h2()
	{
        	$DEBUG
        	I2=`expr "${I2}" + 1`
        	I3=0
		(
		if [ "${FORMAT}" = "txt" ]
		then
        		HEAD=`echo "${I1}.${I2} $1"`
        		echo "\t${HEAD}" >>$TINDEX
        		echo ${HEAD}
        		echo;echo
        		if [ "$3" = "" ]
        		then
                		echo "command: $2\n"
        		fi
        		$2
        		echo "^L"
		else
        		CH="${I1}.${I2}"
        		echo "<UL><LI><A NAME=\"ttoc${CH}\" HREF=\"#ss${CH}\">${CH} $1</A></UL>" >>$TINDEX
        		echo "<H2>"
        		if [ "$3" = "no" ]
        		then
          			echo "<A NAME=\"ss${CH}\" HREF=\"${IDIOT}#noref\">${CH} $1</A><BR>"
        		else
          			echo "<A NAME=\"ss${CH}\" HREF=\"${IDIOT}#ss${CH}\">${CH} $1</A><BR>"
          			help "ss${CH}" "$2"
        		fi
        		echo "</H2>"
        		echo "<XMP>"
        		$2
        		errno=$?
        		if [ $errno -ne 0 ]
        		then
                		echo "</XMP>"
                		echo "<FONT COLOR=\"red\">"
                		echo "ERROR: $2 FAILED (code $errno) !!!"
                		echo "</FONT>"
                		echo "<XMP>"
        		fi
        		echo "</XMP>"
        		echo "<BR><BR>"
        		echo "<A HREF=\"#s${I1}\">Start of Chapter ${I1}</A><br>"
        		echo "<A HREF=\"#ttoc${CH}\">Table of Contents</A><br>"
        		echo "<H1>"
        		echo "<HR>"
        		echo "</H1>"
		fi
        	) >>$TBODY
	}


	h3()
	{
        	$DEBUG
        	I3=`expr "${I3}" + 1`
		(
			if [ "${FORMAT}" = "txt" ]
			then
        			HEAD=`echo "${I1}.${I2}.${I3} $1"`
        			echo "\t\t${HEAD}" >>$TINDEX
        			echo ${HEAD}
        			echo;echo
        			if [ "$3" = "" ]
        			then
                			echo "command: $2\n"
        			fi
        			$2
        			echo "^L"
			else
        			CH="${I1}.${I2}.${I3}"
        			echo "</XMP>"
        			echo "<UL><UL><LI><A NAME=\"tttoc${CH}\" HREF=\"#sss${CH}\">${CH} $1</A></UL></UL>" >>$TINDEX
        			echo "<H2>"
        			if [ "$3" = "no" ]
        			then
         				echo "<A NAME=\"sss${CH}\" HREF=\"${IDIOT}#noref\">${CH} $1</A><BR>"
        			else
         				echo "<A NAME=\"sss${CH}\" HREF=\"${IDIOT}#sss${CH}\">${CH} $1</A><BR>"
         				help "sss${CH}" "$2"
        			fi
        			echo "</H2>"
       				echo "<XMP>"
        			$2
        			errno=$?
        			if [ $errno -ne 0 ]
        			then
                			echo "</XMP>"
                			echo "<FONT COLOR=\"red\">"
                			echo "ERROR: $2 FAILED (code $errno) !!!"
                			echo "</FONT>"
                			echo "<XMP>"
        			fi
        			echo "</XMP>"
        			echo "<BR><BR>"
        			echo "<A HREF=\"#ss${I1}.${I2}\">Start of Chapter ${I1}.${I2}</A>"
        			echo "<A HREF=\"#tttoc${CH}\">Table of Contents</A>"
        			echo "<H1>"
        			echo "<HR>"
        			echo "</H1>"
			fi
        	) >>$TBODY
	}


	
	h4()
	{
        	(
        	echo "<H4>"
        	echo $1
        	echo "</H4>"
        	echo "<XMP>"
        	$2
        	echo "</XMP>" ) >>$TBODY
	}

	
	startlist()
	{
        	echo "<li>" >>$TINDEX
	}

	
	stoplist()
	{
        	echo "</li>" >>$TINDEX
	}

	list_volume_groups()
	{
        	for i in `lsvg -o`
        	do
                	h3 "Volume Group ${i} details (1)" "lsvg ${i}"
                	h3 "Volume Group ${i} details (2)" "lsvg -l ${i}"
        	done
	}


	hwconfig_attr()
	{
        	for i in `lscfg|egrep "^\+ |^\- "|awk '{print $2}' | sort`
        	do
                	h3 "Resource attributes of $i" "lsattr -E -l $i"
        	done
	}


	logicalvol()
	{
		for i in `lsvg`
		do
        		for lv in `lsvg -l $i |grep "/" | awk '{print $1}'`
        		do
                		#echo "\n\nLogical volume $lv details\n";lslv $lv
                		#echo "\n\nLogical Volume $lv details\n";lslv -l $lv
                		#echo \n\n"Logical Volume $lv Physical maps\n";lslv -m $lv

                		h3 "Logical volume $lv details (1)" "lslv $lv"
                		h3 "Logical Volume $lv details (2)" "lslv -l $lv"
                		#h3 "Logical Volume $lv Physical maps" "lslv -m $lv"
        		done
		done
	}


	physicalvol()
	{
		for pv in `lspv |awk '{print $1}'`
		do
        		#echo "\n\nPhysical Volume $pv details\n";lspv -l $pv
        		#echo "\n\nPhysical Volume $pv details\n";lspv -p $pv
        		#echo "\n\nPhysical Volume $pv Physical maps\n";lspv -M $pv

        		h3 "Physical Volume $pv details (1)" "lspv -l $pv"
        		h3 "Physical Volume $pv details (2)" "lspv -p $pv"
        		#h3 "Physical Volume $pv Physical maps" "lspv -M $pv"
		done
	}


	network_if()
	{
        	lsdev -C -c if

        	for i in `lsdev -C -c if |awk '{print $1}'`
        	do
                	h3 "Network Interface $i details" "lsattr -E -l $i"
        	done
	}


	hconroutine()
	{
		users=`lshconu`
		for u in $users
		do
        		profiles=`lshconp -Fl -N $u |awk '{print $1}'`
        		for p in $profiles
        		do
                		lshcons -n $p -N $u
        		done
		done
	}


	nserver() 
	{
		$DEBUG
        	files=$(find /etc/nameserver -type f -print | egrep -v "SCCS|copy$")
        	if [[ ! -z $files ]] 
		then
                	cat $files
        	else
                	echo "NO FILES FOUND"
        	fi
	}


	user_profiles()
	{
        	find / -name ".profile" -print |xargs -i  -t cat {} 2>&1
	}

	
	xdefaults_files()
	{
        	find / -name ".Xdefaults" -print |xargs -i  -t cat {} 2>&1
	}


	user_mwm()
	{
        	find / -name ".mwmrc" -print |xargs -i  -t cat {} 2>&1
	}

	
	rhosts_files()
	{
        	find / -name ".rhosts" -print |xargs -i  -t cat {} 2>&1
	}
#end functions


########################################################################
# MAIN INSTRUCTIONS 
########################################################################

init
head $HOST
helpheader

########################################################################
#       text                    command                 reference
########################################################################

#HARDWARE###############################################################
h1      "Hardware"
h2      "Hardware Configuration"        "lscfg"
h2      "Hardware details"              "lscfg -v"
h2      "System Configuration sys0"     "/usr/sbin/lsattr -E -l sys0"
h2      "Hardware Resource attributes"  "hwconfig_attr"         "no"
########################################################################

#USER CONFIGURATION#####################################################
h1      "User Configuration"
h2      "/etc/passwd file"      "cat /etc/passwd"
h2      "/etc/group file"       "cat /etc/group"
h2      "/etc/netgroup file"    "cat /etc/netgroup"
h2      "/etc/security/limits file" "cat /etc/security/limits"
h2      "Users .profile Files"  "user_profiles"         "no"
h2      "Users .Xdefaults Files"        "xdefaults_files" "no"
h2      "Users .mwmrc Files"            "user_mwm"        "no"
h2      "Users .rhosts Files"           "rhosts_files"          "no"
########################################################################

#FILE SYSTEMS###########################################################
h1      "Filesystems"
h2      "Configured file systems" "lsfs"
h2      "Disk Space totals"     "df -k"
h2      "/etc/filesystems file" "cat /etc/filesystems"
########################################################################


#VOLUMES################################################################
h1      "Disk Volumes"
h2      "Volume groups"         "lsvg"
h2      "Volume group details"  "list_volume_groups" "no"
h2      "Logical Volume details" "logicalvol"   "no"
h2      "Physical Volume details" "physicalvol" "no"
########################################################################

#PRINTERS###############################################################
h1      "Printers"
h2      "Printer definitions"      "cat /etc/qconfig"
########################################################################

#NETWORK################################################################
h1      "Networking"
h2      "Network Interfaces"    "network_if"    "no"
h2      "Static Routes" "netstat -rn"   "netstat -rn"
h2      "Bootptab"      "cat /etc/bootptab"     "cat /etc/bootp"
h2      "Services"      "cat /etc/services"     "cat /etc/services"

#NETWORK   NIS/NFS/RCP/DNS##############################################
h2      "NFS exports"   "lsnfsexp"      "exports"
h2      "NFS mounted filesystems"       "lsnfsmnt"
h2      "NIS"   "cat /etc/yp/Makefile"
h2      "NIS list the master"   "lsmaster"
h2      "NIS Domain"    "ypwhich"
h2      "NIS security"  "cat /var/yp/securenets"
h2      "RPC info"      "rpcinfo -p"
h2      "tftp access"   "cat /etc/tftpaccess.ctl"
h2      "Remote access" "cat /etc/hosts.equiv"
h2      "Remote printer access" "cat /etc/hosts.lpd"
h2      "Remote X access"       "cat /etc/X?.hosts"
h2      "Remote ftp access"     "cat /etc/ftpusers"
h2      "Syslog daemon"         "cat /etc/syslog.conf"
h2      "Sendmail Configuration" "cat /etc/sendmail.cf"
h2      "SNA configuration"      "exportsna -A"
if [ -f /etc/named.boot ]
then
        h2 "Nameserver configuration"
        h3 "Named.boot" "cat /etc/named.boot"
        h3 "Nameserver details" "nserver"
        h3 "Nameserver Resolver file" "cat /etc/resolv.conf"
fi
########################################################################

#HCON###################################################################
#h1      "HCON"
#h2      "HCON users status"     "stathcon -u"
#h2      "HCON users"            "lshconu"
#h2      "HCON profiles"         "hconroutine" "no"
########################################################################


#APPLICATIONS###########################################################
#h2      "Oracle /etc/oratab" "cat /etc/oratab"
########################################################################

#SYSTEM SOFTWARE########################################################
h1      "System Software"
h2      "System Software installed"     "lslpp -l all"
h2      "System software fix history"   "lslpp -h"
h2      "System software level"         "oslevel"
h2      "System software at earlier level" "oslevel -l"
h2      "System software at later  level" "oslevel -g"
h2      "System software missing at earlier level" "oslevel -m"
h2      "Software license info"         "cat /usr/lib/netls/conf/nodelock"
########################################################################

########################################################################
h1	"Unix configuration"
h2      "Inittab File"          "cat /etc/inittab"
h2      "crontabs"              "cronadm cron -l "
h2      "rc.boot file"          "cat /sbin/rc.boot"
h2      "rc.tctpip file"        "cat /etc/rc.tcpip"
h2      "rc.sna file"           "cat /etc/rc.sna"
h2      "rc.nfs file"           "cat /etc/rc.nfs"
h2      "rc.ncs file"           "cat /etc/rc.ncs"
h2      "rc.xcom file"          "cat /etc/rc.xcom"
h2      "rc.local file"         "cat /etc/rc.local"
h2      "rc.hcon file"          "cat /etc/rc.hcon"
h2      "/etc/profile file"     "cat /etc/etc.profile.xcom"
h2      "/etc/environment file" "cat /etc/environment"
h2      "/etc/inetd.conf file"  "cat /etc/inetd.conf "
########################################################################

#HACMP##################################################################
#h1     "Hacmp"
#h2     "Hacmp Cluster topology"                " /usr/sbin/cluster/cllscf"
#h2     "Hacmp Cluster defintions"              " /usr/sbin/cluster/cllsclstr"
#h2     "Hacmp Topology Information by Node"    "/usr/sbin/cluster/cllsnode"
#h2     "Hacmp Topology Information by Network Name"    "/usr/sbin/cluster/cllsnw"
#h2     "Hacmp Topology Information by Network Adapter" "/usr/sbin/cluster/cllsif"
#h2     "Hacmp Node environment node 1"    "/usr/sbin/cluster/clshowres -n 1"
#h2     "Hacmp  Node environment node 2"   "/usr/sbin/cluster/clshowres -n 2"
#h2     "Hacmp device major numbers"            "ls -la /dev"
########################################################################
#
# END MAIN INSTRUCTIONS SECTION
#


# Beginning disk mapping section
#
#
########################################


set -A listevg $(lsvg -o)
#liste des volume groups

set -A couleurs 118844 114488 884411 881144 441188 448811 7700ff f0077 77ff00 ff7700 0077ff 00ff77 0000ff ff0000 ff00ff ffff00 00ffff 00ff00 123456 654321 abcdef fedcba aabbcc bccaa ccbbaa ccaabb
#lettreslv le tableau des lettres pour les lv
#couleurs le tableau des couleurs pour les lv

echo "<a name=map><h2>Mapping of the LVs over the PVs for every VG</h2></a>">>$TBODY

echo "<h3>List of the VGs</h3>">>$TBODY

for vg in ${listevg[*]}
do
	echo "<A href=#${vg}map>${vg}</A><br>">>$TBODY
done

for vg in ${listevg[*]}
do
	echo "<a name=${vg}map><h1>volume group:$vg </a></h1>">>$TBODY
	set -A temporaire $(lsvg -p $vg|grep -Ev "NAME|:"|awk '{print $1}')
	for pv in ${temporaire[*]}
	do
		typeset -i taille=$(lspv -L $pv|grep TOTAL|awk '{print $3}')
		eval $pv'size=$taille'
		compteur=1
		while (( compteur <=taille ))
		do
			eval $pv'pps[compteur]="<td bgcolor=ffffff><b>&nbsp</b></td>"'
			(( compteur+=1 ))
		done
	done
	
	set -A listelv $(lsvg -l $vg|grep -Ev "NAME|:"|awk '{print $1}')
	#liste des volumes logiques du VG en cours
	nombrelv=${#listelv[*]}
	#nombre de volumes logiques
	
	compteur=0
	while (( compteur<nombrelv ))
	do
		echo "<b><FONT COLOR=${couleurs[compteur]}>${listelv[compteur]}</FONT></b>">>$TBODY
		(( compteur+=1 ))
	done

	echo "<br><b><FONT COLOR=0000ff> blank for a single volume, s for striped volume<br>">>$TBODY
	echo "1 2 3 for mirrors, a b c for striped mirrors</FONT></b>">>$TBODY
	compteur=0
	while (( compteur<nombrelv ))
	do
		for pv in $(lsvg -p $vg|grep -Ev ":|NAME"|awk '{print $1}')
		do
			unset char
			unset char2
			
			copy=$(lslv ${listelv[compteur]}|grep SCHED|awk '{print $2}')
			if (( copy >1 ))
			then
				char=M
			fi

			stripe=$(lslv ${listelv[compteur]}|grep SCHED|awk '{print $5}')
			if [[ $stripe = striped ]]
			then
				char2=S
			fi
				
			case "${char}${char2}" in
			(S) symb=s;;
			(M) symb=1;;
			(MS) symb=a;;
			(*) symb=\&nbsp;;
			esac
			strip=$(lslv ${listelv[compteur]}|grep STRIPE|grep SIZE)
			for pp in $(lslv -m ${listelv[compteur]}|grep -v PV|grep $pv|awk '{print $2}')
			do
				typeset -i10 pp
				eval $pv'pps[$pp]="<td bgcolor=${couleurs[$compteur]}><b>$symb</b></td>"'
			done
	
			if [[ $symb = 1 ]]
			then 
				symb=2
			elif [[ $symb = a ]]
			then
				symb=b
			fi
		
			for pp in $(lslv -m ${listelv[compteur]}|grep -v PV|grep $pv|awk '{print $4}')
			do
				typeset -i10 pp
				eval $pv'pps[$pp]="<td bgcolor=${couleurs[$compteur]}><b>$symb</b></td>"'
			done
		
			if [[ $symb = 2 ]]
			then
				symb=3
			elif [[ $symb = b ]]
			then
				symb=c
			fi


	
			for pp in $(lslv -m ${listelv[compteur]}|grep -v PV|grep $pv|awk '{print $6}')
			do
				typeset -i10 pp
				eval $pv'pps[$pp]="<td bgcolor=${couleurs[$compteur]}><b>$symb</b></td>"'
			done
		done
		
		(( compteur+=1 ))
	done

	comptepv=0
	echo "<table border=1>" >>$TBODY
	
	for pv in ${temporaire[*]}
	do
		position=1
		eval 'final=$'$pv'size'
		if (( comptepv == 4 ))
		then
			echo "<tr>">>$TBODY
		fi
		echo "<br>physical volume:$pv">>$TBODY
		echo "<br><br><br>">>$TBODY
		echo "<table border=1 bgcolor=555555>">>$TBODY
		for compteur5 in 1 2 3 4 5
		do
			echo "<td>">>$TBODY

			case "$compteur5" in
				(1)echo "edge">>$TBODY;;
				(2)echo "middle">>$TBODY;;
				(3)echo "center">>$TBODY;;
				(4)echo "inner m">>$TBODY;;
				(5)echo "inner e">>$TBODY;;
			esac
			
			echo "<table>">>$TBODY
			compteur7=0
			(( compteur6=compteur5*final/5 ))

			while (( position<=compteur6 ))
			do
				eval 'echo "${'$pv'pps[position]}">>$TBODY'
				(( position+=1 ))
				(( compteur7+=1 ))
				if (( compteur7==8 ))
				then
					echo "<tr>">>$TBODY
					(( compteur7=0 ))
				fi
			done
			echo "</table>" >>$TBODY
		done
		(( comptepv+=1 ))
		echo "</table>">>$TBODY
	done
	

	echo "</table>">>$TBODY
	echo "<a href=#map>Index</a>">>$TBODY
	echo "<br><a href=#head>Head</a>">>$TBODY
	echo "">>$TBODY

done

echo "">>$TBODY
echo "">>$TBODY
echo "">>$TBODY
echo "">>$TBODY
echo "">>$TBODY



#END Disk Mapping Section
#########################################
#########################################
#########################################
#


#########################################
# Begin Dispatching of the LVs
#########################################



graphepv="<FONT COLOR=0000ff><h2><b>P V</b></h2></FONT></center></td>"
graphelv="<FONT COLOR=00ff00><h2><b>L V</b></h2></FONT></center></td>"
graphemnt="<FONT COLOR=ff0000><h2><b>F S</b></h2></FONT></center></td>"
#chaines de caracteres pour representer les entites considerees

set -A listevg $(lsvg -o)
echo "<a name=disques><br><br><br><h2>Listing of the VGs<br></h2>">>$TBODY
echo "<h4>">>$TBODY


for vg in ${listevg[*]}
do
	echo "<A href=#${vg}dk>$vg</A><br>">>$TBODY
	set -A temporaire $(lsvg -p $vg|grep -Ev "NAME|:"|awk '{print $1}')
	eval 'set -A '$vg' ${temporaire[*]}'
done

echo "</h4>">>$TBODY
echo "">>$TBODY
echo "<h2>Listing of the PVs<br></h2>">>$TBODY
echo "<h4>">>$TBODY

for vg in ${listevg[*]}
do
	eval 'set -A temporaire ${'$vg'[*]}'
	for pv in ${temporaire[*]}
	do
		echo "<A href=#${vg}dk>$pv</A><br>">>$TBODY
		set -A temporaire2 $(lspv -l $pv|grep -Ev "NAME|:"|awk '{print $1}')
		eval 'set -A '$pv' ${temporaire2[*]}'
		set -A temporaire2 $(lspv -l $pv|grep -Ev "NAME|:"|awk '{print $5}')
		eval 'set -A '$pv'mnt ${temporaire2[*]}'
	done
done
#liste des VGs et des PVs et creation des tableaux des PVs et des LVs
#les LVs du PV nomme "monpv" se trouvent dans le tableau du meme nom
#idem pour les PV du VG "monvg" 
#les points de montage des LVs du PV nomme "monpv" se trouvent dans le tableau "monpvmnt"

echo "</h4>">>$TBODY


for vg in ${listevg[*]}
do
	echo "">>$TBODY
	echo "<h4><center><a name=${vg}dk>$vg</a></center></h4>">>$TBODY
	echo "<center><table border=2>">>$TBODY
	
	eval 'set -A temporaire ${'$vg'[*]}'
	echo "<td><center><br>$graphepv">>$TBODY
	for pv in ${temporaire[*]}
	do
		echo "<td><center><br>${pv}</center></td>">>$TBODY
	done
	echo "<tr>">>$TBODY
	#chaque PV
	
	echo "<td><table border=1><td><center><br>$graphelv</center></td><tr><td><center><br>$graphemnt">>$TBODY
	echo "</center></table></td>">>$TBODY
	for pv in ${temporaire[*]}
	do
		eval 'set -A temporaire3 ${'$pv'[*]}'
		echo "<td><table>">>$TBODY
		for lv in ${temporaire3[*]}
		do
			echo "<td><table border=1>">>$TBODY		
			echo "<td><center><br>${lv}">>$TBODY
			echo "<tr><td><center><br>$(lsvg -l $vg|grep $lv|awk '{print $7'})">>$TBODY
			echo "</table></td>">>$TBODY	

		done

		echo "</table></td>">>$TBODY
	done
	echo "</table>">>$TBODY
	#chaque LV


	echo "</table></br><A HREF=#disques>Index</A><br><a href=#head>Head</a>">>$TBODY
	#fermeture de la grille
done




################################
# End of Dispatching of the LVs 
################################

################################
# Begin SSA loops 
################################


echo "<a name=ssaloop><h3>SSA ADAPTERS PRESENT ON THE SYSTEM</h3></a>">>$TBODY



set -A listessa $(lsdev -Cc adapter|grep ssa|awk '{print $1}')

lsdev -Cc adapter|grep ssa 1>/dev/null 2>&1
erreur=$?


if (( erreur != 0 ))
then
	echo "NO SSA DISKS ON THIS SYSTEM">>$TBODY
fi

set -A listepdk $(lsdev -Cc pdisk|grep SSA|awk '{print $1}')

set -A listevg $(lsvg)


for ssa in ${listessa[*]}
do
	for disk in $(ssadisk -a $ssa -P)
	do
		a1=$(ssaconn -l $disk -a $ssa|awk '{print $3}')
		b1=$(ssaconn -l $disk -a $ssa|awk '{print $5}')
		
		if [[ -n $a1 ]] && [[ $a1 != - ]]
		then
			eval $ssa"a[a1]=$disk"
		fi
		
		if [[ -n $b1 ]] && [[ $b1 != - ]]
		then
			eval $ssa"b[b1]=$disk"
		fi
	done	
done



	
	

for ssa in ${listessa[*]}
do
	echo "<a href=#$ssa>SSA ADAPTER:$ssa</a>">>$TBODY
done

for ssa in ${listessa[*]}
do
	
	eval 'longueura=${#'$ssa'a[*]}'
	eval 'longueurb=${#'$ssa'b[*]}'
	if (( longueura !=0 )) || (( longueurb !=0 ))
	then
		echo "<a name=$ssa>SSA ADAPTER:$ssa</a>">>$TBODY
	fi

	compteur=0
	if (( longueura !=0 ))
	then
		echo "<h3>Loop A</h3>">>$TBODY
		echo "<a href=#ssaloop>index</a><br>">>$TBODY
		echo "<a href=#head>head</a><br>">>$TBODY
	fi

	echo "<table border=1>">>$TBODY
	while (( compteur<longueura ))
	do
		eval 'temp=$'$ssa'a[compteur]'
		if [[ -n $temp ]]
		then
		echo "<td><center>$compteur</center></td>">>$TBODY
		fi
		(( compteur+=1 ))
	done
	
	echo "<tr>">>$TBODY
	
	eval 'set -A temp ${'$ssa'a[*]}'
	for disque in ${temp[*]}
	do
		echo "<td><center>$disque</center></td>">>$TBODY
	done
	echo "</table>">>$TBODY
	echo "">>$TBODY

	compteur=0
	if (( longueurb !=0 ))
	then
		echo "<h3>Loop B</h3>">>$TBODY
		echo "<a href=#ssaloop>index</a><br>">>$TBODY
		echo "<a href=#head>head</a><br>">>$TBODY
	fi

	echo "<table border=1>">>$TBODY
	while (( compteur<longueurb ))
	do
		eval 'temp=$'$ssa'b[compteur]'
		if [[ -n $temp ]]
		then
		echo "<td><center>$compteur</center></td>">>$TBODY
		fi
		(( compteur+=1 ))
	done
	
	echo "<tr>">>$TBODY
	
	unset temp	
	eval 'set -A temp ${'$ssa'b[*]}'
	for disque in ${temp[*]}
	do
		echo "<td><center>$disque</center></td>">>$TBODY
	done
	echo "</table>">>$TBODY
	
	
	
done
	
close

	rm -f ${TINDEX} ${TBODY} ${TIDIOT}
	rm *.tmp.*
