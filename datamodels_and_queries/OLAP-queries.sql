-- OLAP Queries for the user steering experiment

-- Q1
-- Considering just tasks that started from one minute ago to now, determine tasks status, number of tasks that started, finished, and the total number of failure tries ordered by node. 
select machineid, status, count(starttime) as started_tasks, count(endtime) as finished_tasks, sum(failure_tries) as failure_tries
from dchiron.eactivation
where starttime between date_sub(now(), interval 1 minute) and now() 
group by machineid, status
order by machineid, status
;

-- Q2
-- Given a node hostname, for each task, determine task status (e.g., finished or finished with error), the total size in bytes of the files consumed by the tasks that finished in the last minute. Order the results in descending order by bytes and ascending order by task status.
select a.status, sum(f.fsize) as total_bytes
from dchiron.eactivation a, dchiron.efile f, dchiron.emachine m
where m.hostname like '%stremi-1%'
and f.taskid = a.taskid
and f.actid = a.actid
and a.machineid = m.machineid
and a.endtime between date_sub(now(), interval 1 minute) and now() 
group by a. status
order by total_bytes desc, a. status asc
;

--Q3
-- Determine the node(s) (hostname(s)) with the greatest number of tasks aborted or finished with errors in the last minute.
select m.hostname
from dchiron.eactivation a, dchiron.emachine m 
where a.machineid = m.machineid 
and a.status in ('FINISHED_WITH_ERROR', 'ABORT') 
and a.endtime between date_sub(now(), interval 1 minute) and now() 
group by m.hostname
having count(*) = ( 
  select count(*) 
    from dchiron.eactivation a, dchiron.emachine m 
    where a.machineid = m.machineid 
    and a.status in ('FINISHED_WITH_ERROR', 'ABORT') 
    and a.endtime between date_sub(now(), interval 1 minute) and now() 
    group by m.hostname
    order by count(*) desc 
    limit 1 
) 
;

-- Q4
-- Given a workflow identification, show how many tasks are left to be executed.
select count(*)
from dchiron.cworkflow w, dchiron.eactivity ay, dchiron.eactivation an
where w.wkfid = ay.wkfid
and ay.actid = an.actid
and an.status = 'READY'
and w.tag = 'WfRFA-4'
;

-- Q5
-- Considering workflows that are running for more than one minute, determine the name(s) of the activity(ies) with the greatest number of unfinished tasks so far. Also, show the amount of such tasks.
select w.tag, ay.tag, count(*)
from dchiron.cworkflow w, dchiron.eactivity ay, dchiron.eactivation an
where w.wkfid = ay.wkfid
and ay.actid = an.actid
and date(ay.starttime) < date_sub(now(), interval 1 minute)
and ay.endtime is null
and an.status in ('BLOCKED', 'READY', 'RUNNING', 'PIPELINED')
group by w.tag, ay.tag
having count(*) = ( 
  select count(*) 
  from dchiron.cworkflow w, dchiron.eactivity ay, dchiron.eactivation an 
  where w.wkfid = ay.wkfid 
  and ay.actid = an.actid 
  and date(ay.starttime) < date_sub(now(), interval 1 minute) 
  and ay.endtime is null 
  and an.status in ('BLOCKED', 'READY', 'RUNNING', 'PIPELINED') 
  group by w.tag, ay.tag 
  order by count(*) DESC 
  limit 1 
)
;

-- Q6
-- Determine the average and maximum execution times of tasks finished for each activity not finished. Show the name of the activity and order by average and maximum time descending.
select ay.tag as Activity, avg(timediff(an.endtime , an.starttime)) as Average_Time, max( timediff(an.endtime , an.starttime) ) as Max_Time 
from dchiron.eactivity ay, dchiron.eactivation an
where ay.actid = an.actid
and ay.endtime is null
and an.status = 'FINISHED' 
group by ay.tag
order by Average_Time DESC, Max_Time DESC
;


-- Q7
-- PreProcessing activity produces cx, cy, cz and a file.
-- List above information when PreProcessing activity makes “CalculateWearAndTear” activity generate f1 > 0.5, but only when CalculateWearAndTear takes more than average to FINISH
select f.fname, f.fsize, taskCWT.failure_tries, P.cx, P.cy, P.cz, CWT.f1, timediff(taskCWT.endtime , taskCWT.starttime) as task_time
from wf1.oPreProcessing P, wf1.oCalculateWearAndTear CWT, wf1.oAnalyzeRisers R, dchiron.efile f, dchiron.eactivation taskPreProc, dchiron.eactivation taskCWT
where 
CWT.f1 > 0.5
and CWT.previoustaskid = R.nexttaskid
and R.previoustaskid = P.nexttaskid
and taskPreProc.taskid = P.previoustaskid
and taskCWT.taskid = CWT.previoustaskid
and taskCWT.status = 'FINISHED'
and taskCWT.failure_tries > 0
and taskPreProc.taskid = f.taskid
and timediff(taskCWT.endtime , taskCWT.starttime) >= ALL(
  select avg( timediff(an.endtime , an.starttime) ) 
  from dchiron.eactivation an 
  where an.actid = taskCWT.actid
  group by an.actid
)
order by task_time desc
;

-- Q8
-- modify output values from PreProcessing
update wf1.oPreProcessing P
inner join dchiron.eactivation an on
  P.nexttaskid = an.taskid
set P.cx = 0.381, P.cy = 0.4, P.cz = 0.2923 
where an.STATUS = 'READY'
;
