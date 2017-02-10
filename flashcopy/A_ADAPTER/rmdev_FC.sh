#!/bin/ksh

. ./liste_vgdisk.sh

export RETURN_CODE=

return_code () {
        RETURN_CODE=$?
        [ $RETURN_CODE -eq 0 ] && echo '> [ OK ]'  \
        || echo '> [ FAILED ]'
}

find_hdisk () {
        DS_LUNID=$1
        pcmpath query essmap | awk '$5~LUNID { DISK=$1 } END { print DISK }' LUNID=${DS_LUNID}\$
}

for VGDISK in `echo $LISTE_VGDISK` ; do

        VGNAME=`echo $VGDISK | cut -d, -f1`
        LUNID=`echo $VGDISK | cut -d, -f2`
        DISK=`find_hdisk $LUNID`

        echo ""
        echo "-[ $VGNAME ]-"

        echo "Lun $LUNID => $DISK"

        # rmdev
        echo "rmdev of the $DISK (LUNID=$LUNIDn VG=$VGNAME)"
        rmdev -Rdl $DISK
	return_code

done

echo ""
echo "Done !"
echo
for i in `lsdev -Cc disk | grep 2107 | awk '{print $1}'`
do
echo "$i -> \c"
lscfg -vpl $i | grep Serial
done
