#!/bin/bash
DIR=$(cd `dirname $0` && cd .. && pwd)

mvn package -f "$DIR/Activator/pom.xml" -Ddir="../exp/bin"
mvn package -f "$DIR/SyntheticRFA/pom.xml" -Ddir="../exp/bin"
