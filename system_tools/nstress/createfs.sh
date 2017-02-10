# Create the /db filesystem on two disks/striped

mklv -y'db' -t'jfs' -u'8' -L'db' '-S64K' rootvg 64 hdisk0 hdisk1 
crfs -v jfs -d'db' -m'/db' -Ayes  
mount /db

mkdir -p /db/log
mkdir -p /db/data1
mkdir -p /db/data1
mkdir -p /db/data2

mklv -y'web' -t'jfs' -u'8' -L'web' '-S64K' rootvg 64 hdisk0 hdisk1 
crfs -v jfs -d'web' -m'/db' -Ayes  
mount /web

