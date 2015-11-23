#!/bin/bash

export SPARK_HOME=/usr/local/spark/

rm /tmp/*.pid
export SPARK_HOME=/usr/local/spark/

# run spark 
export SPARK_LOCAL_IP=`awk 'NR==1 {print $1}' /etc/hosts`
sed '1d' /etc/hosts > /tmp/hosts
cat /tmp/hosts > /etc/hosts
rm /tmp/hosts
echo "$SPARK_LOCAL_IP `hostname`" >> /etc/hosts

# spark configuration
cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
echo "export MESOS_NATIVE_JAVA_LIBRARY=/usr/lib/libmesos.so" >> $SPARK_HOME/conf/spark-env.sh

cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
echo "spark.master mesos://`hostname`:5050" >> $SPARK_HOME/conf/spark-defaults.conf
echo "spark.mesos.executor.home /usr/local/spark" >> $SPARK_HOME/conf/spark-defaults.conf

export SPARK_MASTER_PORT=7077
cd $SPARK_HOME/sbin
./start-master.sh
./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT

# start mesos
mesos-master --ip=0.0.0.0 --work_dir=/var/lib/mesos &
mesos-slave --master=0.0.0.0:5050 --launcher=posix &

CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
	service sshd stop
	/usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi
