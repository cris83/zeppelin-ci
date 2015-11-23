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
FIREFOX_BIN=firefox-31.0.tar.bz2
MAVEN_BIN=apache-maven-3.3.3-bin.tar.gz

echo " @ download spark : $REPO_HOME/$SPARK_BIN"
echo " @ download firefox : $REPO_HOME/$FIREFOX_BIN"
echo " @ download maven : $REPO_HOME/$MAVEN_BIN"

if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
	echo " # Doesn't exist spark."; echo""
	wget -P $REPO_HOME http://mirror.tcpdiag.net/apache/spark/spark-$SPARK_VERSION/$SPARK_BIN
fi

if [ ! -f $REPO_HOME/$FIREFOX_BIN ]; then
	echo " # Doesn't exist firefox."; echo""
	wget -P $REPO_HOME http://ftp.mozilla.org/pub/firefox/releases/31.0/linux-x86_64/en-US/$FIREFOX_BIN
fi

if [ ! -f $REPO_HOME/$MAVEN_BIN ]; then
	echo " # Doesn't exist maven."; echo""
	wget -P $REPO_HOME http://archive.apache.org/dist/maven/maven-3/3.3.3/binaries/$MAVEN_BIN
fi
