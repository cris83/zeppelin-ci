FROM DOCKER_VAR_OS
MAINTAINER astroshim <hsshim@nflabs.com>

# set env 
ENV SPARK_PROFILE DOCKER_VAR_SPARK_PROFILE
ENV SPARK_VERSION DOCKER_VAR_SPARK_VERSION
ENV HADOOP_PROFILE DOCKER_VAR_HADOOP_PROFILE
ENV HADOOP_VERSION DOCKER_VAR_HADOOP_VERSION

# update the image with the latest packages
RUN yum update -y; yum clean all
RUN yum install -y \
wget \
tar \
curl \
&& \
yum clean all

# remove old jdk
RUN yum remove java; yum remove jdk

# install oracle jdk7
RUN wget --continue --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" -O jdk-linux-x64.rpm "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.rpm"
RUN rpm -Uvh jdk-linux-x64.rpm
RUN rm jdk-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# get spark
COPY spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz /tmp/
RUN tar xzf /tmp/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz -C /usr/local

RUN cd /usr/local && ln -s spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE spark
ENV SPARK_HOME /usr/local/spark

# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

# install mesos
RUN rpm -Uvh http://repos.mesosphere.com/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm
RUN yum -y install mesos

# open port for spark
EXPOSE 8080 7077 8888 8081

# open port for mesos
EXPOSE 5050

ENTRYPOINT ["/etc/bootstrap.sh"]
