#!/bin/bash

## Author: @pablokbs on github
## fredrikson.com.ar
##
## Bash script that connects to twilio's api service and sends and sms.
## 
## You should place this file on /usr/local/bin and create a new misccomand on Nagios with the following parameters:
## misc command name: notify-host-by-sms
## misc command line: /usr/local/bin/nagios_twilios.sh -c "$CONTACTPAGER$" -b "$NOTIFICATIONTYPE$%0D%0AHost%3A+$HOSTALIAS$%0D%0AHost+Status%3A+$HOSTSTATE$%0D%0AInfo%3A+$HOSTOUTPUT$"
## 
## And the same with another misccomand for the services:
## misc command name: notify-service-by-sms
## misc command line: /usr/local/bin/nagios_twilios.sh -c "$CONTACTPAGER$" -b "$NOTIFICATIONTYPE$%0D%0AHost%3A+$HOSTALIAS$%0D%0AService%3A+$SERVICEDESC$%0D%0AStatus%3A+$SERVICESTATE$"
## 
## You can modify the body of the message if you want.
##
## After that, you should edit your contacts to use this new notification commands, add them besides the defaults "notify-service-by-email" and "notify-host-by-email"
## Also, remember to add a pager number to your contact.cfg, like this:
## --
## define contact {
## 	contact_name John Doe
## 	email test@example.com
##	pager 55512345
## }
## --
##

usage()
{
cat << EOF

usage: $0 [-t] -c CONTACTS -b BODY

This scripts sends an sms notification to one or several contacts

OPTIONS:
 -h Show this message
 -t Don't really send the message, just show the code to be run
 -c Contact's mobile number separated by spaces and between quotes, e.g.: -c "5551111 5551112 5551113"
 -b Body of the sms

EOF
}


PRECONTACTS=""
BODY=""

## Remember to modify this

URL='https://api.twilio.com/2010-04-01/Accounts/_PLEASE_CHANGE_ME_/SMS/Messages.xml'
FROM='From=%2B_PLEASE_INSERT_NUMBER_HERE_'
ACCOUNTSID="_INSERT_ACCOUNTSID_HERE"
AUTHTOKEN="_INSERT_AUTHTOKEN_HERE"

SEND='curl -X POST "$URL" -d "$FROM" -d "To=%2B$CONTACT" -d "Body=Nagios+$BODY" -u "$ACCOUNTSID:$AUTHTOKEN"'


while getopts "h:c:b:t" OPTION
do
	case $OPTION in
		h)
			usage
			exit 1
			;;
		t)	
			echo "The following line will be executed:"
			echo -n ""
			echo $SEND
			;;
		c)	
			PRECONTACTS=$OPTARG
			;;
		b)	
			BODY=$OPTARG
			;;
		?)
			usage
			exit
			;;
	esac
done

if [[ -z $PRECONTACTS ]] || [[ -z $BODY ]]
then
     usage
          exit 1
fi

for CONTACT in ${PRECONTACTS}
do
	curl -X POST "$URL" -d "$FROM" -d "To=%2B$CONTACT" -d "Body=Nagios+$BODY" -u "$ACCOUNTSID:$AUTHTOKEN" &>> /tmp/nagios_sms.log
done
