#!/bin/sh
# \
exec expect -f "$0" ${1+"$@"}
set FILE [lindex $argv 0]
set host [lindex $argv 1]
set password [lindex $argv 2]
set prompt [lindex $argv 3]
set port [lindex $argv 4]

spawn scp -o VerifyHostKeyDNS=no -o UserKnownHostsFile=/dev/null  -o CheckHostIP=no -o StrictHostkeyChecking=no -P $port $FILE $host:./myid_rsa.pub
expect "assword:"
send "$password\r"
expect eof

spawn ssh -o VerifyHostKeyDNS=no -o UserKnownHostsFile=/dev/null  -o CheckHostIP=no -o StrictHostkeyChecking=no -p $port $host
expect "assword:"
send "$password\r"
expect "$prompt"
send "mkdir -m 600 .ssh\r"
expect "$prompt"
send "cat ./myid_rsa.pub >> .ssh/authorized_keys\r"
expect "$prompt"
send "chmod 600 .ssh/authorized_keys\r"
expect "$prompt"
send "rm -f ./myid_rsa.pub\r"
expect "$prompt"
send "exit\r"
expect eof
