#!/bin/bash

source .variable
OPERATION=$1 #add, delete
DOMAIN=$2
TTL=$3
TYPE=$4
DATA=$5

## Functions
check_fqdn(){
## Check for valid FQDN
REGEX='^[a-z0-9.-]{1,255}\.[a-z][a-z0-9-]{1,62}[a-z]\.[a-z]{2,10}$'
if [[ ! ${DOMAIN} =~ ${REGEX} ]]; then
    echo "Invalid domain format."
    exit
fi
}

check_add(){
## Check for valid TTL
if [ -z ${TTL} ] || [ ${TTL} -lt 60 ] || [ ${TTL} -gt 86400 ]; then
    echo "Invalid TTL.  Valid ranges are between 60 - 86400"
    exit
fi

## Check for valid Type
if [ -z ${TYPE} ]; then
    echo "Invalid type.  Valid types are A, AAAA, CNAME, & TXT"
    exit
elif !([ ${TYPE} == "A" ] || [ ${TYPE} == "AAAA" ] || [ ${TYPE} == "CNAME" ] || [ ${TYPE} == "TXT" ]); then
    echo "Invalid type.  Valid types are A, AAAA, CNAME, & TXT"
    exit
fi

## Check for data
if [ -z ${DATA} ]; then
    echo "Invalid data."
    exit
fi
}

## Check operation
if [ -z ${OPERATION} ]; then
    echo "Usage: ./update.sh <add|delete> <DOMAIN> <TTL> <TYPE> <DATA>"
    echo "  Example: ./update.sh add host.test.local 1800 A 1.2.3.4"
    exit
elif [ ${OPERATION} != "add" ] && [ ${OPERATION} != "delete" ]; then
    echo "Invalid operation.  Only 'add' and 'delete' are valid."
    exit
elif [ ${OPERATION} == "add" ]; then
    check_fqdn
    check_add
elif [ ${OPERATION} == "delete" ]; then
    check_fqdn
fi




echo "
server ${SERVER}
update ${OPERATION} ${DOMAIN} ${TTL} ${TYPE} ${DATA}
send
" | nsupdate -k ${KEY}

dig @${SERVER} ${DOMAIN} ${TYPE}