#!/bin/sh

export ROOT=$(cd `dirname $0`; pwd)
export SKYNET_ROOT=$ROOT/skynet
export DAEMON=false

node=1
## echo $ROOT
 echo $SKYNET_ROOT
while getopts "Dku12" arg
do
	case $arg in
		D)
			export DAEMON=true
			;;
		k)
			kill `cat $ROOT/run/skynet.pid`
			exit 0;
			;;
        u)
            svn up
            svn up config/
            svn up proto/
            exit 0;
            ;;
        1)
            node=$arg
            ;;
        2)
            node=$arg
            ;;
	esac
done

echo $node

$SKYNET_ROOT/skynet $ROOT/etc/config$node

