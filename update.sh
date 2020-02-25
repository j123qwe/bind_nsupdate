#!/bin/bash

#$$ Variables
source .variable
OPERATION=$1
DOMAIN=$2
TTL=$3
TYPE=$4
DATA=$5

#$$ Functions
check_fqdn(){
## Check for valid FQDN
REGEX='^[a-zA-Z0-9.-]{1,255}\.[a-zA-Z][a-zA-Z0-9-]{1,62}[a-zA-Z]\.[a-zA-Z]{2,10}$'
if [[ ! ${DOMAIN} =~ ${REGEX} ]]; then
    echo "Invalid domain format."
    exit
fi
}

check_add(){
## Check for valid TTL
if [ -z ${TTL} ] || [ ${TTL} -lt 60 ] || [ ${TTL} -gt 86400 ]; then
    echo "Invalid TTL.  Valid ranges are between 60 - 86400"
    exit 1
fi

#** Check server
if [ -z ${SERVER} ]; then
	echo "No server IP specified.  Please populate .variable file."
	exit 1
fi

#** Check key file
if [ ! -f ${KEY} ]; then
	echo "No security key specificed.  Please populate .variable file."
	exit 1
fi

#** Check for valid Type
if [ -z ${TYPE} ]; then
    echo "Invalid type.  Valid types are A, AAAA, CNAME, & TXT"
    exit
elif !([ ${TYPE} == "A" ] || [ ${TYPE} == "AAAA" ] || [ ${TYPE} == "CNAME" ] || [ ${TYPE} == "TXT" ]); then
    echo "Invalid type.  Valid types are A, AAAA, CNAME, & TXT"
    exit 1
fi

#** Check for data
if [ -z ${DATA} ]; then
    echo "Invalid data."
    exit 1
fi
}

#** Check operation
if [ -z ${OPERATION} ]; then
    echo "Usage: ./update.sh <add|delete> <DOMAIN> <TTL> <TYPE> <DATA>"
    echo "  Example: ./update.sh add host.test.local 1800 A 1.2.3.4"
    exit 1
elif [ ${OPERATION} != "add" ] && [ ${OPERATION} != "delete" ]; then
    echo "Invalid operation.  Only 'add' and 'delete' are valid."
    exit 1
elif [ ${OPERATION} == "add" ]; then
    check_fqdn
    check_add
elif [ ${OPERATION} == "delete" ]; then
    check_fqdn
fi


#** Submit request
echo "
server ${SERVER}
update ${OPERATION} ${DOMAIN} ${TTL} ${TYPE} ${DATA}
send
" | nsupdate -k ${KEY}

#** Query server
dig @${SERVER} ${DOMAIN} ${TYPE}
