#!/usr/bin/env bash

if [ $# -lt 1 ]; then
	echo "Usage: $0 [ deploy | redeploy | start | stop | remove ]"
	exit
fi

function deploy() {
  kcli create plan -f ex294_rhel8_lab.yml ex294-rhel8-lab
}

function redeploy() {
  kcli create plan -f ex294_rhel8_lab.yml ex294-rhel8-lab --force
}

function start() {
  kcli start plan ex294-rhel8-lab
}

function stop() {
  kcli stop plan ex294-rhel8-lab
}

function remove() {
  kcli delete plan ex294-rhel8-lab
}

case "$1" in
deploy)
	deploy
	;;
redeploy)
	redeploy
	;;
start)
	start
	;;
stop)
	stop
	;;
remove)
	remove
	;;
*)
	echo "Usage: $0 [ deploy | redeploy | start | stop | remove ]"
	exit 1
	;;
esac

exit 0
