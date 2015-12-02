#!/bin/bash
set -e
BUILDSTEP_TIMEOUT=300
BUILDSTEP_DIR=/buildstep
BUILDSTEP_ZEP=zeppelin.bs
BUILDSTEP_BAK=backend.bs


# ----------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------
function first_build
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3

	sleep 10 
	echo "first build $SPARK_VER $SPARK_PRO $HADOOP_VER"
	mvn package -DskipTests -Phadoop-${HADOOP_VER} -Ppyspark -B
	mvn package -Pbuild-distr -Phadoop-${HADOOP_VER} -Ppyspark -B
	\cp -f /tmp/zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=/usr/local/spark$SPARK_VER" >> conf/zeppelin-env.sh
	mvn verify -Pusing-packaged-distr -Phadoop-${HADOOP_VER} -Ppyspark -B
}

function etc_build
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3

	sleep 10
	echo "etc build $SPARK_VER $SPARK_PRO $HADOOP_VER"
	mvn package -DskipTests -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -B -pl 'zeppelin-interpreter,spark-dependencies,spark'
	\cp -f /tmp/zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=/usr/local/spark$SPARK_VER" >> conf/zeppelin-env.sh
	mvn package -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -B -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-server' -Dtest=org.apache.zeppelin.rest.*Test -DfailIfNoTests=false
}


# ----------------------------------------------------------------------
# Init
# ----------------------------------------------------------------------
/buildstep.sh init $BUILDSTEP_DIR $BUILDSTEP_TIMEOUT
/buildstep.sh log $BUILDSTEP_ZEP "- Buildstep : Start, zeppelin build..."


# ----------------------------------------------------------------------
# Open XVFB
# ----------------------------------------------------------------------
/buildstep.sh log $BUILDSTEP_ZEP "- Buildstep : Info, Launch a XVFB session on display"
/buildstep.sh log $BUILDSTEP_ZEP "- Buildstep : Info, DISPLAY PORT = $DISPLAY"
dbus-uuidgen > /var/lib/dbus/machine-id
Xvfb $DISPLAY -ac -screen 0 1280x1024x24 &


# ----------------------------------------------------------------------
# Cloning zeppelin
# ----------------------------------------------------------------------
/buildstep.sh log $BUILDSTEP_ZEP "- Buildstep : Info, Cloning zeppelin"
git clone -b $BRANCH $REPO /zeppelin
cd /zeppelin


# ----------------------------------------------------------------------
# Build Script
# ----------------------------------------------------------------------
arg_num=0
IFS=' '
read -r -a SPARK_VERSIONS <<< "$SPARK_VERSION_ARRAY"
read -r -a SPARK_PROFILE <<< "$SPARK_PROFILE_ARRAY"

for i in "${SPARK_VERSIONS[@]}"
do
	SPARK_VERSION=$i

	##### Build Step 1
	/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : started build spark $SPARK_VERSION"

	##### Build Step 2 ( build spark 1.x )
	if [[ $arg_num == 0 ]]; then
		first_build $SPARK_VERSION ${SPARK_PROFILE[$arg_num]} $HADOOP_PROFILE
	else
		etc_build $SPARK_VERSION ${SPARK_PROFILE[$arg_num]} $HADOOP_PROFILE
	fi
	let "arg_num+=1"

	##### Build Step 3
	/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : finished build spark $SPARK_VERSION"
	/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : wait for backend - spark $SPARK_VERSION"
	/buildstep.sh waitfor $BUILDSTEP_BAK "- $BUILDSTEP_BAK : closed backend spark $SPARK_VERSION"
done


# ----------------------------------------------------------------------
echo "Done!"

# End of Script
