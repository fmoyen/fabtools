#!/bin/ksh

echo "lspv"
echo "===="
lspv
echo

for i in `lsvg | grep FC`
do
   echo "$i ... \c"

   exportvg $i
   if [ $? -ne 0 ]
   then
     echo
     echo PROBLEM WHILE EXPORTVG $i
     echo EXITING
     echo
     exit 2
   fi

   echo "done"
done

echo
echo "lspv"
echo "===="
lspv
