#!/bin/bash
set -e

if [ -z $1 ]; then
	echo "# Please, Input hadoop version !"
	exit 1
fi

REPO_HOME=./build/repo
HADOOP_PROFILE=$1

SPARK_BIN_ARR=(1.5.0 1.4.1 1.3.1 1.2.1 1.1.1)
echo " @ download spark : $REPO_HOME/$SPARK_BIN"
for i in "${SPARK_BIN_ARR[@]}"
do
	SPARK_VERSION=$i
	SPARK_BIN=spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz
	if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
		echo " # Doesn't exist spark."; echo""
		wget -P $REPO_HOME http://mirror.tcpdiag.net/apache/spark/spark-$SPARK_VERSION/$SPARK_BIN
	fi
done
