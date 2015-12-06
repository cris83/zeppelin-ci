#!/bin/bash
BS_PROFILE="/etc/.profile.bs"
BS_INITFLG="buildstep.init"
BS_LOGPATH=""


function buildstep_init
{
    bs_logdir=$2
    bs_timeout=$3                       #<- seconds

    mkdir -p $bs_logdir
    touch $BS_PROFILE
    echo "export BS_PATH=$bs_logdir" > $BS_PROFILE
    echo "export BS_TIMEOUT=$bs_timeout" >> $BS_PROFILE
    echo "0" > $bs_logdir/$BS_INITFLG
}


function buildstep_envload
{
	yml=$1								
    envfile=$2							

    echo "#!/bin/bash" > $envfile
    chmod +x $envfile

    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $yml |
    awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent-1; i++) {vn=(vn)(vname[i])("_")}
         printf("export %s%s=\"%s\"\n", vn, $2, $3);
      }
    }' >> $envfile
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

    echo $bs_log

    init=`cat $BS_LOGPATH/$BS_INITFLG`
    if [[ $init == 0 ]]; then
        echo "1" > $BS_LOGPATH/$BS_INITFLG
        echo $bs_log > $BS_LOGPATH/$bs_file
    else
        echo $bs_log >> $BS_LOGPATH/$bs_file
    fi
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
        if [ -f $buildstep ]; then
            line=`cat $buildstep | wc -l`
            for n in `seq 1 $line`
            do
                val=`tail -$n $buildstep | head -1 2>&1`
                if [[ $val == $compstr ]]; then
                    let "timeout=0"
                    exit 0
                fi
            done
        fi

		let "timeout+=1"
		echo "# Build step - wait($timeout)..."
		sleep 1

		if [[ $BS_TIMEOUT == $timeout ]]; then
			echo "# Build step - timeout !"
			exit 1
		fi
	done
}

function buildstep_putres
{
	item=$2
	ret=$3

	if [[ $ret != 0 ]]; then
		echo "1" > /tmp/zepci_${item}_result
	else
		echo "0" > /tmp/zepci_${item}_result
	fi
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
		envload)
			buildstep_envload $2 $3
			;;
		waitfor)
			buildstep_waitfor $*
			;;
		log)
			buildstep_log $*
			;;
		putres)
			buildstep_putres $*
			;;
		*)
			echo "- buildstep : $1 is invalid command"
			;;
	esac
}


buildstep $@