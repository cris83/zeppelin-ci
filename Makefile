### Makefile by astroshim <hsshim@nflabs.com>
### This is a makefile for making docker images or running docker containers.

IMAGE_VERSION = 0.3

# Below env can be the arguments.
SPARK_PROFILE = "1.5 1.4 1.3 1.2 1.1"
SPARK_VERSION = "1.5.0 1.4.1 1.3.1 1.2.1 1.1.1"
HADOOP_PROFILE = 2.3
HADOOP_VERSION = 2.3.0
JDK_VERSION = 1.7.0

.PHONY: help build run

BUILD_DIR=/tmp/build/build/
INTERPRETER_BUILD_DIR=/tmp/build/build/backends
ZEPPELIN_BUILD_DIR=/tmp/build/build/zeppelin

help:
	@echo
	@echo "  Several choices : "
	@echo
	@echo "   make build     to build all docker image."
	@echo "   make run       to run all docker container."
	@echo 
	@echo "   example) make build type=zeppelin item=spark_standalone "
	@echo 
	@echo "  type : "
	@echo 
	@echo "   backend        jobs for backends."
	@echo "   zeppelin       jobs for zeppelin."
	@echo 
	@echo "  sub item : "
	@echo "  examples) "
	@echo "   *              all items in the build system will be ran."
	@echo "   spark_*        all spark cluster will be builded or ran."
	@echo 

setup =  \
	mkdir -p $(BUILD_DIR); \
	rm -rf $(BUILD_DIR)*; \
	cp -rf build/* $(BUILD_DIR) 


run_job =  \
	for dir in $$(find $(1) -type d); do \
	  ( \
		cd $$dir ; \
		if [ -f Makefile ]; then \
			for t in $$dir/*; do \
			  (if [ -d $$t ]; then \
				if [[ `basename $$t` == $(3) ]]; then \
					echo "*****************************************************************"; \
					echo "***** target path => $$t"; \
					echo "*****************************************************************"; \
					cp -f $(BUILD_DIR)/buildstep.sh $$t; \
					make $2 -f Makefile \
						type=`basename $$t` \
						REPO=$(REPO) \
						BRANCH=$(BRANCH) \
						IMAGE_VERSION=$(IMAGE_VERSION) \
						SPARK_PROFILE=$(SPARK_PROFILE) \
						SPARK_VERSION=$(SPARK_VERSION) \
						HADOOP_PROFILE=$(HADOOP_PROFILE) \
						HADOOP_VERSION=$(HADOOP_VERSION) \
						JDK_VERSION=$(JDK_VERSION) \
						BUILD_PATH=$$t; \
                    let RET=$$?; \
                    if [ ! $$RET -eq 0 ]; then \
                        echo "1" > /tmp/zepci_$(item)_result; \
                    else \
                        echo "0" > /tmp/zepci_$(item)_result; \
                    fi; \
			  	fi; \
			  fi; \
			); done \
		fi; \
	/bin/echo " "; \
	); done	

build : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	if [ -z $(item) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	echo "type=$(type)"; \
	$(call setup); \
	if [ "$(type)" = "backend" ]; then \
		./build/repo/get_backend_utils.sh $(HADOOP_PROFILE); \
		$(call run_job,$(INTERPRETER_BUILD_DIR),$@,$(item)) \
	elif [ "$(type)" = "zeppelin" ]; then \
		./build/repo/get_zeppelin_utils.sh $(HADOOP_PROFILE); \
		$(call run_job,$(ZEPPELIN_BUILD_DIR),$@,$(item)) \
	else \
		echo "no type you want!"; \
		exit 1; \
	fi;

run : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	$(call setup); \
	if [ "$(type)" = "backend" ]; then \
		$(call run_job,$(INTERPRETER_BUILD_DIR),$@,$(item)) \
	elif [ "$(type)" = "zeppelin" ]; then \
		$(call run_job,$(ZEPPELIN_BUILD_DIR),$@,$(item)) \
	else \
		echo "no type you want!"; \
		exit 1; \
	fi;

