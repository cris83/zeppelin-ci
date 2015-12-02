#!/bin/bash
set -e

EXE_PATH=""
BACKEND=""
ZEPPELIN=""


# -------------------------------------------------------------------------
# Fucntions
# -------------------------------------------------------------------------

function buildorder_stop
{
	CONTAINER=$1

	if [ -z $CONTAINER ]; then
		echo "- buildorder : please, input container-name"
		exit 1
	fi

	ret_stop=`docker stop $CONTAINER`
	ret_rm=`docker rm $CONTAINER`
}

function buildorder_start
{
	ZEP_TYPE=$1		#<- Zeppelin item
	REPO=$2
	BRANCH=$3

	if [ -z $ZEP_TYPE ]; then
		echo "- buildorder : please, input item"
		exit 1
	fi
	if [ -z $REPO ]; then
		echo "- buildorder : please, input repo"
		exit 1
	fi
	if [ -z $BRANCH ]; then
		echo "- buildorder : please, input branch"
		exit 1
	fi

	cd $EXE_PATH

	# Start Interpreter(Backend) Container
	set +e
	make run type=backend item=$ZEP_TYPE
	if [ ! $? -eq 0 ]; then
		set -e
		buildorder_stop $ZEP_TYPE
		make run type=backend item=$ZEP_TYPE
	fi

	# Start Zeppelin Container
	set -e
	make run type=zeppelin item=$ZEP_TYPE REPO=$REPO BRANCH=$BRANCH
	#make run type=zeppelin item=$ZEP_TYPE repo=$REPO BRANCH=$BRANCH
}

function buildorder_clean
{
	docker ps -a | awk '{print $(NF-0)}' | while read line
	do
		if [ $line = "NAMES" ]; then
			continue;
		else
			echo "# closing, docker container - $line"
			buildorder_stop $line
		fi
	done
}

function buildorder
{
	set -e

	cur_path=`pwd`
	EXE_PATH=$cur_path
	BACKEND="$cur_path/resources/backends"
	ZEPPELIN="$cur_path/resources/zeppelin/os/centos"

	CMD=$1				#<- Buildorder Command
	CONTAINER=$2		#<- Docker Container Name
	ZEP_TYPE=$2			#<- Zeppelin
	REPO=$3				#<- Github Repository URL
	BRANCH=$4			#<- Github Repository Branch

	case $CMD in
		start)
			buildorder_start $ZEP_TYPE $REPO $BRANCH ;;
		stop)
			buildorder_stop $CONTAINER

			set +e
			result="/tmp/zepci_"$CONTAINER"_result"
			echo "# Result File : $result"

			let ret=`cat $result`
			echo "# $CONTAINER RET : $ret"

			if [ $ret -eq 0 ]; then
				exit 0
			else
				exit 1
			fi
			;;
		clean)
			buildorder_clean ;;
		*)
			echo "- buildorder : command not found" ;;
	esac
}


# -------------------------------------------------------------------------
# Main
# -------------------------------------------------------------------------
buildorder $@


# End of File
