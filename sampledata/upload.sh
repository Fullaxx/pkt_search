#!/bin/bash
# Upload ndjson file

PASSWORDFILE="/data/passwords"

if [ "$#" -ne "2" ]; then
  echo "$0: <INDEX> <FILE>"
  exit 1
fi 

if [ -z "${PASS}" ]; then
  echo "Set PASS in the environment!"
  echo "Use ${PASSWORDFILE} to find the password for elastic"
  exit 2
fi

HOST=${HOST:-localhost}
INDEX="$1"
FILE="$2"

if [ ! -r ${FILE} ]; then
  echo "${FILE} is not readable!"
  exit 3
fi

CONVERT=`mktemp`
while read LINE; do
  echo '{"index" : {}}' >>${CONVERT}
  echo ${LINE} >>${CONVERT}
done <${FILE}

curl -k -s -u elastic:${PASS} -XPOST http://${HOST}:9200/${INDEX}/_bulk?pretty\&refresh=true -H "Content-Type: application/x-ndjson" --data-binary @${CONVERT} 2>&1
rm ${CONVERT}
