#!/bin/bash
REPO_HOME="$(cd "`dirname "$0"`"/..; pwd)"
mysql_root_directory="$1"
$REPO_HOME/d-chiron/shutdownDB.sh $REPO_HOME/rfa-synthetic/rfa-dchiron/rfa-dchiron-wf.xml --configFile=$mysql_root_directory/0/var/lib/mysql/config.ini --ssh --secsToWait=30
