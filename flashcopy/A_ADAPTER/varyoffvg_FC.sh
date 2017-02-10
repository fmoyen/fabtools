#!/bin/ksh

echo "lsvg -o"
echo "======="
lsvg -o 
echo

for i in `lsvg -o | grep FC`
do
   echo "$i ... \c"

   varyoffvg $i
   if [ $? -ne 0 ]
   then
     echo
     echo PROBLEM WHILE VARYOFFVG $i
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
