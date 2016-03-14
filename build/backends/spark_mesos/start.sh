#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
SPARK_SHARE=/reposhare/$BUILD_TYPE

# ----------------------------------------------------------------------
# starting mesos
# ----------------------------------------------------------------------
function run_mesos
{
	mesos-master --ip=0.0.0.0 --work_dir=/var/lib/mesos & > /dev/null
	mesos-slave --master=0.0.0.0:5050 --launcher=posix & > /dev/null
	echo "1" > /current_mesos
}

if [ ! -f /current_mesos ]; then
	run_mesos
fi


# ----------------------------------------------------------------------
# Setup spark & firefox
# ----------------------------------------------------------------------
SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=7072
export SPARK_WORKER_WEBUI_PORT=8082
export SPARK_LOCAL_IP=`awk 'NR==1 {print $1}' /etc/hosts`
export SPARK_HOME="$SPARK_SHARE/$SPARK_DAT"

## reset hosts
if [ ! -f /tmp/hosts ]; then
    sed '1d' /etc/hosts > /tmp/hosts
    cat /tmp/hosts > /etc/hosts
    rm /tmp/hosts
    echo "$SPARK_LOCAL_IP `hostname`" >> /etc/hosts
fi


# ----------------------------------------------------------------------
# Run spark (start & stop)
# ----------------------------------------------------------------------
# create PID dir. test case detect pid file so they can select active spark home dir for test
mkdir -p ${SPARK_HOME}/run
export SPARK_PID_DIR=${SPARK_HOME}/run
cd $SPARK_HOME/sbin

cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
echo "export MESOS_NATIVE_JAVA_LIBRARY=/usr/lib/libmesos.so" >> $SPARK_HOME/conf/spark-env.sh

cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
echo "spark.master mesos://`hostname`:5050" >> $SPARK_HOME/conf/spark-defaults.conf
echo "spark.mesos.executor.home /usr/local/spark" >> $SPARK_HOME/conf/spark-defaults.conf

##### starting
./start-master.sh

set +e
echo $SPARK_VER | grep "^1.[123].[0-9]" > /dev/null
let ret=$?

set -e
if [ $ret -eq 0 ]; then   # spark 1.3 or prior
	./start-slave.sh 1 `hostname`:$SPARK_MASTER_PORT
else
	./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT
fi


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
