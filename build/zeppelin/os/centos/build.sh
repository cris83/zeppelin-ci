#!/bin/bash
set -e

echo "Launch a XVFB session on display port 99 . "
echo "DISPLAY = $DISPLAY"
dbus-uuidgen > /var/lib/dbus/machine-id
Xvfb $DISPLAY -ac -screen 0 1280x1024x24 &

echo "cloning zeppelin"
git clone -b $BRANCH $REPO /zeppelin
cp /tmp/zeppelin-env.sh /zeppelin/conf/
cd /zeppelin

echo "start buil without test.."
mvn package -DskipTests -Phadoop-${HADOOP_VERSION} -Ppyspark -B

echo "start buil with test.."
mvn package -Pbuild-distr -Phadoop-${HADOOP_VERSION} -Ppyspark -B

echo "start buil with backend test.."
mvn verify -Pusing-packaged-distr -Phadoop-${HADOOP_VERSION} -Ppyspark -B

echo "Done!"
