#!/bin/bash
REPO_HOME="$(cd "`dirname "$0"`"/..; pwd)"
$REPO_HOME/d-chiron/startDB.sh $REPO_HOME/rfa-synthetic/rfa-dchiron/rfa-dchiron-wf.xml