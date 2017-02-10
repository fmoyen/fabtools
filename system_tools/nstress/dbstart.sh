echo starting database
export DIR=.
export TIME=6000
export LOG1=/db/log/logfile1
export LOG2=/db/log/logfile2
export DATA1=/db/data1/system.dbf
export DATA2=/db/data1/index.dbf
export DATA3=/db/data1/tables.dbf
export DATA4=/db/data2/rollback.dbf
export DATA5=/db/data1/tables2.dbf

echo starting logging servers
$DIR/nlog -k 1 -s 1 -m $TIME 2>$LOG1 -o "db -log1" >/dev/null &
echo kill -9 $! >>nzap

echo starting db servers
$DIR/ncpu -p 4 -z 95 -s $TIME -o "db -client5" >/dev/null &

echo starting cache
$DIR/nmem -m 64 -z 80 -s $TIME -o "db -mgr1" >/dev/null &
echo kill -9 $! >>nzap

$DIR/nmem -m 64 -z 90 -s $TIME -o "db -mgr4" >/dev/null &
echo kill -9 $! >>nzap

$DIR/nmem -m 64 -z 95 -s $TIME -o "db -mgr5" >/dev/null &
echo kill -9 $! >>nzap


echo create the database
for disk in $DATA1 $DATA2 $DATA3 $DATA4 $DATA5
do
        if [ -f $disk ]
        then
                echo $disk exists
        else
                echo $disk creating
                $DIR/ndisk -C 32  -f $disk >/dev/null
                echo kill -9 $! >>nzap
        fi
done

echo starting disks
$DIR/ndisk -R -r 20 -b 4k -z 80 -t $TIME -f $DATA1 -o "db -dmg1" >//dev/null &
                echo kill -9 $! >>nzap
$DIR/ndisk -R -r 20 -b 8k -z 90 -t $TIME -f $DATA4 -o "db -dmg4" >//dev/null &
                echo kill -9 $! >>nzap
$DIR/ndisk -R -r 90 -b 8k -z 95 -t $TIME -f $DATA5 -o "db -dmg5" >//dev/null &
                echo kill -9 $! >>nzap

echo database running

