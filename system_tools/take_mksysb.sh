#!/bin/ksh


#-----------------------------------------------------------
# USAGE

SCRIPT=$0

function usage
{
  echo
  echo "usage : $SCRIPT"
  echo "        [-h]   -> displays this help"
  echo "        [-dir <where to store the mksysb>]"
  echo
  echo "        without any parameter, will ask you the directory where to store the mksysb"

  echo
}


#-----------------------------------------------------------
# MAIN PART

OKdir=0

if [ $# -gt 2 ] || [ $# -eq 1 ] 
then
  usage
  exit 1
fi

if [ $# -eq 2 ]
then
  case $1 in
   -h)
     usage
     exit 0
   ;;

   -dir)
     mount_point=$2
     OKdir=1
   ;;

   *)
     usage
     exit 1
   ;;
  esac
fi

if [ $OKdir -eq 0 ]
then
   echo "Give the mount point where to store the mksysb: \c"
   read mount_point
fi

if [ -d $mount_point ]
then
   host=`/usr/bin/hostname`
   timestamp=`date +%Y%m%d`
   file=$host.$timestamp.mksysb

   if [ -f $mount_point/$file ]
   then
      echo "the file $file already exists... Exiting ..."
   else
      /usr/bin/mksysb  '-e'  '-i' '-X'  '-A' $mount_point/$file
      echo
      echo "MKSYSB file : "
      du -sg $mount_point/$(/usr/bin/hostname).*.mksysb 
      du -sg $mount_point
      cd $mount_point; df -gP .
      echo
   fi
else
   echo "the mount point $mount_point does not exist. Please check and retry ... Exiting ..."
   echo
fi

