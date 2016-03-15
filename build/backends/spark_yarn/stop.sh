#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
SPARK_SHARE=/reposhare/$BUILD_TYPE

# ----------------------------------------------------------------------
# Stopping Backend
# ----------------------------------------------------------------------
SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER
export SPARK_HOME="$SPARK_SHARE/$SPARK_DAT"
cd $SPARK_HOME/sbin

# stopping
./spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1
./stop-master.sh

: ${HADOOP_PREFIX:=/usr/local/hadoop}
##$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# stopping hadoop
$HADOOP_PREFIX/sbin/stop-dfs.sh
$HADOOP_PREFIX/sbin/stop-yarn.sh

# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
