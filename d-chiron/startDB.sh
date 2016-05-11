#!/bin/bash
REPO_HOME="$(cd "`dirname "$0"`"/..; pwd)"
echo "Rebuilding the database..."

xml=$1
chironjar=$REPO_HOME/d-chiron/dChiron.jar
class="chiron.dbcluster.DBManager"

java -cp $chironjar $class $xml --start $2 $3 $4 $5 $6 $7 $7