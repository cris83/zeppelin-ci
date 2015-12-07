### Makefile by astroshim <hsshim@nflabs.com>
### This is a makefile for making zeppelin docker images or running zeppelin docker containers.

.PHONY: help build run


# ----------------------------------------------------------------------
# - Define Varialbes 
# ----------------------------------------------------------------------

LOCALREPO_BIN=$(BUILD_HOME)/build/localrepo/bin
LOCALREPO_DAT=$(BUILD_HOME)/build/localrepo/dat
REPOSHARE_ENV=$(REPOSHARE_PATH)/$(ZCI_ENV)

OS_VERSION=centos:centos6


# ----------------------------------------------------------------------
# - Host Port
# ----------------------------------------------------------------------

ZEPPELIN_PORT = 8080
ZEPPELIN_WEBSOCKET_PORT = 8081

ZEPPELIN_HOST_PORT_STANDALONE = 39090
ZEPPELIN_HOST_WEBSOCKET_PORT_STANDALONE = 39091
ZEPPELIN_HOST_PORT_YARN = 48080
ZEPPELIN_HOST_WEBSOCKET_PORT_YARN = 48081
ZEPPELIN_HOST_PORT_MESOS = 58080
ZEPPELIN_HOST_WEBSOCKET_PORT_MESOS = 58081


# ----------------------------------------------------------------------
# - Call Function
# ----------------------------------------------------------------------

docker_build = \
	echo ""; \
	source $(REPOSHARE_PATH)/$(ZCI_ENV); \
	$(LOCALREPO_BIN)/get_confirm_build_dat.sh $(REPOSHARE_ENV) $(LOCALREPO_DAT); \
	cp build.sh $1; \
	sed -i -e 's/DOCKER_VAR_OS/$(OS_VERSION)/g' $1/Dockerfile; \
	docker build -t zeppelin-"$1:$(IMAGE_VERSION)" $1/;


# ----------------------------------------------------------------------
# - Build Options
# ----------------------------------------------------------------------

help:
	@echo
	@echo "  Several choices : "
	@echo
	@echo "   make build type=[type]    to build zeppelin docker image of defined type."
	@echo "   make run type=[type]      to run zeppelin docker container of defined type."
	@echo 
	@echo "  type : "
	@echo 
	@echo "   spark_standalone          use spark standalone backend."
	@echo "   spark_yarn                use yarn backend."
	@echo "   spark_mesos               use mesos backend."
	@echo 


build : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	$(call docker_build,$(type))
	
run : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	if [ $(type) = "spark_standalone" ]; then\
		echo "run spark standalone mode zeppelin! "; \
		docker run --rm -i \
        -v $(REPOSHARE_PATH):/reposhare \
		-e BRANCH=$(BRANCH) \
		-e REPO=$(REPO) \
		-e ZCI_ENV=$(ZCI_ENV) \
		-e BUILD_TYPE=$(type) \
		-p $(ZEPPELIN_HOST_PORT_STANDALONE):$(ZEPPELIN_PORT) \
		-p $(ZEPPELIN_HOST_WEBSOCKET_PORT_STANDALONE):$(ZEPPELIN_WEBSOCKET_PORT) \
		zeppelin-$(type):$(IMAGE_VERSION) /bin/bash; \
	elif [ $(type) = "spark_yarn" ]; then\
		echo "run spark_yarn mode zeppelin! "; \
		docker run --rm -i \
        -v $(REPOSHARE_PATH):/reposhare \
		-e BRANCH=$(BRANCH) \
		-e REPO=$(REPO) \
		-e ZCI_ENV=$(ZCI_ENV) \
		-e BUILD_TYPE=$(type) \
		-p $(ZEPPELIN_HOST_PORT_YARN):$(ZEPPELIN_PORT) \
		-p $(ZEPPELIN_HOST_WEBSOCKET_PORT_YARN):$(ZEPPELIN_WEBSOCKET_PORT) \
		--link $(type):sparkmaster \
		zeppelin-$(type):$(IMAGE_VERSION) /bin/bash; \
	elif [ $(type) = "spark_mesos" ]; then\
		echo "run mesos backend zeppelin! "; \
		docker run --rm -i \
        -v $(REPOSHARE_PATH):/reposhare \
		-e BRANCH=$(BRANCH) \
		-e REPO=$(REPO) \
		-e ZCI_ENV=$(ZCI_ENV) \
		-e BUILD_TYPE=$(type) \
		-p $(ZEPPELIN_HOST_PORT_MESOS):$(ZEPPELIN_PORT) \
		-p $(ZEPPELIN_HOST_WEBSOCKET_PORT_MESOS):$(ZEPPELIN_WEBSOCKET_PORT) \
		--link spark_mesos:sparkmaster \
		zeppelin-$(type):$(IMAGE_VERSION) /bin/bash; \
	else \
		echo "not found to run backend.";\
		exit 1; \
	fi  
