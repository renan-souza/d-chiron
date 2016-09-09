# d-Chiron

## Dependecies
- Java JRE 1.7 64 bit or newer
- MySQL Cluster
- libaio1 64 bit
- The front node (node from which the other processes will start) should be able to access the other nodes via ssh using public key.

## Setup
1. Clone repository:

    ```bash
    $ git clone https://github.com/vssousa/d-chiron.git
    ```
2. Download MySQL Cluster:
    
    [Linux Generic (glibc 2.5) (x86, 64-bit), Compressed TAR Archive](http://dev.mysql.com/downloads/cluster/)
3. Unpack MySQL Cluster:

    ```bash
    $ tar -xvvf mysql-cluster-gpl-X.Y.Z-plataform.tar.gz
    ```
4. Change working directory to d-Chiron:
    
    ```bash
    $ cd d-chiron/d-chiron
    ```
5.  Setup  MySQL Cluster for d-Chiron:
    
    ```bash
    $ ./setupmysql.sh <mysql_path> <mysql_directory> <data_directory> <number_of_nodes>
    ```
 - `mysql_path`: fullpath to the unpacked MySQL Cluster directory
 - `mysql_directory`: root directory where MySQL cluster directories will be placed into
 - `data_directory`: base directory where data from data nodes will be placed into
 - `number_of_nodes`: Maximum number of nodes that will run MySQL Cluster. If there are, for example, 5 database nodes (1 mgm_node, 2 sql_nodes, 2 data_nodes), this number should be at least 5.

## Configuration

- Edit dbcluster/installation.properties:

    ```bash
    $ vi dbcluster/installation.properties
    ```
    - [Follow this link for an example](dbcluster/installation.properties.example)
    - Define installationRootDirectory and base_data_dir as you defined in Setup#5 for mysql_root_directory an base_data_directory, respectively.
    - Chose the number of nodes used by  MySQL Cluster
        - number_of_datanodes
        - number_of_sqlnodes
        - number_of_mgm_node
    - All other configurations may be left as the example file.

## Workflow Configuration

1. Change working directory to rfa-synthetic/rfa-dchiron:

    ```sh
    $ cd ../rfa-synthetic/rfa-dchiron
    ```
- [Use of the XML file from RFA workflow](../rfa-synthetic/rfa-dchiron/rfa-dchiron-wf.xml):
    
    ```sh
    $ vi rfa-dchiron-wf.xml
    ```
    - Replace `full/to/path/repositoryroot/` ocurrences with the full path to this repository root directory

- Edit machines.conf with nodes hostnames, ports, and ranks for MPI initialization:
    
    ```sh
    $ vi machines.conf
    ```
   Example:
    ```
    # Number of processes
    2
    # Protocol switch limit
    131072
    #Entry in the form of machinename@port@rank
    node1-hostname@20348@0
    node2-hostname@20348@1
    ```

## Run
Scripts to submit workflow execution using d-Chiron can be found in ....

1. Start MySQL Cluster instances:

    ```bash
    $ ./invokestartdb.sh <mysql_root_directory>
    ```

2. Submit workflow execution:

    ```bash
    $ ./invokewf.sh <mysql_root_directory>
    ```
3. Shutdown MySQL Cluster instances:

    ```bash
    $ ./invokeshutdown.sh <mysql_root_directory>
    ```

## Monitor

1. Add new monitoring queries before or during workflow execution, informing the monitoring interval. Example:

    ```sql
    insert into dchiron.umonitoring(monitoringinterval, monitoringquery) values (
        10, 
        'select avg(g.map2) from dchiron.eactivation artask, rfa.ogatherdatafromrisers g, rfa.opreprocessing p, rfa.oanalyzerisers r where r.previoustaskid = p.nexttaskid and p.previoustaskid = g.nexttaskid and r.previoustaskid = artask.taskid and (artask.endtime-artask.starttime) > (select avg(endtime-starttime) from scc2.eactivation where actid=3);'
    );
    ```

1. Start the `Monitor` module:

    ```bash
    $ java -jar Monitor.jar --start
    ```
	
1. For each monitoring query, the result will be stored in `UMonitoringResult` at each time interval defined for the query. 
	
## Steer

#### Removing slices

1. First, determine the select predicates to determine a slice to be removed. For example, `map1 > 70000`. 

2. Then, run a steering query to cut off the slice:

    ```bash
    $ java -jar --xml=rfa-dchiron-wf.xml --user=peter --type=REMOVE_TUPLES --tasksquery="select  nexttaskid  from wf1.ogatherdatafromrisers where map1 > 70000" 
    ````
