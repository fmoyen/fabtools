#!/bin/sh
# \
exec expect -f "$0"

spawn ssh-keygen -t rsa
expect "Enter file in which to save the key"
send "\r"
expect {
	"Overwrite"	{
				
				send "n\r"
				expect eof
				
			}

	"passphrase):"	{

				send "\r"
				expect "again"
				send "\r"
				
			}
}
expect eof	