#!/bin/bash

rm /tmp/*.pid

# run spark 
export SPARK_LOCAL_IP=`awk 'NR==1 {print $1}' /etc/hosts`
sed '1d' /etc/hosts > /tmp/hosts
cat /tmp/hosts > /etc/hosts
rm /tmp/hosts
echo "$SPARK_LOCAL_IP `hostname`" >> /etc/hosts

export SPARK_MASTER_PORT=7077
cd /usr/local/spark/sbin
./start-master.sh
./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT

CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
	service sshd stop
	/usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi
