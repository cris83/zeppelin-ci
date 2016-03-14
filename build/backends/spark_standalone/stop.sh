#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
SPARK_SHARE=/reposhare/$BUILD_TYPE

# ----------------------------------------------------------------------
# Stopping spark
# ----------------------------------------------------------------------
SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER
export SPARK_HOME="$SPARK_SHARE/$SPARK_DAT"
cd $SPARK_HOME/sbin

./spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1
./stop-master.sh

# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
