# d-Chiron Repository
Welcome to d-Chiron repository. d-Chiron is a Scientific Workflow Management System with parallel capabilities that manages complex data-intensive workflows and registers data provenance at runtine to enable user steering and human-in-the-loop. d-Chiron utilizes MySQL Cluster as its core in-memory distributed data structure used for managing execution, provenance, and domain dataflow data.

# Contents

In this repository, you find what is necessary to execute d-Chiron either in a cluster or standalone. d-Chiron data models and provenance data interactive queries are provided. The code for Risers Fatigue Analysis (RFA), a synthetic workflow based on a real case study in the oil & gas industry, is available. The workflow modeled and ready to be tested is avaiable. 

- [d-Chiron](d-chiron) 
- [Data models and OLAP queries](datamodels-and-queries/) 
    - [PROV-Df data model](datamodels-and-queries/PROV-Df.png)
    - [d-Chiron's Relational schema](datamodels-and-queries/relational-database-schema-dChiron-RFA.png) 
    - [Provenance interactive queries](datamodels-and-queries/OLAP-queries.sql)
- [Risers Fatigue Analysis synthetic workflow](rfa-synthetic)
    - [RFA activites](rfa-synthetic/rfa-activities)
