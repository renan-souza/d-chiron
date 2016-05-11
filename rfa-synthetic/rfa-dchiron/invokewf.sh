#!/bin/bash
REPO_HOME="$(cd "`dirname "$0"`"/..; pwd)"

wfdir=$REPO_HOME/rfa-synthetic/rfa-dchiron
xml=$REPO_HOME/rfa-synthetic/rfa-dchiron/rfa-dchiron-wf.xml
mysql_root_directory="$1"

$REPO_HOME/d-chiron/startWF.sh $wfdir $wfdir/machines.conf.chiron $xml $mysql_root_directory