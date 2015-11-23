#!/bin/bash
set -e

if [ -z $1 ]; then
	echo "# Please, Input spark version !"
	exit 1
fi

if [ -z $2 ]; then
	echo "# Please, Input hadoop version !"
	exit 1
fi

REPO_HOME=./build/repo
SPARK_VERSION=$1
HADOOP_PROFILE=$2

SPARK_BIN=spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz

echo " @ download spark : $REPO_HOME/$SPARK_BIN"

if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
	echo " # Doesn't exist spark."; echo""
	wget -P $REPO_HOME http://mirror.tcpdiag.net/apache/spark/spark-$SPARK_VERSION/$SPARK_BIN
fi

