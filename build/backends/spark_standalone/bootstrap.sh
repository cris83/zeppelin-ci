#!/bin/bash
set -e
BUILDSTEP_TIMEOUT=3600			#<- sec
BUILDSTEP_DIR=/buildstep
BUILDSTEP_ZEP=zeppelin.bs
BUILDSTEP_BAK=backend.bs


# ----------------------------------------------------------------------
# Init
# ----------------------------------------------------------------------
/buildstep.sh init $BUILDSTEP_DIR $BUILDSTEP_TIMEOUT
/buildstep.sh log $BUILDSTEP_BAK "Start, backend build..."


# ----------------------------------------------------------------------
# Setup spark 
# ----------------------------------------------------------------------
export SPARK_MASTER_PORT=7077
export SPARK_LOCAL_IP=`awk 'NR==1 {print $1}' /etc/hosts`

sed '1d' /etc/hosts > /tmp/hosts
cat /tmp/hosts > /etc/hosts
rm /tmp/hosts
echo "$SPARK_LOCAL_IP `hostname`" >> /etc/hosts


# ----------------------------------------------------------------------
# Run spark (start & stop)
# ----------------------------------------------------------------------
IFS=' ' read -r -a SPARK_VERSIONS <<< "$SPARK_VERSION_ARRAY"
for i in "${SPARK_VERSIONS[@]}"
do
	# set spark env
	SPARK_VERSION=$i
	export SPARK_HOME="/usr/local/spark$SPARK_VERSION"
	cd /usr/local/spark$SPARK_VERSION/sbin

	##### Build Step 1
	/buildstep.sh waitfor $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : started build spark $SPARK_VERSION"
	/buildstep.sh log $BUILDSTEP_BAK "- $BUILDSTEP_BAK : started backend spark $SPARK_VERSION"

	# starting
	./start-master.sh

	set +e
	echo $SPARK_VERSION | grep "^1.[123].[0-9]" > /dev/null
	let ret=$?
	
	set -e
	if [ $ret -eq 0 ]; then   # spark 1.3 or prior
		./start-slave.sh 1 `hostname`:$SPARK_MASTER_PORT
	else
		./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT
	fi

	##### Build Step 2
	/buildstep.sh log $BUILDSTEP_BAK "- $BUILDSTEP_BAK : wait for zeppelin - spark_standalone $SPARK_VERSION"
	/buildstep.sh waitfor $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : finished build spark $SPARK_VERSION"

	# stopping
	./spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1
	./stop-slave.sh

	##### Build Step 3
	/buildstep.sh log $BUILDSTEP_BAK "- $BUILDSTEP_BAK : closed backend spark $SPARK_VERSION"
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
