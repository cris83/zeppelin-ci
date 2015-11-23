#!/bin/bash

export SPARK_PROFILE 1.4
export SPARK_VERSION 1.4.0
export HADOOP_PROFILE 2.3
export HADOOP_VERSION 2.3.0

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any 
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# setting spark defaults
echo spark.yarn.jar hdfs:///spark/spark-assembly-$SPARK_VERSION-hadoop$HADOOP_VERSION.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

# run spark 
export SPARK_LOCAL_IP=`awk 'NR==1 {print $1}' /etc/hosts`
sed '1d' /etc/hosts > /tmp/hosts
cat /tmp/hosts > /etc/hosts
rm /tmp/hosts
echo "$SPARK_LOCAL_IP `hostname`" >> /etc/hosts

# start hdfs
service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

# 
$HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE/lib /spark

#export SPARK_MASTER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002
#  -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004
#  -Dspark.blockManager.port=7005 -Dspark.executor.port=7006
#  -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
#export SPARK_WORKER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002
#  -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004
#  -Dspark.blockManager.port=7005 -Dspark.executor.port=7006
#  -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"

export SPARK_MASTER_PORT=7077

cd /usr/local/spark-1.4.0-bin-hadoop2.3/sbin
./start-master.sh -i $SPARK_LOCAL_IP
./start-slave.sh spark://$SPARK_LOCAL_IP:$SPARK_MASTER_PORT

CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
	service sshd stop
	/usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi
