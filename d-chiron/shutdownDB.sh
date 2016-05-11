#!/bin/bash

REPO_HOME="$(cd "`dirname "$0"`"/..; pwd)"
xml=$1
chironjar=$REPO_HOME/d-chiron/dChiron.jar
class="chiron.dbcluster.DBManager"

echo "java -cp $chironjar $class $xml --shutdown $3 $4 $5"
java -cp $chironjar $class $xml --shutdown $3 $4 $5
