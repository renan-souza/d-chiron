ACTIVATORJAR=bin/Activator.jar
JAR_FILE=bin/SyntheticRFA.jar
ISDEBUG=true
PATH_FILES=files
MAIN_CLASS="br.ufrj.main.SyntheticRFA"
WFDIR=.
MASTER_HOST=$1
SWB_PY=bin/swb.py
OUTPUT_DIR=${WFDIR}/out
INPUT_FILE_PATH=input.dataset

EXECUTORS=$2
TOTAL_CORES=$3
TAG_NAME="SparkSyntheticRFA"
BALANCED=true
ENABLERANDOM=false


ARGS="$MASTER_HOST $TOTAL_CORES $INPUT_FILE_PATH $TAG_NAME $OUTPUT_DIR $BALANCED ${ISDEBUG} $PATH_FILES $ACTIVATORJAR $SWB_PY ${ENABLERANDOM}"

#$SPARK_HOME/bin/spark-submit --class $MAIN_CLASS --num-executors $EXECUTORS --total-executor-cores $TOTAL_CORES --master $MASTER_HOST $JAR_FILE $ARGS

#log
$SPARK_HOME/bin/spark-submit --class $MAIN_CLASS --num-executors $EXECUTORS --total-executor-cores $TOTAL_CORES --master $MASTER_HOST --conf spark.eventLog.enabled=true --conf spark.eventLog.dir=slog $JAR_FILE $ARGS
