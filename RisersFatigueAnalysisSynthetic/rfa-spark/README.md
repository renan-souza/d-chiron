# Risers Fatigue Analysis Syntehtic - Spark

## How to Run
### Dependencies:
- [Apache Spar Cluster](https://spark.apache.org/docs/1.1.0/cluster-overview)
- [Python2](https://www.python.org/downloads/)
- [Bash](https://www.gnu.org/software/bash/)

### Setup and configuration:
Clone repository:
```sh
$ git clone https://github.com/vssousa/d-chiron.git
$ cd d-chiron
```
#### Edit the input file:
```sh
$ vi RisersFatigueAnalysisSynthetic/rfa-spark/input.dataset
```
- Eg:
```csv
ID;SPLITMAP;SPLITFACTOR;MAP1;MAP2;FILTER1;F1;FILTER2;F2;REDUCE;REDUCEFACTOR
1;5;8;5;5;5;100;5;100;5;4
```
- Fields:
 - **ID**:
 - **SPLITMAP**: Average Task Cost in Uncompress activity (seconds)
 - **SPLITFACTOR**:
 - **MAP1**: Average Task Cost in Pre-Processing activity (seconds)
 - **MAP2**: Average Task Cost in Analyze Riser sactivity (seconds)
 - **FILTER1**:Average Task Cost in Calculate Wear and Tear activity (seconds)
 - **F1**:
 - **FILTER2**:Average Task Cost in Analyze Position activity (seconds)
 - **F2**:
 - **REDUCE**: Average Task Cost in Compress Results activity (seconds)
 - **REDUCEFACTOR**:

### Run
- Start Apache Spark Cluster
- Set SPARK_HOME environment variable
```sh
$ export SPARK_HOME=/path/to/spark
```
- Change directory to rfa-spark:
```sh
$ cd RisersFatigueAnalysisSynthetic/rfa-spark
```
- Run:
```sh
$ ./run.sh <spark-master-url> <num-executors> <total-executor-cores>
```
Where:
   - **spark-master-url**: The master URL for the cluster
   - **num-executors**: Number of Apache Spark executors requested on thec cluster.
   - **total-executor-cores**: Total Number of cores requested on the cluster.

- Eg:
```sh
$ ./run.sh  spark://hostname:7077 1 2
```
## Source and Build:

[Source Code](rfa-spark-project)

### Build Dependencies
- [Maven 3](http://maven.apache.org)
- [Scala](http://www.scala-lang.org/)

### Build
- Change directory to rfa-spark-project:
```sh
$ cd RisersFatigueAnalysisSynthetic/rfa-spark/rfa-spark-project
```
- Maven
```sh
$ mvn package
```
