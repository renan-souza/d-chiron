-- ---------
-- FUNCTIONS --
-- --------

DELIMITER //

DROP FUNCTION IF EXISTS %=DBNAME%.f_emachine //
CREATE FUNCTION %=DBNAME%.f_emachine(v_machineid integer, v_hostname VARCHAR(255), v_address VARCHAR(60), v_mflopspersecond double, v_type VARCHAR(60), v_financial_cost double, v_rank integer) RETURNS integer
begin
   declare d_machineid integer;
   select v_machineid into d_machineid;
   if (coalesce(v_machineid, 0) = 0) then
      insert into emachine(hostname, address, mflopspersecond, type, financial_cost, erank) values(v_hostname, v_address, v_mflopspersecond, v_type, v_financial_cost, v_rank);
      set d_machineid = LAST_INSERT_ID();
   else
      update emachine set hostname = v_hostname, address = v_address, mflopspersecond = v_mflopspersecond, type = v_type, financial_cost = v_financial_cost, erank = v_rank where machineid = d_machineid;
   end if;
   return d_machineid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_activation //
CREATE FUNCTION %=DBNAME%.f_activation(v_taskid integer, v_actid integer, v_machineid integer, v_processor integer, v_exitstatus integer, v_commandline VARCHAR(1024), v_workspace VARCHAR(255), v_failure_tries integer, v_terr text, v_tout text, v_starttime timestamp, v_endtime timestamp, v_status VARCHAR(100), v_extractor text, isInsertOrUpdate integer) RETURNS integer
begin
	declare d_taskid integer;
	select v_taskid into d_taskid;
	if (isInsertOrUpdate = 1) then
		if (coalesce(d_taskid, 0) = 0) then
			insert into eactivation(taskid, actid, machineid, processor, exitstatus, commandline, workspace, failure_tries, terr, tout, starttime, endtime, status, extractor) values(d_taskid, v_actid, v_machineid, v_processor, v_exitstatus, v_commandline, v_workspace, v_failure_tries, v_terr, v_tout, v_starttime, v_endtime, v_status, v_extractor);
			set d_taskid = LAST_INSERT_ID();
		else
			update eactivation set actid = v_actid, machineid = v_machineid, processor = v_processor, exitstatus = v_exitstatus, commandline = v_commandline, workspace = v_workspace, failure_tries = v_failure_tries, terr = v_terr, tout = v_tout, starttime = v_starttime, endtime = v_endtime, status = v_status, extractor = v_extractor where taskid = d_taskid;
		end if;
	else
		update eactivation set actid = v_actid, machineid = v_machineid, processor = v_processor, exitstatus = v_exitstatus, commandline = v_commandline, workspace = v_workspace, failure_tries = v_failure_tries, terr = v_terr, tout = v_tout, starttime = v_starttime, endtime = v_endtime, status = v_status, extractor = v_extractor where taskid = d_taskid;
	end if;
	return d_taskid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_activity //
CREATE FUNCTION %=DBNAME%.f_activity(v_actid integer, v_wkfid integer, v_tag VARCHAR(255), v_status VARCHAR(100), v_starttime timestamp, v_endtime timestamp, v_cactid integer, v_templatedir VARCHAR(255), v_constrained VARCHAR(100) ) RETURNS integer
begin
declare d_actid integer;
 select v_actid into d_actid;
 if (coalesce(d_actid, 0) = 0) then	
	insert into eactivity(actid, wkfid, tag, status, starttime, endtime, cactid, templatedir, constrained) values(d_actid, v_wkfid, v_tag, v_status, v_starttime, v_endtime, v_cactid, v_templatedir, v_constrained);
	set d_actid = LAST_INSERT_ID();
 else 
   update eactivity set status = v_status, starttime = v_starttime, endtime = v_endtime, templatedir = v_templatedir, constrained = v_constrained where actid = d_actid;
 end if;
 return d_actid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_cactivity //
CREATE FUNCTION %=DBNAME%.f_cactivity(v_actid integer, v_wkfid integer, v_tag VARCHAR(255), v_atype VARCHAR(255), v_description VARCHAR(1024), v_activation VARCHAR(1024), v_extractor VARCHAR(1024), v_templatedir VARCHAR(1024)) RETURNS integer
begin
declare d_actid integer;

 select v_actid into d_actid;
 if (coalesce(d_actid, 0) = 0) then
    insert into cactivity(actid, wkfid, tag, atype, description, activation, extractor, templatedir) values(d_actid, v_wkfid, v_tag, v_atype, v_description, v_activation, v_extractor, v_templatedir);
	set d_actid = LAST_INSERT_ID();
 else 
   update cactivity set atype = v_atype, description = v_description, templatedir = v_templatedir, activation = v_activation, extractor = v_extractor where actid = d_actid;
 end if;
 return d_actid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_crelation //
CREATE FUNCTION %=DBNAME%.f_crelation(v_wkfid integer, v_rtype VARCHAR(255), v_rname VARCHAR(255)) RETURNS integer
begin
declare d_relid integer;
	insert into crelation(wkfid, relid, rtype, rname) values (v_wkfid, d_relid, v_rtype, v_rname);
	set d_relid = LAST_INSERT_ID();
	return d_relid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_cworkflow //
CREATE FUNCTION %=DBNAME%.f_cworkflow(v_wkfid integer, v_tag VARCHAR(255), v_description VARCHAR(255)) RETURNS integer
begin
declare d_wkfid integer;
 select v_wkfid into d_wkfid;
 if (coalesce(d_wkfid, 0) = 0) then
	insert into cworkflow(wkfid, tag, description) values(d_wkfid, v_tag, v_description);
	set d_wkfid = LAST_INSERT_ID();
 end if;
 return d_wkfid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_del_workflow //
CREATE FUNCTION %=DBNAME%.f_del_workflow(v_tagexec VARCHAR(255)) RETURNS integer
begin
    update eworkflow set tag = 'lixo' where tagexec = v_tagexec;
	return 0;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_del_workflows //
CREATE FUNCTION %=DBNAME%.f_del_workflows(v_tag VARCHAR(255)) RETURNS integer
begin

	delete from %=DBNAME%.efile where exists ( select * from %=DBNAME%.eactivity a, %=DBNAME%.eworkflow w where a.actid = efile.actid	and a.wkfid = w.wkfid and w.tag = v_tag );

	delete from %=DBNAME%.eactivation where actid in ( select a.actid from %=DBNAME%.eactivity a, %=DBNAME%.eworkflow w where a.wkfid = w.wkfid and w.tag = v_tag );
	
	delete from %=DBNAME%.efield where actid in ( select actid from %=DBNAME%.eactivity a, %=DBNAME%.eworkflow w where a.wkfid = w.wkfid and w.tag = v_tag );

	delete from %=DBNAME%.erelation where actid in ( select actid from %=DBNAME%.eactivity a, %=DBNAME%.eworkflow w where a.wkfid = w.wkfid and w.tag = v_tag ); 
	
	delete from %=DBNAME%.eactivity where wkfid in ( select w.wkfid from %=DBNAME%.eworkflow w where w.tag = v_tag );


	delete from %=DBNAME%.eworkflow where tag = v_tag;
 return 0;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_file //
CREATE FUNCTION %=DBNAME%.f_file(v_fileid integer, v_actid integer, v_taskid integer, v_ftemplate CHAR(1), v_finstrumented CHAR(1), v_fdir VARCHAR(500), v_fname VARCHAR(500), v_fsize integer, v_fdata timestamp, v_foper VARCHAR(20), v_fieldname VARCHAR(255)) RETURNS integer
begin
declare d_fileid integer;

    select v_fileid into d_fileid;
if (coalesce(d_fileid, 0) = 0) then
	insert into efile(fileid, actid, taskid, fdir, fname, fsize, fdata, ftemplate, finstrumented, foper, fieldname) values(d_fileid, v_actid, v_taskid, v_fdir, v_fname, v_fsize, v_fdata, v_ftemplate, v_finstrumented, v_foper, v_fieldname);
	set d_fileid = LAST_INSERT_ID();
end if;	
-- else 
-- 	update efile set ftemplate = v_ftemplate, finstrumented = v_finstrumented, fdir = v_fdir, fname = v_fname, fsize = v_fsize, fdata = v_fdata where fileid = d_fileid;
-- end if;
return d_fileid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_relation //
CREATE FUNCTION %=DBNAME%.f_relation(v_relid integer, v_actid integer, v_rtype VARCHAR(255), v_rname VARCHAR(255), v_filename VARCHAR(255)) RETURNS integer
begin
declare d_relid integer;

 select v_relid into d_relid;
 if (d_relid is null) then
	insert into erelation(relid, actid, rtype, rname, filename) values(d_relid, v_actid, v_rtype, v_rname, v_filename);
	set d_relid = LAST_INSERT_ID();
 end if;
 return d_relid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_workflow //
CREATE FUNCTION %=DBNAME%.f_workflow(v_wkfid integer, v_tag VARCHAR(255), v_tagexec VARCHAR(255), v_expdir VARCHAR(255), v_wfdir VARCHAR(255), v_maximumfailures integer, v_userinteraction VARCHAR(255), v_reliability double precision, v_redundancy VARCHAR(255)) RETURNS integer
begin
declare d_wkfid integer;

 select v_wkfid into d_wkfid;
 if (coalesce(d_wkfid, 0) = 0) then
	insert into eworkflow(ewkfid, tag, tagexec, expdir, wfdir, maximumfailures, userinteraction, reliability, redundancy) values(d_wkfid, v_tag, v_tagexec, v_expdir, v_wfdir, v_maximumfailures, v_userinteraction, v_reliability, v_redundancy);
	set d_wkfid = LAST_INSERT_ID();
 end if;
 return d_wkfid;
end;
//

DROP FUNCTION IF EXISTS %=DBNAME%.f_cmapping //
CREATE FUNCTION %=DBNAME%.f_cmapping(v_relid integer,v_previousid integer, v_nextid integer) RETURNS integer
begin
 declare d_cmapid integer;
 insert into cmapping(cmapid, crelid,previousid, nextid) values (d_cmapid, v_relid,v_previousid,v_nextid);
 set d_cmapid = LAST_INSERT_ID();
 return d_cmapid;
end;
//


DELIMITER ;



