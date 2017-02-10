#!/bin/sh
# \
exec expect -f "$0" ${1+"$@"}
set FILE [lindex $argv 0]
set host [lindex $argv 0]
#set password [lindex $argv 2]
#set prompt [lindex $argv 3]
#set port [lindex $argv 4]

#set host 10.3.31.61
set port 22
set prompt root

spawn ssh -o VerifyHostKeyDNS=no -o UserKnownHostsFile=/dev/null  -o CheckHostIP=no -o StrictHostkeyChecking=no -p $port $host
expect "password"
send "p&i7up19\r"
expect "root"
send "passwd\r"
expect "Changing"
send "ibm4amdocs\r"
expect "again"
send "ibm4amdocs\r"
expect "root"
send "exit\r"
expect eof
