echo starting webserver
export DIR=.
export TIME=6000
export LOG1=/web/logfile1
export LOG2=/web/logfile2
export WEB1=/web/webfile

echo starting web loggers 
$DIR/nlog -k 1 -s 1 -m $TIME -o "weblgger" 2>$LOG1 >/dev/null &
echo kill -9 $! >>nzap

echo starting web servers
$DIR/ncpu -p 5 -z 80 -s $TIME -h 5  -o "webserver -c1" >/dev/null &

echo starting cache
$DIR/nmem -m 4 -z 99 -s $TIME  -o "webserver -m3" >/dev/null &
echo kill -9 $! >>nzap
$DIR/nmem -m 4 -z 99 -s $TIME  -o "webserver -m4" >/dev/null &
echo kill -9 $! >>nzap

echo create the webpages
for disk in $WEB1
do
        if [ -f $disk ]
        then
                echo $disk exists
        else
                echo $disk creating
                $DIR/ndisk -C 32  -f $disk  >/dev/null &
                echo kill -9 $! >>nzap
        fi
done

echo starting disks
$DIR/ndisk -M 8 -R -r 99 -b 4k -z 99 -t $TIME -f $WEB1 -o "webserver -d" >/dev/null &
                echo kill -9 $! >>nzap

echo web server running

