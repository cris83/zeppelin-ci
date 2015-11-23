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

REPO_HOME=/tmp/build/build/repo
SPARK_VERSION=$1
HADOOP_PROFILE=$2

SPARK_BIN=spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz
FIREFOX_BIN=firefox-31.0.tar.bz2

echo " @ download spark : $REPO_HOME/$SPARK_BIN => $BUILD_PATH/$SPARK_BIN"
echo " @ ======> $BUILD_PATH"

if [ -f $REPO_HOME/$SPARK_BIN ]; then
	cp $REPO_HOME/$SPARK_BIN $BUILD_PATH/
else 
	echo " # Doesn't exist spark."; echo""
	wget -P $BUILD_PATH http://mirror.tcpdiag.net/apache/spark/spark-$SPARK_VERSION/$SPARK_BIN
fi

if [ -f $REPO_HOME/$FIREFOX_BIN ]; then
	cp $REPO_HOME/$FIREFOX_BIN $BUILD_PATH/
else 
	echo " # Doesn't exist firefox."; echo""
	wget -P $BUILD_PATH http://ftp.mozilla.org/pub/firefox/releases/31.0/linux-x86_64/en-US/$FIREFOX_BIN
fi

