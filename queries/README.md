# Provenance queries

  - [Query 1](#query-1)
  - [Query 2](#query-2)
  - [Query 3](#query-3)
  - [Query 4](#query-4)
  - [Query 5](#query-5)
  - [Query 6](#query-6)
  - [Query 7](#query-7)
  
## Domain dataflow provenance queries

### Query 1
What is the average of the environmental conditions that are leading to the 10 greatest fatigue life values?

```sql

SELECT AVG(datagath.wind_speed), AVG(datagath.wave_freq), AVG(datagath.wave_height), AVG(datagath.wtr_temp), AVG(datagath.air_temp)
FROM
	dchiron.eactivation t,
	rfa.oDatagathering datagath,
	rfa.oPreprocessing preproc,
	rfa.oStressanalysis stress,
	rfa.oStressSriticalSaseSelection StSel,
	rfa.oCurvatureCriticalCaseSelection CvSel,
	rfa.oCalculateFatigueLife calcfatigue
WHERE
	datagath.previoustaskid = Idatagath.nexttaskid AND
	preproc.previoustaskid = datagath.nexttaskid AND
	stress.previoustaskid = preproc.nexttaskid AND
	StSel.previoustaskid = stress.nexttaskid AND
	CvSel.previoustaskid = StSel.nexttaskid AND
	calcfatigue.previoustaskid = CvSel.previoustaskid AND
	calcfatigue.fatigue_life IN (
		SELECT fatigue_life
		FROM rfa.calcfatigue 
		ORDER BY fatigue_life DESC
		LIMIT 10
	)

```

### Query 2
What are the float unit conditions that are leading to risers’ curvature lower than 800?

```sql
SELECT stress.fcurvature_val, datagath.funit_name, datagath.funit_status, datagath.funit_lat, datagath.funit_long, datagath.funit_type
	rfa.iDatagathering Idatagath,
	rfa.oDatagathering datagath,
	rfa.oPreprocessing preproc,
	rfa.oStressanalysis stress
WHERE
	datagath.previoustaskid = Idatagath.nexttaskid AND
	preproc.previoustaskid = datagath.nexttaskid AND
	stress.previoustaskid = preproc.nexttaskid AND
	stress.fcurvature_val < 800
ORDER BY stress.fcurvature_val 
LIMIT 10￼
```

### Query 3
What are the top 10 compressed data files (input for Activity 1) that contain original data that are leading to lowest fatigue life value (output from Activity 6)?

```sql
SELECT calcfatigue.fatigue_life, f.name, f.path, f.size, f.fieldname
	dchiron.eactivation t,
	rfa.iDatagathering Idatagath,
	rfa.oDatagathering datagath,
	rfa.oPreprocessing preproc,
	rfa.oStressanalysis stress,
	rfa.oStressSriticalSaseSelection StSel,
	rfa.oCurvatureCriticalCaseSelection CvSel,
	rfa.oCalculateFatigueLife calcfatigue
WHERE
	datagath.previoustaskid = Idatagath.nexttaskid AND
	preproc.previoustaskid = datagath.nexttaskid AND
	stress.previoustaskid = preproc.nexttaskid AND
	StSel.previoustaskid = stress.nexttaskid AND
	CvSel.previoustaskid = StSel.nexttaskid AND
	calcfatigue.previoustaskid = CvSel.previoustaskid AND
	calcfatigue.previoustaskid = t.taskid AND
	f.taskid =  t.taskid
ORDER BY calcfatigue.fatigue_life
LIMIT 10
```

## Integrating domain dataflow and performance data provenance queries

### Query 4
What are the histograms and finite element meshes files related when computed fatigue life based on stress analysis is lower than 60?

```sql
SELECT stress.stress_fatigue_val, mesh.name, mesh.path, mesh.size, hist.name, hist.path, hist.size
FROM
	dchiron.eactivation t,
	dchiron.efile mesh,
	dchiron.efile hist,
	rfa.oDatagathering datagath,
	rfa.oPreprocessing preproc,
	rfa.oStressanalysis stress
WHERE
	preproc.previoustaskid = datagath.nexttaskid AND
	stress.previoustaskid = preproc.nexttaskid AND
	stress.previoustaskid = t.taskid AND
	stress.stress_fatigue_val < 60 AND
	mesh.taskid = t.taskid AND
	mesh.fieldname = 'ELEM_MESH' AND
	hist.taskid = t.taskid AND
	hist.fieldname = 'HISTOGRAM'
ORDER BY stress.stress_fatigue_val, mesh.fieldname, hist.fieldname
```

### Query 5
Determine the average of each environmental conditions (output of Data Gathering – Activity 1) associated to the tasks that are taking execution time more than 1.5 the average of Curvature Critical Case Selection (Activity 5).

```sql
SELECT AVG(datagath.wind_speed), AVG(datagath.wave_freq), AVG(datagath.wave_height), AVG(datagath.wtr_temp), AVG(datagath.air_temp)
FROM
	dchiron.eactivation t,
	rfa.oDatagathering datagath,
	rfa.oPreprocessing preproc,
	rfa.oStressanalysis stress,
	rfa.oStressSriticalSaseSelection StSel,
	rfa.oCurvatureCriticalCaseSelection CvSel
WHERE
	preproc.previoustaskid = datagath.nexttaskid AND
	stress.previoustaskid = preproc.nexttaskid AND
	StSel.previoustaskid = stress.nexttaskid AND
	CvSel.previoustaskid = StSel.nexttaskid AND
	CvSel.previoustaskid = t.taskid AND
	(t.endtime-t.starttime) > (
		SELECT 1.5*AVG(endtime-starttime) 
		FROM dchiron.eactivation
		WHERE tag = 'CurvatureCriticalCaseSelection'
	)
```


### Query 6
Determine the finite element meshes files (output of Preprocessing – Activity 2) associated to the tasks that are finishing with error status.

```sql
SELECT f.name, f.path, f.size
FROM
	dchiron.emachine m,
	dchiron.eactivation t,
	dchiron.eactivity acti,
	dchiron.efile f
WHERE
	t.actid = acti.actid AND
	t.status = 'FINISHED_WITH_ERROR' AND
	f.taskid = t.taskid AND
	f.fieldname = 'ELEM_MESH' AND
	acti.tag = 'Preprocessing'
ORDER BY f.size DESC
```


### Query 7
List the 5 computing nodes with the greatest number of Preprocessing activity tasks that are consuming tuples that contain wind speed values greater than 70 Km/h.

```sql
SELECT m.hostname, COUNT(*)
FROM
	dchiron.emachine m,
	dchiron.eactivation t,
	dchiron.eactivity acti,
	rfa.odatagathering datagath
WHERE
	m.machineid = t.machineid AND
	t.actid = acti.actid AND
	acti.tag = 'Preprocessing' AND
	datagath.nexttaskid = t.taskid AND
	datagath.windspeed > 70
GROUP BY m.hostname
ORDER BY 2 DESC
LIMIT 5
```
