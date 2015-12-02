#!/bin/bash
set -e
BUILDSTEP_TIMEOUT=3600          #<- sec
BUILDSTEP_DIR=/buildstep
BUILDSTEP_ZEP=zeppelin.bs
BUILDSTEP_BAK=backend.bs


# ----------------------------------------------------------------------
# Init
# ----------------------------------------------------------------------
export SPARK_PROFILE 1.4
export SPARK_VERSION 1.4.0
export HADOOP_PROFILE 2.3
export HADOOP_VERSION 2.3.0

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any 
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -


# ----------------------------------------------------------------------
# Setup spark ( deafults )
# ----------------------------------------------------------------------
echo spark.yarn.jar hdfs:///spark/spark-assembly-$SPARK_VERSION-hadoop$HADOOP_VERSION.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

export SPARK_MASTER_PORT=7077
export SPARK_LOCAL_IP=`awk 'NR==1 {print $1}' /etc/hosts`
sed '1d' /etc/hosts > /tmp/hosts
cat /tmp/hosts > /etc/hosts
rm /tmp/hosts
echo "$SPARK_LOCAL_IP `hostname`" >> /etc/hosts


# ----------------------------------------------------------------------
# Start hdfs
# ----------------------------------------------------------------------
service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE/lib /spark


# ----------------------------------------------------------------------
# - Run spark 
# - Desc : starting and stopping is executed with Buildstep.
# ----------------------------------------------------------------------
#cd /usr/local/spark-1.4.0-bin-hadoop2.3/sbin
#./start-master.sh -i $SPARK_LOCAL_IP
#./start-slave.sh spark://$SPARK_LOCAL_IP:$SPARK_MASTER_PORT

IFS=' ' read -r -a SPARK_VERSIONS <<< "$SPARK_VERSION_ARRAY"
for i in "${SPARK_VERSIONS[@]}"
do
    # set spark env
    SPARK_VERSION=$i
    SPARK_HOME="/usr/local/spark$SPARK_VERSION/sbin"
    cd /usr/local/spark$SPARK_VERSION/sbin

    ##### Build Step 1
	/buildstep.sh waitfor $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : started build spark $SPARK_VERSION"
    /buildstep.sh log $BUILDSTEP_BAK "- Buildstep : started backend spark $SPARK_VERSION"

    # starting
    ./start-master.sh
    echo $SPARK_VERSION | grep "^1.[123].[0-9]" > /dev/null
    if [ $? -eq 0 ]; then   # spark 1.3 or prior
        ./start-slave.sh 1 `hostname`:$SPARK_MASTER_PORT
    else
        ./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT
    fi

    ##### Build Step 2
    /buildstep.sh log $BUILDSTEP_BAK "- Buildstep : wait for zeppelin - spark_yarn $SPARK_VERSION"
    /buildstep.sh waitfor $BUILDSTEP_ZEP "- Buildstep : finished build spark_yarn - spark $SPARK_VERSION"

    # stopping
    ./spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1
    ./stop-slave.sh

    ##### Build Step 3
    /buildstep.sh log $BUILDSTEP_BAK "- Buildstep : closed backend spark_yarn - spark $SPARK_VERSION"
done


# ----------------------------------------------------------------------
# Tail
# ----------------------------------------------------------------------
CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
	service sshd stop
	/usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
