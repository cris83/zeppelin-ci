FROM DOCKER_VAR_OS
MAINTAINER astroshim <hsshim@nflabs.com>

# set env 
ENV SPARK_PROFILE_ARRAY DOCKER_VAR_SPARK_PROFILE
ENV SPARK_VERSION_ARRAY DOCKER_VAR_SPARK_VERSION
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

# --- get spark ---------------------------------------------------------------------
#COPY spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz /tmp/
#RUN tar xzf /tmp/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz -C /usr/local
#RUN cd /usr/local && ln -s spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE spark
#ENV SPARK_HOME /usr/local/spark
# -----------------------------------------------------------------------------------
ADD spark-*-bin-hadoop$HADOOP_PROFILE.tgz /usr/local/
RUN for i in ${SPARK_VERSION_ARRAY[@]}; do \
		ln -s /usr/local/spark-$i-bin-hadoop$HADOOP_PROFILE /usr/local/spark$i; \
	done
RUN ls -al /usr/local/
# -----------------------------------------------------------------------------------

# update buildstep
COPY buildstep.sh /buildstep.sh
RUN chown root.root /buildstep.sh
RUN chmod 700 /buildstep.sh

# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

# open port for spark
EXPOSE 8080 7077 8888 8081

ENTRYPOINT ["/etc/bootstrap.sh"]
