### Makefile by astroshim <hsshim@nflabs.com>
### This is a makefile for making backend docker images or running backend docker containers.

.PHONY: help build run

# zeppelin ports
ZEPPELIN_PORT = 8080
ZEPPELIN_WEBSOCKET_PORT = 8081

# spark ports
SPARK_MASTER_PORT = 7077
SPARK_MASTER_UI_PORT = 8888

# mesos ports
MESOS_PORT = 5050
MESOS_HOST_PORT = 25050

# hadoop ports
HDFS_NN_HTTP_PORT = 50070
HDFS_NN_COMMAND_PORT = 9000
HDFS_DN_HTTP_PORT = 50075
HDFS_DN_DATA_PORT = 50010
HDFS_DN_COMMAND_PORT = 50020
YARN_JOB_TRACKER_PORT = 9001
YARN_NN_HTTP_PORT = 8042
YARN_RM_PORT = 8032
YARN_RM_HTTP_PORT = 8088
YARN_RM_RT_PORT = 8031
YARN_RM_SCHEDULER_PORT = 8030
YARN_RM_ADMIN_PORT = 8033

docker_build =  \
	sed -i -e 's/DOCKER_VAR_OS/centos:centos6/g' $1/Dockerfile;  \
	sed -i -e 's/DOCKER_VAR_SPARK_PROFILE/$(SPARK_PROFILE)/g' $1/Dockerfile;  \
	sed -i -e 's/DOCKER_VAR_SPARK_VERSION/$(SPARK_VERSION)/g' $1/Dockerfile;  \
	sed -i -e 's/DOCKER_VAR_HADOOP_PROFILE/$(HADOOP_PROFILE)/g' $1/Dockerfile;  \
	sed -i -e 's/DOCKER_VAR_HADOOP_VERSION/$(HADOOP_VERSION)/g' $1/Dockerfile;  \
	../repo/get_backend_util_build.sh $(SPARK_VERSION) $(HADOOP_PROFILE); \
	docker build -t "$1:$(IMAGE_VERSION)" $1/ 

help:
	@echo
	@echo "  Several choices : "
	@echo
	@echo "   make build type=[type]    to build zeppelin backend docker image of defined type."
	@echo "   make run type=[type]      to run zeppelin backend docker container of defined type."
	@echo 
	@echo "  type : "
	@echo 
	@echo "   spark_standalone          spark standalone cluster backend."
	@echo "   spark_yarn                spark yarn cluster backend."
	@echo "   spark_mesos               mesos cluster backend."
	@echo 

build :
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi
	$(call docker_build,$(type))

run : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	if [ $(type) = "spark_standalone" ]; then\
		docker run -id \
		-p 38080:$(ZEPPELIN_PORT) \
		-p 37077:$(SPARK_MASTER_PORT) \
		-p 38888:$(SPARK_MASTER_UI_PORT) \
		-p 38081:$(ZEPPELIN_WEBSOCKET_PORT) \
		-h sparkmaster \
		--name $(type) \
		$(type):$(IMAGE_VERSION) bash; \
	elif [ $(type) = "spark_yarn" ]; then\
		docker run -id \
		-p 18080:$(ZEPPELIN_PORT) \
		-p 17077:$(SPARK_MASTER_PORT) \
		-p 18888:$(SPARK_MASTER_UI_PORT) \
		-p 18081:$(ZEPPELIN_WEBSOCKET_PORT) \
		-p 19000:$(HDFS_NN_COMMAND_PORT) \
		-p 19001:$(YARN_JOB_TRACKER_PORT) \
		-p 18088:$(YARN_RM_HTTP_PORT) \
		-p 18042:$(YARN_NN_HTTP_PORT) \
		-p 18030:$(YARN_RM_SCHEDULER_PORT) \
		-p 18031:$(YARN_RM_RT_PORT) \
		-p 18032:$(YARN_RM_PORT) \
		-p 18033:$(YARN_RM_ADMIN_PORT) \
		-p 50010:$(HDFS_DN_DATA_PORT) \
		-p 50020:$(HDFS_DN_COMMAND_PORT) \
		-p 50075:$(HDFS_DN_HTTP_PORT) \
		-p 50070:$(HDFS_NN_HTTP_PORT) \
		--name $(type) \
		-h sparkmaster \
		$(type):$(IMAGE_VERSION) bash; \
	elif [ $(type) = "spark_mesos" ]; then\
		docker run -id \
		-p 28080:$(ZEPPELIN_PORT) \
		-p 27077:$(SPARK_MASTER_PORT) \
		-p 28888:$(SPARK_MASTER_UI_PORT) \
		-p 28081:$(ZEPPELIN_WEBSOCKET_PORT) \
		-p 25050:$(MESOS_PORT) \
		--name $(type) \
		-h sparkmaster \
		$(type):$(IMAGE_VERSION) bash; \
	else \
		echo "not found to run backend.";\
	fi

