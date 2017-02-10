#!/bin/ksh

##############################################
# VARIABLES

VGs="lpar1:data1vg lpar1:log1vg lpar15:data15vg lpar15:log15vg"
ACTIVE_LPARS="N"
CONFIRMATION="no"
DB_2_FLASH=/monitor/FCscripts/scripts_dscli/RESYNC_db_2_flash.dscli
FLASH_2_DB=/monitor/FCscripts/scripts_dscli/RESYNC_flash_2_db.dscli

##############################################
# PROGRAM

if [ `uname -n` != "D-DB-NIM" ]

then
  echo Run this onto dbnim lpar only please !
  echo
  exit 1
else

  echo 
  echo "############################################################"
  echo 
  echo "This script will allow you to restore the DB using the flashcopy"
  echo "or to update the flashcopy using the DB"
  echo 
  echo "############################################################"
  echo 
  echo "checking the status of the DB2 Volume Groups..."

  for i in $VGs
  do
    lpar=`echo $i | awk -F: '{print $1}'`
    vg=`echo $i | awk -F: '{print $2}'`

    echo "    LPAR=$lpar, VG=$vg : \c"

    ssh root@$lpar uname -n > /dev/null 2>&1
    sshOK=`echo $?`
    if [ $sshOK -ne 0 ]
    then
      echo;echo
      echo "CONNECTION ISSUE FOR LPAR $lpar"
      echo "Please correct this and try again ..."
      echo
      exit 2
    fi

    ssh root@$lpar lsvg -o | grep $vg > /dev/null 2>&1
    inactive=`echo $?`
    if [ $inactive -eq 1 ]
    then 
      echo offline 
    else
      echo ONLINE 
      ACTIVE_LPARS="Y" 
    fi
  done

  echo
  if [ $ACTIVE_LPARS = "N" ]
  then
    echo "Good. Let's continue ..."
  else
    echo "SOME VOLUM GROUPS ARE STILL ACTIVE."
    echo "Please correct this and try again"
    echo
  exit 3
  fi
  
  echo
  echo "############################################################"
  echo 
  echo "1) restore the DB using the flashcopy"
  echo "2) update the flashcopy with the DB"
  echo 
  echo "Your choice: \c"
  read choice
  echo
  echo "############################################################"
  echo 

  case $choice in
  
  1)
    echo "your choice is to restore the DB using the flashcopy"
    echo
    echo "ALL DATAS ON YOUR DB WILL BE DESTROYED !!"
    echo
    echo "please confirm [yes|no]: \c"
    read confirmation
    echo
 
    if [ X$confirmation = "Xyes" ]
    then
      echo
      echo "############################################################"
      echo
      echo doing the flashback
      /opt/ibm/dscli/dscli -script $FLASH_2_DB 
    else
      echo
      echo "############################################################"
      echo
      echo "aborting ..."
    fi
  ;;

  2)
    echo "your choice is to update the flashcopy volumes using the DB volumes"
    echo
    echo "THE OLD FLASHCOPY WILL NOT BE AVAILABLE ANYMORE ..."
    echo
    echo "please confirm [yes|no]: \c"
    read confirmation
    echo

    if [ X$confirmation = "Xyes" ]
    then
      echo
      echo "############################################################"
      echo
      echo updating the flashcopy
      /opt/ibm/dscli/dscli -script $DB_2_FLASH 
    else
      echo
      echo "############################################################"
      echo
      echo "aborting ..."
      echo
    fi
  ;;

  *)
  echo "I did not understand your answer"
  echo "aborting ..."
  echo
  ;;

  esac

fi 
