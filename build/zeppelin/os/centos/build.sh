#!/bin/bash
set -e
echo "# Script version : 0.3"
echo "# ZCI-ENV File   : $ZCI_ENV"
source /reposhare/$ZCI_ENV

SPARK_SHARE=/reposhare/$BUILD_TYPE
USER_HOME=/reposhare/users/$CONT_NAME
ZEPPELIN_HOME=$USER_HOME/zeppelin

# ----------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------
function spark_conf		#<- only spark_yarn
{
	home=$1

	if [[ $BUILD_TYPE == "spark_yarn" ]]; then
		echo "- copy spakr conf ."
		\cp -f /tmp/spark_conf/*  $home/conf/
	fi
}

function build_all_modules
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	PROFILE="-Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding"
	BUILD_FLAG="package -Pbuild-distr"
	TEST_FLAG="verify -Drat.skip=true -Pusing-packaged-distr"

	mvn $BUILD_FLAG $PROFILE -B

	\cp -f /tmp/zeppelin-env.sh $ZEPPELIN_HOME/conf/
    echo "export SPARK_HOME=$SPARK_SHARE/$SPARK_DAT" >> $ZEPPELIN_HOME/conf/zeppelin-env.sh
	spark_conf "$SPARK_SHARE/$SPARK_DAT"

	mvn $TEST_FLAG $PROFILE -B
}

function build_spark_module
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	PROFILE="-Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark"
	BUILD_FLAG="package -DskipTests"
	TEST_FLAG="verify -Drat.skip=true"

	mvn $BUILD_FLAG $PROFILE -B

	\cp -f /tmp/zeppelin-env.sh $ZEPPELIN_HOME/conf/
    echo "export SPARK_HOME=$SPARK_SHARE/$SPARK_DAT" >> $ZEPPELIN_HOME/conf/zeppelin-env.sh
	spark_conf "$SPARK_SHARE/$SPARK_DAT"

	mvn $TEST_FLAG $PROFILE -B
}


# ----------------------------------------------------------------------
# Init
# ----------------------------------------------------------------------
BUILDSTEP_TIMEOUT=300
BUILDSTEP_DIR=/reposhare/buildstep/$BUILD_TYPE
BUILDSTEP_ZEP=${CONT_NAME}_zeppelin.bs
BUILDSTEP_BAK=${CONT_NAME}_backend.bs

/buildstep.sh init $BUILDSTEP_DIR $BUILDSTEP_TIMEOUT
/buildstep.sh log $BUILDSTEP_ZEP "# Start, zeppelin build ..."

# firefox 
ln -s /reposhare/firefox/firefox /usr/bin/firefox


# ----------------------------------------------------------------------
# Open XVFB
# ----------------------------------------------------------------------
/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : Info, Launch a XVFB session on display"
/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : Info, DISPLAY PORT = $DISPLAY"
dbus-uuidgen > /var/lib/dbus/machine-id
Xvfb $DISPLAY -ac -screen 0 1280x1024x24 &


# ----------------------------------------------------------------------
# Move to Zeppelin
# ----------------------------------------------------------------------
cd $ZEPPELIN_HOME


# ----------------------------------------------------------------------
# Build Script
# ----------------------------------------------------------------------
arg_num=0
IFS=' '
read -r -a SPARK_VERSIONS <<< "$SPARK_VERSION"
for i in "${SPARK_VERSIONS[@]}"
do
	SPARK_VERSION=$i
	SPARK_PROFILE=${SPARK_VERSION%.*}
	HADOOP_PROFILE=${HADOOP_VERSION%.*}

	##### Build Step 1
	/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : started $BUILD_TYPE build spark $SPARK_VERSION"

	##### Build Step 2
	if [[ $arg_num == 0 ]]; then
		build_all_modules $SPARK_VERSION $SPARK_PROFILE $HADOOP_PROFILE
	else
		build_spark_module $SPARK_VERSION $SPARK_PROFILE $HADOOP_PROFILE
	fi
	let "arg_num+=1"

	##### Build Step 3
	/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : finished $BUILD_TYPE build spark $SPARK_VERSION"
	/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : wait for backend - spark $SPARK_VERSION"
	/buildstep.sh waitfor $BUILDSTEP_BAK "- $BUILDSTEP_BAK : closed $BUILD_TYPE backend spark $SPARK_VERSION"
done
echo "Done!"


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
