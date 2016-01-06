#!/bin/bash
set -e
SPARK_SHARE=/reposhare/$BUILD_TYPE

echo "# ZCI-ENV FILE : $ZCI_ENV"
source /reposhare/$ZCI_ENV

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

function first_build_only_spark
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	item=$4
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	rm -rf /zeppelin/interpreter/spark
	mvn package -Pbuild-distr -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -B

	\cp -f /tmp/${item}_zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=$SPARK_SHARE/$SPARK_DAT" >> conf/zeppelin-env.sh
	spark_conf "$SPARK_SHARE/$SPARK_DAT"

	sleep 3
	#mvn verify -Drat.skip=true -Pusing-packaged-distr -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -B
}

function first_build
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	mvn package -DskipTests -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding -B
	mvn package -Pbuild-distr -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding -B

	\cp -f /tmp/${item}_zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=$SPARK_SHARE/$SPARK_DAT" >> conf/zeppelin-env.sh

	sleep 3
	#mvn verify -Drat.skip=true -Pusing-packaged-distr -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding -B
}

function skiptests_etc_build
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	rm -rf /zeppelin/interpreter/spark
	mvn package -DskipTests -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -B -pl 'zeppelin-interpreter,spark-dependencies,spark'

	\cp -f /tmp/${item}_zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=$SPARK_SHARE/$SPARK_DAT" >> conf/zeppelin-env.sh
	mvn package -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -B -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-server' -Dtest=org.apache.zeppelin.rest.*Test -DfailIfNoTests=false
}

# only 1.2 and 1.1
function etc_build
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	rm -rf /zeppelin/interpreter/spark
	mvn package -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -B -pl 'zeppelin-interpreter,spark-dependencies,spark'

	\cp -f /tmp/${item}_zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=$SPARK_SHARE/$SPARK_DAT" >> conf/zeppelin-env.sh
	mvn package -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -B -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-server' -Dtest=org.apache.zeppelin.rest.*Test -DfailIfNoTests=false
}


# ----------------------------------------------------------------------
# Init
# ----------------------------------------------------------------------
# firefox 
ln -s /reposhare/firefox/firefox /usr/bin/firefox


# ----------------------------------------------------------------------
# Open XVFB
# ----------------------------------------------------------------------
dbus-uuidgen > /var/lib/dbus/machine-id
Xvfb $DISPLAY -ac -screen 0 1280x1024x24 &


# ----------------------------------------------------------------------
# Cloning zeppelin
# ----------------------------------------------------------------------
git clone -b $BRANCH $REPO /zeppelin
cd /zeppelin


# ----------------------------------------------------------------------
# Build Script
# ----------------------------------------------------------------------
arg_num=0
IFS=' '
items=( spark_standalone spark_mesos spark_yarn )
for item in ${items[@]}
do
	echo "- Set ${item} Buildstep"
	BUILDSTEP_TIMEOUT=300
	BUILDSTEP_DIR=/reposhare/buildstep/$item
	BUILDSTEP_ZEP="${item}_${CONT_NAME}_zeppelin.bs"
	BUILDSTEP_BAK="${item}_${CONT_NAME}_backend.bs"

	/buildstep.sh init $BUILDSTEP_DIR $BUILDSTEP_TIMEOUT
	/buildstep.sh log $BUILDSTEP_ZEP "# Starting, Zeppelin Build ..."

	read -r -a SPARK_VERSIONS <<< "$SPARK_VERSION"
	for i in "${SPARK_VERSIONS[@]}"
	do
		SPARK_VER=$i
		SPARK_PROFILE=${SPARK_VER%.*}
		HADOOP_PROFILE=${HADOOP_VERSION%.*}

		##### Build Step 1
		/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : started $item build spark $SPARK_VER"

		##### Build Step 2 ( build spark 1.x )
		if [[ $item == "spark_standalone" ]]; then

			if [[ $arg_num == 0 ]]; then
				first_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE
			else
				if [[ $SPARK_PROFILE == "1.2" || $SPARK_PROFILE == "1.1" ]]; then
					etc_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE
				else
					skiptests_etc_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE
				fi
			fi

		else

			if [[ $arg_num == 0 ]]; then
				first_build_only_spark $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE $item
			else
				if [[ $SPARK_PROFILE == "1.2" || $SPARK_PROFILE == "1.1" ]]; then
					etc_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE
				else
					skiptests_etc_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE
				fi
			fi

		fi

		arg_num=1

		##### Build Step 3
		/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : finished $item build spark $SPARK_VER"
		/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : wait for backend - spark $SPARK_VER"
		/buildstep.sh waitfor $BUILDSTEP_BAK "- $BUILDSTEP_BAK : closed $item backend spark $SPARK_VER"
	done

	echo "- ${item} build done."
	arg_num=0

done
echo "Done!"


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
