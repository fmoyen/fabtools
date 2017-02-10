#!/bin/ksh

echo "lsvg -o"
echo "======="
lsvg -o 
echo

for i in `lsvg | grep FC`
do
   echo "$i ... \c"

   varyonvg $i
   if [ $? -ne 0 ]
   then
     echo
     echo PROBLEM WHILE VARYONVG $i
     echo EXITING
     echo
     exit 1
   fi
   echo "done"
done

echo
echo "lsvg -o"
echo "======="
lsvg -o
