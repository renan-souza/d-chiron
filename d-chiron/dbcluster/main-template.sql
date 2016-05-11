drop database if exists %=WF_TAG%;
drop database if exists %=DBNAME%;
create database %=DBNAME%;

SET FOREIGN_KEY_CHECKS = 0;

SET character_set_client = UTF8;


-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.cactivity
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.cactivity (
  actid INT NOT NULL AUTO_INCREMENT,
  wkfid INT NOT NULL,
  tag VARCHAR(255) NOT NULL,
  atype VARCHAR(25) NOT NULL,
  description VARCHAR(1024) NULL,
  activation VARCHAR(1024) NULL,
  extractor VARCHAR(1024) NULL,
  constrained VARCHAR(1) NULL,
  templatedir VARCHAR(1024) NULL,
  PRIMARY KEY (wkfid, actid),
  INDEX c_activity_wkfid (wkfid ASC),
  UNIQUE INDEX cactivity_actid (actid ASC),
  CONSTRAINT cactivity_wkfid_fk
    FOREIGN KEY (wkfid)
    REFERENCES %=DBNAME%.cworkflow (wkfid)
    ON DELETE CASCADE
    ON UPDATE SET NULL) Engine=NDBCLUSTER;

-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.cfield
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.cfield (
  fid INT NOT NULL AUTO_INCREMENT,
  fname VARCHAR(20) NOT NULL,
  relid INT NOT NULL,
  ftype VARCHAR(10) NOT NULL,
  decimalplaces INT NULL,
  fileoperation VARCHAR(20) NULL,
  instrumented VARCHAR(5) NULL,
  PRIMARY KEY (fid),
  INDEX c_field_key (fname ASC, relid ASC)) Engine=NDBCLUSTER;

-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.coperand
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.coperand (
  opid INT NOT NULL AUTO_INCREMENT,
  actid INT NOT NULL,
  oname VARCHAR(100) NULL,
  numericvalue DOUBLE NULL,
  textvalue VARCHAR(100) NULL,
  PRIMARY KEY (actid, opid),
  UNIQUE INDEX coperand_opid (opid ASC)) Engine=NDBCLUSTER;

-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.crelation
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.crelation (
  relid INT NOT NULL AUTO_INCREMENT,
  wkfid INT,
  rtype VARCHAR(20) NULL,
  rname VARCHAR(100) NULL,
  UNIQUE INDEX crelation_index (relid ASC),
  PRIMARY KEY (wkfid, relid)
) Engine=NDBCLUSTER;

-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.cworkflow
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.cworkflow (
  wkfid INT NOT NULL AUTO_INCREMENT,
  tag VARCHAR(200) NOT NULL,
  description VARCHAR(100) NULL,
  PRIMARY KEY (wkfid),
  UNIQUE INDEX cworkflow_index (wkfid ASC),
  UNIQUE INDEX cworkflow_index_tag (tag ASC)) Engine=NDBCLUSTER;

-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.eactivity
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.eactivity (
  actid INT NOT NULL AUTO_INCREMENT,
  wkfid INT NOT NULL,
  tag VARCHAR(50) NOT NULL,
  status varchar(20),
  starttime DATETIME NULL,
  endtime DATETIME NULL,
  cactid INT NULL,
  templatedir LONGTEXT NULL,
  constrained CHAR(1) NULL DEFAULT 'F',
  finishedloadingdata CHAR(1) NULL DEFAULT 'F',
  PRIMARY KEY (wkfid, actid),
  INDEX e_activity_wkfid (wkfid ASC),
  UNIQUE INDEX eactivity_actid (actid ASC),
  CONSTRAINT eactivity_wkfid_fk
    FOREIGN KEY (wkfid)
    REFERENCES %=DBNAME%.eworkflow (ewkfid)
    ON DELETE CASCADE
    ON UPDATE SET NULL) Engine=NDBCLUSTER;

-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.efile
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.efile (
  fileid INT NOT NULL AUTO_INCREMENT,
  actid INT NOT NULL,
  taskid INT NULL,
  ftemplate CHAR(1) NULL DEFAULT 'F',
  finstrumented CHAR(1) NULL DEFAULT 'F',
  fdir VARCHAR(500) NULL,
  fname VARCHAR(500) NULL,
  fsize BIGINT NULL,
  fdata DATETIME NULL,
  foper VARCHAR(20) NULL,
  fieldname VARCHAR(255) NULL,
  PRIMARY KEY (actid, fileid),
  INDEX e_file_actid (actid ASC),
  INDEX e_file_taskid (taskid ASC),
  UNIQUE INDEX efile_fileid (fileid ASC)) Engine=NDBCLUSTER;

-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.emachine
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.emachine (
  machineid INT NOT NULL AUTO_INCREMENT,
  hostname VARCHAR(250) NOT NULL,
  address VARCHAR(250) NULL,
  mflopspersecond DOUBLE NULL,
  type VARCHAR(250) NULL,
  financial_cost DOUBLE NULL,
  erank INT NULL,
  PRIMARY KEY (machineid)) Engine=NDBCLUSTER;

  -- ----------------------------------------------------------------------------
-- Table %=DBNAME%.eactivation
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.eactivation (
  taskid INT NOT NULL AUTO_INCREMENT,
  actid INT NOT NULL,
  machineid INT NOT NULL,
  processor INT NULL,
  exitstatus INT NULL,
  commandline VARCHAR(1024) NULL,
  workspace VARCHAR(150) NULL,
  failure_tries INT NULL,
  terr VARCHAR(250) NULL,
  tout VARCHAR(250) NULL,
  starttime DATETIME NULL,
  endtime DATETIME NULL,
  status varchar(20),
  extractor VARCHAR(1024) NULL,
  PRIMARY KEY (taskid, actid, machineid) USING HASH,
  UNIQUE KEY (taskid) USING HASH,
  UNIQUE KEY (taskid, actid) USING HASH,
  FOREIGN KEY (machineid)  REFERENCES %=DBNAME%.emachine (machineid) ON DELETE CASCADE  ON UPDATE SET NULL, 
  FOREIGN KEY (actid)  REFERENCES %=DBNAME%.eactivity (actid) ON DELETE CASCADE  ON UPDATE SET NULL
) 
Engine=NDBCLUSTER
PARTITION BY KEY(taskid, actid, machineid)
PARTITIONS %=NUMBER_OF_PARTITIONS%;
-- Number of slave machines in cluster

CREATE INDEX eactivation_index_actid_status ON %=DBNAME%.eactivation (actid, status, machineid) using btree  ;
-- hash index would be better, but up to this mysql cluster version we are using, it is not possible to create hash index on a non-unique composite field
	
-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.eperfeval
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.eperfeval (
  metric varchar(20) NULL,
  etime double NULL,
  machineid INT NULL,
  processor INT NULL,
  ewkfid INT NULL,
  taskid INT NULL,  
  provfunction varchar(100) NULL
 ) Engine=NDBCLUSTER;

-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.eworkflow
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.eworkflow (
  ewkfid INT NOT NULL AUTO_INCREMENT,
  tagexec VARCHAR(200) NOT NULL,
  expdir VARCHAR(150) NULL,
  wfdir VARCHAR(200) NULL,
  tag VARCHAR(200) NOT NULL,
  maximumfailures INT NULL,
  userinteraction CHAR(1) NULL DEFAULT 'F',
  reliability DOUBLE NULL,
  redundancy CHAR(1) NULL DEFAULT 'F',
  PRIMARY KEY (ewkfid)) Engine=NDBCLUSTER;


-- ----------------------------------------------------------------------------
-- Table %=DBNAME%.eworkflow
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS %=DBNAME%.cmapping (
  cmapid INT NOT NULL AUTO_INCREMENT,
  crelid INT NOT NULL,
  previousid int,
  nextid int, 
  FOREIGN KEY (crelid) REFERENCES %=DBNAME%.crelation(relid) ON DELETE CASCADE ON UPDATE SET NULL, 
  FOREIGN KEY (previousid) REFERENCES %=DBNAME%.cactivity(actid) ON DELETE CASCADE ON UPDATE SET NULL, 
  FOREIGN KEY (nextid) REFERENCES %=DBNAME%.cactivity(actid) ON DELETE CASCADE ON UPDATE SET NULL,  
  PRIMARY KEY (cmapid,crelid),
  UNIQUE INDEX cmapping_unique_id (cmapid ASC)
  ) Engine=NDBCLUSTER;
  
  
SET FOREIGN_KEY_CHECKS = 1;

