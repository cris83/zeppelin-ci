#!/bin/bash
set -e
source $1
REPO_HOME=$2

# ---------------------------------------------------------------------
# Get Spark
# ---------------------------------------------------------------------
IFS=' ' read -r -a SPARK_BIN_ARR <<< "$SPARK_VERSION"
echo "@ Download spark : $REPO_HOME"
for i in "${SPARK_BIN_ARR[@]}"
do
	SPARK_VER=$i
	SPARK_BIN=spark-$SPARK_VER-bin-hadoop$HADOOP_PROFILE.tgz

	if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
		echo " - Doesn't exist -> Downloading spark : $REPO_HOME/$SPARK_BIN"
		echo ""
		wget -P $REPO_HOME http://mirror.tcpdiag.net/apache/spark/spark-$SPARK_VER/$SPARK_BIN
	else
		echo " - Already exist : $SPARK_BIN"
	fi
done


# ---------------------------------------------------------------------
# Get Firefox
# ---------------------------------------------------------------------
FIREFOX_BIN=firefox-31.0.tar.bz2
echo "@ Download firefox : $REPO_HOME/$FIREFOX_BIN"
if [ ! -f $REPO_HOME/$FIREFOX_BIN ]; then
	echo " - Doesn't exist -> Downloading firefox : $REPO_HOME/$FIREFOX_BIN"
	echo ""
	wget -P $REPO_HOME http://ftp.mozilla.org/pub/firefox/releases/31.0/linux-x86_64/en-US/$FIREFOX_BIN
else
	echo " - Already exist : $FIREFOX_BIN"
fi


# ---------------------------------------------------------------------
# Get Maven
# ---------------------------------------------------------------------
MAVEN_BIN=apache-maven-3.3.3-bin.tar.gz
echo "@ Download maven : $REPO_HOME/$MAVEN_BIN"
if [ ! -f $REPO_HOME/$MAVEN_BIN ]; then
	echo " - Doesn't exist -> Downloading maven : $REPO_HOME/$MAVEN_BIN"
	echo ""
	wget -P $REPO_HOME http://archive.apache.org/dist/maven/maven-3/3.3.3/binaries/$MAVEN_BIN
else
	echo " - Already exist : $MAVEN_BIN"
fi


# -------------------------------------------------------------------
# Get Hadoop
# -------------------------------------------------------------------
if [ $item = "spark_yarn" ]; then
    echo "@ Download Hadoop : $REPO_HOME"
    HADOOP_BIN=hadoop-$HADOOP_VERSION.tar.gz
    if [ ! -f $REPO_HOME/$HADOOP_BIN ]; then
        echo " - Doesn't exist -> Downloading hadoop : $REPO_HOME/$HADOOP_BIN"
        echo ""
        wget -P $REPO_HOME https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/$H
    else
        echo " - Already exist : $HADOOP_BIN"
    fi
fi


# ---------------------------------------------------------------------
# End of Script
# ---------------------------------------------------------------------
