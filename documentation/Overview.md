# Flowyzer Engine Overview

- **[How Floyzer Starts](./starting_flow.md)**

- **[Folder Structure](./folder-overview/folder_structure.md)**

## ⚙️ System Components

- **[Airbyte](./system-components-overview/airbyte.md)**: Data integration platform for importing data from a [variety of sources](https://github.com/faros-ai/airbyte-connectors) (even [more sources](https://github.com/airbytehq/airbyte/tree/master/airbyte-integrations/connectors))

- **[Hasura](./system-components-overview/metabase.md)**: GraphQL engine that makes your data accessible over a real-time GraphQL API

- **[Metabase](./system-components-overview/metabase.md)**: Business Intelligence (BI) tool for generating metrics and rendering charts and dashboards from your data

- **[dbt](./system-components-overview/Data-transformation-dbt.md)**: Data transformations to convert raw data into usable metrics
- **[n8n](https://n8n.io/)**: Extendable workflow automation of top of your data
- **[PostgreSQL](https://www.postgresql.org)**: Stores all the your data in canonical representation
- **[Docker](https://www.docker.com)**: Container runtime to run the services
- **[Flyway](https://flywaydb.org)**: Schema evolution for the database schema
- **[Faros Events CLI](https://github.com/faros-ai/faros-events-cli)**: CLI for reporting events to Faros platform, e.g builds & deployments from your CI/CD pipelines
