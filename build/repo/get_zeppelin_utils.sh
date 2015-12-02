#!/bin/bash
set -e

#if [ -z $1 ]; then
#	echo "# Please, Input spark version !"
#	exit 1
#fi

if [ -z $1 ]; then
	echo "# Please, Input hadoop version !"
	exit 1
fi

REPO_HOME=./build/repo
HADOOP_PROFILE=$1

FIREFOX_BIN=firefox-31.0.tar.bz2
MAVEN_BIN=apache-maven-3.3.3-bin.tar.gz

echo " @ download spark : $REPO_HOME/$SPARK_BIN"
echo " @ download firefox : $REPO_HOME/$FIREFOX_BIN"
echo " @ download maven : $REPO_HOME/$MAVEN_BIN"

#if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
#	echo " # Doesn't exist spark."; echo""
#	wget -P $REPO_HOME http://mirror.tcpdiag.net/apache/spark/spark-$SPARK_VERSION/$SPARK_BIN
#fi

#SPARK_BIN_ARR="$1"
SPARK_BIN_ARR=(1.5.0 1.4.1 1.3.1 1.2.1 1.1.1)
for i in "${SPARK_BIN_ARR[@]}"
do
    SPARK_VERSION=$i
    SPARK_BIN=spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz
    if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
        echo " # Doesn't exist spark."; echo""
        wget -P $REPO_HOME http://mirror.tcpdiag.net/apache/spark/spark-$SPARK_VERSION/$SPARK_BIN
    fi
done

if [ ! -f $REPO_HOME/$FIREFOX_BIN ]; then
	echo " # Doesn't exist firefox."; echo""
	wget -P $REPO_HOME http://ftp.mozilla.org/pub/firefox/releases/31.0/linux-x86_64/en-US/$FIREFOX_BIN
fi

if [ ! -f $REPO_HOME/$MAVEN_BIN ]; then
	echo " # Doesn't exist maven."; echo""
	wget -P $REPO_HOME http://archive.apache.org/dist/maven/maven-3/3.3.3/binaries/$MAVEN_BIN
fi
