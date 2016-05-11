#!/bin/bash
REPO_HOME="$(cd "`dirname "$0"`"/..; pwd)"


WFDIR="$1"
confchiron="$2"
XML="$3"
mysql_root_directory="$4"

sccore="dChiron.jar"
setup="dChironSetup.jar"

sccore="$REPO_HOME/d-chiron/$sccore"
setup="$REPO_HOME/d-chiron/$setup"

lockfileroot="${WFDIR}/.lockrank"

executeChiron() {

	lineschiron=`cat $confchiron  | egrep -v "#" | egrep "@"`
	dbdir="$REPO_HOME/d-chiron/dbcluster"
	dbconf="$dbdir/databases.conf"
	generatedsql="$dbdir/main-generated.sql"
	funcgenerated="$dbdir/functions-generated.sql"

	echo "Rebuilding the database for the next execution..."
	linesdb=`cat $dbconf  | egrep -v "#" | egrep ","`
	sqlnode=""
    FIRST_MACHINE=""
	echo "Lines db: $linesdb"
	for i in `echo $linesdb`; do
		IFS=',' read -ra ADDR <<< "$i"
		sqlnode=${ADDR[1]}
        if [ $FIRST_MACHINE="" ]; then
            FIRST_MACHINE=$sqlnode
        fi
	done
	echo "ssh $FIRST_MACHINE \" $mysql_root_directory/0/usr/local/mysql/bin/mysql --host=$sqlnode --user=root < $generatedsql \"  "
	ssh $FIRST_MACHINE "$mysql_root_directory/0/usr/local/mysql/bin/mysql --host=$sqlnode --user=root < $generatedsql "
	echo "Created main tables, waiting..."
	sleep 20

	echo "Creating functions..."
	for i in `echo $linesdb`; do
		echo "line bd: $i"
		IFS=',' read -ra ADDR <<< "$i"
		sqlnode=${ADDR[1]}
		echo "ssh $FIRST_MACHINE \"$mysql_root_directory/0/usr/local/mysql/bin/mysql --host=$sqlnode --user=root < $funcgenerated \"  "
		ssh $FIRST_MACHINE "$mysql_root_directory/0/usr/local/mysql/bin/mysql --host=$sqlnode --user=root < $funcgenerated "
		sleep 10
	done
	echo "Created functions."

	echo "Creating domain tables"
	ssh $FIRST_MACHINE java -jar $setup -i $XML

	sleep 30

	echo "Starting each machine..."
	count=0
	for i in `echo $lineschiron`; do
		file="${lockfileroot}${count}"
		echo "Creating lock file $file"
		touch $file;
		host=`echo $i | cut -d "@" -f 1`

		rank=$count
		echo "ssh $host \"killall -9 java 2>/dev/null; java -jar $sccore $XML $rank; rm -rf $file;\" &   "
		echo "I CHANGED JVM MEMORY ARGUMENTS... PLEASE CHECK THIS FILE (scripts/scc-distributed.sh)"
		ssh $host "killall -9 java 2>/dev/null; java -jar -Xms1G -Xmx1G $sccore $XML $rank; rm -rf $file;" &
		count=`expr $count + 1`
	done
	echo "All started."

	while [[ true ]] ; do
		found=`find ${WFDIR} -maxdepth 1 -type f -wholename "${lockfileroot}[0-9]*" 2>/dev/null`
		[[ $found ]] || break
		sleep 10
	done

	sleep 15

}

rm -rf $lockfileroot*

executeChiron



echo ""
echo "Done!!!"
