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

        # importvg
        echo "Importing VG $VGNAME with $DISK"
        lsvg | grep $VGNAME > /dev/null
        if [ $? -ne 0 ] ; then
                importvg -y $VGNAME $DISK
                return_code
                [ $RETURN_CODE -ne 0 ] && exit 1
        else
                echo "Volume Group $VGNAME is already Active"

        fi

        # mount FS with "mount group"=vgname
        #echo ""
        #echo "mount -t $VGNAME"
        #mount -t $VGNAME
        #return_code
        #[ $RETURN_CODE -ne 0 ] && exit 1

        #echo ""
done

echo ""
echo "Done !"
echo ""
echo "lsvg -o"
echo "======="
lsvg
echo
