#!/bin/sh
set -eux
SCRIPTDIR=$(cd $(dirname $0) && pwd)
SERVER_NAME=$1
USERNAME=$2
PASSWORD=$3
DATABASE=$4
sqlcmd -S $SERVER_NAME -U $USERNAME -P $PASSWORD -d $DATABASE -i $SCRIPTDIR/sample.sql
for i in `seq 1 3`
do
	sqlcmd -S $SERVER_NAME -U $USERNAME -P $PASSWORD -d $DATABASE -Q "INSERT INTO UserInfo SELECT * FROM UserInfo;"
done
