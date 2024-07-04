# File & Folder Structure

- flowyzer-init
  - Cannonical_Scema
  - Cli
  - Configs
  - dbt-transforms
  - flowyzer-metabase-queries
  - init
  - temporal

```mermaid
flowchart TD
    A[flowyzer-init]
    B[Cannonical_Scema]
    C[Cli]
    D[Configs]
    E[dbt-transforms]
    F[flowyzer-metabase-queries]
    G[init]
    H[temporal]

    A --> B
    A --> C
    A --> D
    A --> E
    A --> F
    A --> G
    A --> H
```

## /init/

- init
  - lib - contains all the compiled output files of the `src` folder's files
  - src
    - airbyte
      - contains all the initialization
      - initialization and setup of the Airbyte workspace
    - hasura
      - set up and manage the Hasura GraphQL engine by interacting with the Hasura API.
    - metabase
      - metabase.ts: Handles authentication and API interactions with Metabase, including dashboard operations.
      - dashboards.ts: Implements operations for managing Metabase dashboards, integrated with metabase.ts for API interactions and logging.
      - init.ts gets triggerd by entrypoint.sh with relevant commands.
  - resources
    - metabase
      - dashboards - all config files for metabase dashboards.
    - hasura - contains the hasura graphql queries and sql queries.
    - airbyte - contains connection config yaml files.
  - scripts - contains all the shell scripts (entypoint.sh, db-init.sh, metabase-init.sh)
  - test - unit tests

```mermaid
flowchart TD
    F[init]
    F1[lib - compiled ts files]
    F2[src]
    F3[resources]
    F4[scripts]
    F5[test - unit tests]

    F2_1[airbyte]
    F2_2[hasura]
    F2_3[metabase]

    F3_1[metabase]
    F3_2[airbyte]
    F3_2_1[config-yaml]
    F3_3[hasura]
    F3_3_1[endpoints]
    F3_4[dashboards]

    F4_1[db-init.sh]
    F4_2[metabase-init.sh]
    F4_3[entrypoint.sh]

    F --> F1
    F --> F2
    F --> F3
    F --> F4
    F --> F5
    F2 --> F2_1
    F2 --> F2_2
    F2 --> F2_3
    F3 --> F3_1
    F3 --> F3_2
    F3 --> F3_3
    F3_1 --> F3_4
    F3_2 --> F3_2_1
    F3_3 --> F3_3_1
    F4 --> F4_1
    F4 --> F4_2
    F4 --> F4_3
```

## /cli/

The cli directory contains scripts and functionality for integrating with various external services and managing data synchronization processes.

- src

  - cli.ts

  - Github

    - run
      - Repository Selection: Fetches and prompts the user to select repositories if not provided.
      - Airbyte Setup: Configures an Airbyte source with the selected repositories and credentials.

  - Gitlab

    - run
      - Project Selection: Fetches and prompts the user to select projects if not provided.
      - Airbyte Setup: Configures an Airbyte source with the selected projects and credentials.

  - jira

    - run
      - Airbyte Setup: Configures an Airbyte source with the selected projects and credentials.

  - metabase

    - run
      - fromConfig Method: Creates a new Metabase instance based on provided configuration.

  - refresh

    - run.ts
      - The refresh/run.ts file manages the refresh process for various data sources managed by Airbyte.
      - Checks and refreshes GitHub, GitLab, Bitbucket, and Jira connections.

  - utils
    - index
      - contains utility functions
    - prompts
      - contains interfaces and enums

```mermaid
flowchart TD
    F0[cli]
    F[src]
    F1[github]
    F2[gitlab]
    F3[jira]
    F4[metabase]
    F5[refresh]
    F6[utils]

    F1_1[run]
    F2_1[run]

    F3_1[run]

    F4_1[run]
    F5_1[run]

    F6_1[index]
    F6_2[prompts]

    F0 --> F

    F --> F1
    F1 --> F1_1
    F --> F2
    F --> F3
    F --> F4
    F --> F5
    F --> F6
    F2 --> F2_1
    F3 --> F3_1
    F4 --> F4_1
    F5 --> F5_1
    F6 --> F6_1
    F6 --> F6_2
```
