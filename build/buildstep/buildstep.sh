#!/bin/bash
BS_PROFILE="/etc/.profile.bs"
BS_LOGPATH=""


function buildstep_init
{
	bs_logdir=$2
	bs_timeout=$3		#<- seconds

	mkdir -p $bs_logdir
	touch $BS_PROFILE
	echo "export BS_PATH=$bs_logdir" > $BS_PROFILE
	echo "export BS_TIMEOUT=$bs_timeout" >> $BS_PROFILE
}

function buildstep_getargs()
{
	args=("$@")
	bs_log=""

	for i in `seq 2 $#`;
	do
		arg=${args[$i]}
		if [[ $i == 1 ]]; then
			bs_log="$arg"
		else
			bs_log="$bs_log $arg"
		fi
	done

	echo $bs_log
}

function buildstep_log
{
	bs_file=$2
	bs_log=$(buildstep_getargs $@)

	echo $bs_log >> $BS_LOGPATH/$bs_file
}


function buildstep_waitfor
{
	buildstep=$BS_LOGPATH/$2
	compstr=$(buildstep_getargs $@)
	let timeout=0

	if [ -z "$compstr" ]; then
		echo "- please, input compare string"
		exit 1
	fi

	echo "- buildstep waitfor compare timeout : $BS_TIMEOUT"
	echo "- buildstep waitfor compare string  : $compstr"
	echo ""

	while true
	do
		val=`tail -1 $buildstep 2>&1`	#<- Redirect stderr to stdout
		if [[ $val == $compstr ]]; then
			exit 0
		else
			let "timeout+=1"
			echo "# Build step - wait($timeout)..."
			sleep 1

			if [[ $BS_TIMEOUT == $timeout ]]; then
				echo "# Build step - timeout !"
				exit 1
			fi
		fi
	done
}


function buildstep
{
	if [[ $1 != "init" ]]; then
		source $BS_PROFILE
		BS_LOGPATH=$BS_PATH
	fi

	case $1 in
		init)
			buildstep_init $*
			;;
		waitfor)
			buildstep_waitfor $*
			;;
		log)
			buildstep_log $*
			;;
		*)
			echo "- buildstep : command not found"
			;;
	esac
}


buildstep $@
