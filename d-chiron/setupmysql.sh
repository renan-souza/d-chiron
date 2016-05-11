#!/bin/bash

REPO_HOME="$(cd "`dirname "$0"`"/..; pwd)"
mysql_path=$1
mysql_root_directory=$2
base_data_directory=$3
max_number_of_nodes=$4

# if number of args is wrong
if [ $# != 4 ]; then
  echo "Usage: setupmysql.sh <mysql_path> <mysql_root_directory> <base_data_directory> <max_number_of_nodes>"
  echo "Please check https://github.com/vssousa/d-chiron/tree/master/rfa-synthetic/rfa-spark"
  exit 1
fi

if [ ! -d "$mysql_path" ]; then
    echo "ERROR: mysql_path $mysql_path is not a directory"
    exit 1
fi

for dir in  $mysql_root_directory $base_data_directory; do
    if [ ! -d "$dir" ]; then
        mkdir "$dir"
    fi
    echo $dir
done

for ((i=0;i<$max_number_of_nodes;i++)); do
    echo $i
    mkdir -p $mysql_root_directory/$i/etc
    mkdir -p $mysql_root_directory/$i/var/lib/mysql
    mkdir -p $mysql_path $mysql_root_directory/$i/usr/local
    cp -r $mysql_path $mysql_root_directory/$i/usr/local/mysql/

    mkdir $base_data_directory/$i
done
