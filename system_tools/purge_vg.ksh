#!/bin/ksh

echo
echo "key word for volume group selection (not case sensitive) : \c "
read cle

echo
echo "List of filesystems to purge in the following order :"
echo
for i in `lsvg -o | grep -i $cle`
do
  echo $i
  lsvg -l $i | grep jfs2 | awk '{print $7}' | sort -r
  echo
done

echo "TAKE CARE, IF ANSWERING YES TO THE FOLLOWING QUESTION, DELETION WILL OCCURE !!"
echo "Ready ? (y/n) : \c"
read question

if [ $question = "y" ]
then
  echo
  echo "working ..."
  echo
  for i in `lsvg -o | grep -i $cle`
  do
    for j in `lsvg -l $i | grep jfs2 | awk '{print $7}' | sort -r` 
    do
      echo "deleting $j"
      rm -r $j/* > /dev/null 2>&1
      rm -r $j/.[A-z]* > /dev/null 2>&1
      ls -la $j
      umount -f $j
      echo "done"
      echo
    done
  done
  
  for i in `lsvg -o | grep -i $cle`
  do
    echo $i
    lsvg -l $i
    echo
  done

else
  echo
  echo "aborting"
  echo
fi
