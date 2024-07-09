## Data transformation with DBT

##### Things to note:

- We currently does not do any data-transformation using dbt by default

- The env variables being passed to dbt are not configured in the .env

- If we want to run dbt transformations we should do manually enter `dbt-run` command

#### Steps to run Data Transformations

1. run dbt

```
cd dbt-transforms
dbt run
```

2. Find the Faros DB in Metabase and sync the database schema

#### Ex: Tasks creators transformation

In this example, we'll run a dbt transformation that results in a new table in our Postgres database.

This guide assumes that you have ingested task data. Otherwise, please follow our quickstart.

The [transformation code](../../dbt-transforms/models/custom_metrics/task_creators.sql) lives in the flowyzer-init repo.

It computes the number of tasks created per reporter by month/year and ranks the reporters according to the number of tasks created.

Running the dbt transformation
Export the Faros DB connection details and credentials. Please find the values in the .env file.

```
export DBT_HOST=<FAROS_DB_HOST in .env>
export DBT_PORT=<FAROS_DB_PORT in .env>
export DBT_USER=<FAROS_DB_USER in .env>
export DBT_PASS=<FAROS_DB_PASSWORD in .env>
export DBT_DBNAME=<FAROS_DB_NAME in .env>
```

Run the dbt transformation

```
cd dbt-transforms
dbt run
```

Alternatively, from the repository root, run:

```
cd init && npm i

node lib/metabase/init --metabase-url http://localhost:3000 \
--username $METABASE_USER \
--password $METABASE_PASSWORD \
--database $FAROS_DB_NAME \
--sync-schema
```
