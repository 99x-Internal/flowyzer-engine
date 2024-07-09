### CLI

ENTRYPOINT ["/home/node/cli/bin/main"]:

This line sets the entry point for the Docker container. When the container starts, it will execute the main script located in the /home/node/cli/bin directory.

#### Metabase

- **run**
  - **Initializes** with an Axios instance (`api`) that is used to make HTTP requests to the Metabase API.
  - **fromConfig Method**:
    - **Static Method**: Creates a new instance of Metabase based on the provided configuration (`cfg`).
    - **Steps**: Retrieves a session token using the `sessionToken` method.
    - **Configures** an Axios instance (`api`) with the retrieved session token for subsequent API requests.
    - **Returns** a new Metabase instance initialized with the Axios instance.
  - **sessionToken Method**:
    - **Parameters**: Accepts `cfg` object containing Metabase configuration (url, username, password).
    - **Returns**: A promise resolving to the session token (`data.id`) if successful.
    - **Error Handling**: Uses `wrapApiError` to handle and wrap any errors encountered during the API call.
  - **forceSync Method**
    - **Sends** a POST request to the Metabase API endpoint (`database/2/sync_schema`).
    - **Returns** the response data upon success.
    - **Error Handling**: Uses `wrapApiError` to handle errors encountered during the API call.

#### Github

- **run**
  - **Repository Selection**: Fetches and prompts the user to select repositories if not provided.
  - **Airbyte Setup**: Configures an Airbyte source with the selected repositories and credentials.
  - **Sync Trigger**: Initiates and tracks the data sync process with Airbyte.
  - **Metabase Sync**: Forces a sync in Metabase to ensure filters are populated immediately.

#### Gitlab

- **run**
  - **Sets Start Date**: Calculates the start date based on the cutoff days.
  - **Project Selection**: Fetches and prompts the user to select projects if not provided.
    - Handles cases where no projects are found or selected.
  - **Airbyte Setup**: Configures an Airbyte source with the selected projects and credentials.
  - **Sync Trigger**: Initiates and tracks the data sync process with Airbyte.
  - **Metabase Sync**: Forces a sync in Metabase to ensure filters are populated immediately.

#### Jira

- **run**
  - **Token and Domain Handling**: Prompts the user for Jira domain, email, and token if not provided.
  - **Sets Start Date**: Calculates the start date based on the cutoff days.
  - **Project Selection**: Fetches and prompts the user to select projects if not provided.
    - Handles cases where no projects are found or selected.
  - **Airbyte Setup**: Configures an Airbyte source with the selected projects and credentials.
  - **Sync Trigger**: Initiates and tracks the data sync process with Airbyte.
  - **Metabase Sync**: Forces a sync in Metabase to ensure filters are populated immediately.

#### Refresh

- **run.ts**
  - Defines functionality for refreshing various data sources managed by the Airbyte client.
  - **runRefresh Function**
    - **Purpose**: Handles the logic for refreshing various data sources.
    - **Steps**:
      - Initializes an empty array `work` to store asynchronous tasks.
      - Checks the status of each data source (GitHub, GitLab, Bitbucket, Jira) using `isActiveConnection` method.
      - If a data source is active:
        - Displays a refresh message using emojis.
        - Pushes a refresh task (`cfg.airbyte.refresh`) into the `work` array.
      - If no data sources need refreshing (`work` array is empty), displays a message indicating "nothing to refresh".
      - If there are tasks in the `work` array, waits for all tasks to complete using `Promise.all`.
    - Leverages promises and asynchronous operations (`Promise.all`) to handle refreshing each data source concurrently when applicable.

```mermaid
sequenceDiagram
    participant User
    participant CLI
    participant Airbyte
    participant Metabase
    participant Github
    participant Gitlab
    participant Jira

    User ->> CLI: Initiates process

    CLI ->> Metabase: fromConfig(cfg)
    Metabase -->> CLI: Initialized with config

    CLI ->> Metabase: sessionToken(cfg)
    Metabase -->> CLI: Session token retrieved

    loop GitHub Sync Process
        CLI ->> Github: run(options)
        Github -->> CLI: Repository selection
        CLI ->> Airbyte: findFarosSource('GitHub')
        Airbyte -->> CLI: GitHub source ID retrieved
        CLI ->> Airbyte: setupSource(config)
        Airbyte -->> CLI: GitHub source setup succeeded
        CLI ->> Airbyte: findFarosConnection('GitHub - Faros')
        Airbyte -->> CLI: GitHub connection ID retrieved
        CLI ->> Airbyte: triggerAndTrackSync()
        Airbyte -->> CLI: GitHub sync job triggered
        CLI ->> Metabase: forceSync()
        Metabase -->> CLI: Metabase sync initiated
    end

    loop GitLab Sync Process
        CLI ->> Gitlab: run(options)
        Gitlab -->> CLI: Sets Start Date
        Gitlab -->> CLI: Project Selection
        CLI ->> Airbyte: findFarosSource('GitLab')
        Airbyte -->> CLI: GitLab source ID retrieved
        CLI ->> Airbyte: setupSource(config)
        Airbyte -->> CLI: GitLab source setup succeeded
        CLI ->> Airbyte: findFarosConnection('GitLab - Faros')
        Airbyte -->> CLI: GitLab connection ID retrieved
        CLI ->> Airbyte: triggerAndTrackSync()
        Airbyte -->> CLI: GitLab sync job triggered
        CLI ->> Metabase: forceSync()
        Metabase -->> CLI: Metabase sync initiated
    end

    loop Jira Sync Process
        CLI ->> Jira: run(options)
        Jira -->> CLI: Token and Domain Handling
        Jira -->> CLI: Sets Start Date
        Jira -->> CLI: Project Selection
        CLI ->> Airbyte: findFarosSource('Jira')
        Airbyte -->> CLI: Jira source ID retrieved
        CLI ->> Airbyte: setupSource(config)
        Airbyte -->> CLI: Jira source setup succeeded
        CLI ->> Airbyte: findFarosConnection('Jira - Faros')
        Airbyte -->> CLI: Jira connection ID retrieved
        CLI ->> Airbyte: triggerAndTrackSync()
        Airbyte -->> CLI: Jira sync job triggered
        CLI ->> Metabase: forceSync()
        Metabase -->> CLI: Metabase sync initiated
    end

    CLI ->> CLI: runRefresh(options)
    CLI ->> Airbyte: isActiveConnection('GitHub')
    Airbyte -->> CLI: GitHub connection status retrieved
    CLI ->> Airbyte: isActiveConnection('GitLab')
    Airbyte -->> CLI: GitLab connection status retrieved
    CLI ->> Airbyte: isActiveConnection('Bitbucket')
    Airbyte -->> CLI: Bitbucket connection status retrieved
    CLI ->> Airbyte: isActiveConnection('Jira')
    Airbyte -->> CLI: Jira connection status retrieved
    CLI ->> CLI: Display refresh messages
    CLI ->> CLI: Refresh each active connection concurrently
    CLI ->> Metabase: forceSync() for immediate filter update

    CLI -->> User: Process complete

```
