#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
SPARK_SHARE=/reposhare/$BUILD_TYPE


# ----------------------------------------------------------------------
# - Setup hadoop ( deafults )
# ----------------------------------------------------------------------
function setup_hadoop
{
	REPOSHARE_HADOOP="/reposhare/hadoop/hadoop-${HADOOP_VER}.0"
	echo "# hadoop : $REPOSHARE_HADOOP"
	if [ ! -d ${REPOSHARE_HADOOP} ]; then
		HPATH=/reposhare/hadoop
		mkdir -p $HPATH
		tar xfz /reposhare/hadoop/hadoop-${HADOOP_VER}.0.tar.gz -C $HPATH
	fi

	if [ -L /usr/local/hadoop ]; then
		rm -f /usr/local/hadoop
	fi
	ln -s ${REPOSHARE_HADOOP} /usr/local/hadoop
	: ${HADOOP_PREFIX:=/usr/local/hadoop}

	sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
	sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

	mkdir -p $HADOOP_PREFIX/input
	\cp -f $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

	# add config
	\cp -f /tmp/core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml
	\cp -f /tmp/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
	\cp -f /tmp/mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
	\cp -f /tmp/yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

	# format of hdfs
	mkdir -p /data/
	chmod 777 /data/
	$HADOOP_PREFIX/bin/hdfs namenode -format

	chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh

	$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

	# installing libraries if any 
	cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

	echo ${HADOOP_VER} > /current_hadoop
}

if [ ! -f /current_hadoop ]; then
	setup_hadoop
fi

if [ `cat /current_hadoop` = ${HADOOP_VER} ]; then
	echo ""
else
	echo "# current hadoop version : ${HADOOP_VER}"
	setup_hadoop
fi


# ----------------------------------------------------------------------
# - Setup spark for yarn
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
# - Run backend
# ----------------------------------------------------------------------
# create PID dir. test case detect pid file so they can select active spark home dir for test
mkdir -p ${SPARK_HOME}/run
export SPARK_PID_DIR=${SPARK_HOME}/run
cd $SPARK_HOME/sbin

# starting hadoop
echo spark.yarn.jar hdfs:///spark/spark-assembly-$SPARK_VER-hadoop$HADOOP_VERSION.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-$SPARK_VER-bin-hadoop$HADOOP_VER/lib /spark

# starting spark
./start-master.sh -i $SPARK_LOCAL_IP


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
