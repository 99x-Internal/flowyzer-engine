## DBT-Transforms

#### Step-by-Step Workflow

1. **Docker Initiates dbt:**

   - The docker container starts the dbt process by running dbt commands (e.g., `dbt run`).

2. **Load Connection Profiles:**

   - dbt reads the `profiles.yml` file to load the database connection profiles. This file contains the necessary credentials and configurations to connect to the databases.

3. **Connect to Source Database:**

   - Using the connection details from `profiles.yml`, dbt establishes a connection to the source database where the raw data resides.

4. **Load Project Configurations:**

   - dbt reads the `dbt_project.yml` file to load the project configurations. This file defines the project's structure and settings.

5. **Execute Custom Incremental Materialization:**

   - dbt runs the custom incremental materialization script located in `macros/incremental.sql`. This script handles the incremental loading of data, ensuring that only new or changed data is processed.

6. **Load Source Definitions:**

   - dbt reads the `models/sources.yml` file to load the source definitions. This file specifies the raw data tables that dbt will reference in its transformations.

7. **Query Raw Data Tables:**

   - dbt queries the raw data tables in the source database based on the definitions in `sources.yml`.

8. **Execute Base Task Transformations:**

   - dbt executes the SQL transformations defined in `models/custom_metrics/base/base_task.sql`. This script standardizes and prepares the raw task data.

9. **Execute Base Build Transformations:**

   - dbt runs the SQL transformations in `models/custom_metrics/base/base_build.sql`, standardizing and preparing the raw build data.

10. **Execute Base Pipeline Transformations:**

    - dbt executes the SQL transformations in `models/custom_metrics/base/base_pipeline.sql`, standardizing and preparing the raw pipeline data.

11. **Execute Incident Model Transformations:**

    - dbt processes the `models/custom_metrics/incident.sql` file to transform incident-related data. This involves applying the incremental materialization strategy and handling specific columns to ignore.

12. **Execute Deployment Model Transformations:**

    - dbt runs the `models/custom_metrics/deployment.sql` file to transform deployment-related data, using the incremental materialization strategy and handling specific columns to ignore.

13. **Execute Task Creators Model Transformations:**

    - dbt processes the `models/custom_metrics/task_creators.sql` file, which ranks task creators by the number of tasks created each month and year.

14. **Validate Model Schemas:**

    - dbt reads the `models/custom_metrics/schema.yml` file to validate the schemas of the models. This step ensures data quality by applying tests and checks on the model columns.

15. **Load Transformed Data into Target Tables:**

    - dbt loads the transformed data into the target tables in the target database. This step involves inserting, updating, or merging data as specified by the transformations.

16. **Transformation Complete:**
    - dbt completes the transformation process and informs the user that the data transformation is done.
