REPO_HOME="$(cd "`dirname "$0"`"/../..; pwd)"

ACTIVATORJAR=$REPO_HOME/rfa-synthetic/rfa-activities/bin/Activator.jar
JAR_FILE=$REPO_HOME/rfa-synthetic/rfa-spark/bin/rfa-spark.jar
ISDEBUG=true
PATH_FILES=$REPO_HOME/rfa-synthetic/files
MAIN_CLASS="br.ufrj.main.SyntheticRFA"
WFDIR=$REPO_HOME/rfa-synthetic/rfa-spark
MASTER_HOST=$1
SWB_PY=$REPO_HOME/rfa-synthetic/rfa-activities/bin/swb.py
OUTPUT_DIR=${WFDIR}/out
INPUT_FILE_PATH=${WFDIR}/input.dataset

EXECUTORS=$2
TOTAL_CORES=$3
TAG_NAME="SparkSyntheticRFA"
BALANCED=true
ENABLERANDOM=false

ARGS="$MASTER_HOST $TOTAL_CORES $INPUT_FILE_PATH $TAG_NAME $OUTPUT_DIR $BALANCED ${ISDEBUG} $PATH_FILES $ACTIVATORJAR $SWB_PY ${ENABLERANDOM}"

# if number of args is wrong
if [ $# != 3 ]; then
  echo "Usage: run.sh <spark-master-url> <num-executors> <total-executor-cores>"
  echo "Please check https://github.com/vssousa/d-chiron/tree/master/rfa-synthetic/rfa-spark"
  exit 1
fi

# if number $SPARK_HOME is not set
if [[ -z $SPARK_HOME ]]; then
    echo "ERROR : SPARK_HOME is not a set"
    exit 1
fi

$SPARK_HOME/bin/spark-submit --class $MAIN_CLASS --num-executors $EXECUTORS --total-executor-cores $TOTAL_CORES --master $MASTER_HOST $JAR_FILE $ARGS
