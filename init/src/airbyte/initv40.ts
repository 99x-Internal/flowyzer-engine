import {AxiosInstance} from 'axios';
import * as fs from 'fs';
import * as yaml from 'js-yaml';
import {Dictionary} from 'lodash';
import path from 'path';
import pino from 'pino';
 
const logger = pino({
  name: 'airbytev40-init',
  customLevels: {
    debug: 35,
    info: 30,
    warn: 40,
    error: 50,
    fatal: 60
  },
  level: 'info',
});
 
import {BASE_RESOURCES_DIR} from '../config';
const CATALOGS = path.join(
  BASE_RESOURCES_DIR,
  'airbyte',
  'workspace',
  'airbyte_config',
  'STANDARD_SYNC.yaml'
);
const SOURCES = path.join(
  BASE_RESOURCES_DIR,
  'airbyte',
  'workspace',
  'airbyte_config',
  'SOURCE_CONNECTION.yaml'
);
 
const username = 'airbyte';
const password = 'password';
 
// Encode the username and password to base64
const basicAuth = 'Basic ' + Buffer.from(`${username}:${password}`).toString('base64');
 
// Function to load and parse a YAML file
function loadYamlFile(filePath: string): any {
  try {
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    const data = yaml.load(fileContent);
    return data;
  } catch (error) {
    console.error(`Error loading YAML file: ${error}`);
    return null;
  }
}
 
// Function to find an entry with a specific attribute value
function findEntryWithAttributeValue(
  data: any[],
  attribute: string,
  value: any
): any {
  return data.find((entry) => entry[attribute] === value);
}
 
function snakeCaseToCamelCase(snakeCaseStr: string): string {
  return snakeCaseStr.replace(/_([a-z])/g, (match, letter) =>
    letter.toUpperCase()
  );
}
 
function convertKeysToCamelCase(data: any): any {
  if (Array.isArray(data)) {
    return data.map(convertKeysToCamelCase);
  } else if (data !== null && typeof data === 'object') {
    const newData: {[key: string]: any} = {};
    for (const key in data) {
      const camelCaseKey = snakeCaseToCamelCase(key);
      newData[camelCaseKey] = convertKeysToCamelCase(data[key]);
    }
    return newData;
  }
  return data;
}
 
export class AirbyteInitV40 {
  private readonly api: AxiosInstance;
 
  constructor(api: AxiosInstance) {
    this.api = api;
  }
 
  async createWorkspace(params: {name: string}): Promise<string> {
    const response = await this.api.post('/workspaces/create', params);
    return response.data.workspaceId as string;
  }
 
  async getWorkspaceBySlug(params: {slug: string}): Promise<string> {
    const response = await this.api.post('/workspaces/get_by_slug', params);
    return response.data.workspaceId as string;
  }
 
  async getFirstWorkspace(): Promise<string> {
    const response = await this.api.post('/workspaces/list', {});
    return response.data.workspaces[0].workspaceId as string;
  }
 
  // extra settings appear to be needed
  async completeWorkspaceSetup(params: {
    workspaceId: string;
    initialSetupComplete: boolean;
    anonymousDataCollection: boolean;
    news: boolean;
    securityUpdates: boolean;
  }): Promise<string> {
    const response = await this.api.post('/workspaces/update', params);
    return response.data.initialSetupComplete as string;
  }
 
  async createCustomSourceDefinition(params: {
    workspaceId: string;
    sourceDefinition: {
      name: string;
      dockerRepository: string;
      dockerImageTag: string;
      documentationUrl: string;
    };
  }): Promise<string> {
    const response = await this.api.post(
      '/source_definitions/create_custom',
      params
    );
    return response.data.sourceDefinitionId as string;
  }
 
  async createCustomDestinationDefinition(params: {
    workspaceId: string;
    destinationDefinition: {
      name: string;
      dockerRepository: string;
      dockerImageTag: string;
      documentationUrl: string;
    };
  }): Promise<string> {
    const response = await this.api.post(
      '/destination_definitions/create_custom',
      params
    );
    return response.data.destinationDefinitionId as string;
  }
 
  async createSource(params: {
    sourceDefinitionId: string;
    connectionConfiguration: Dictionary<any>;
    workspaceId: string;
    name: string;
  }): Promise<string> {
    const response = await this.api.post('/sources/create', params);
    return response.data.sourceId as string;
  }
 
  async createDestination(params: {
    destinationDefinitionId: string;
    connectionConfiguration: Dictionary<any>;
    workspaceId: string;
    name: string;
  }): Promise<string> {
    const response = await this.api.post('/destinations/create', params);
    return response.data.destinationId as string;
  }
 
  async listDestinationNames(params: {workspaceId: string}): Promise<string[]> {
    const response = await this.api.post('/destinations/list', params);
    return response.data.destinations.map(
      (destination: any) => destination.name
    ) as string[];
  }
 
  async getCatalog(params: {sourceId: string}): Promise<Dictionary<any>> {
    const response = await this.api.post('/sources/discover_schema', params);
    return response.data.catalog;
  }
 
  async createConnection(params: {
    name: string;
    prefix: string;
    sourceId: string;
    destinationId: string;
    syncCatalog: Dictionary<any>;
    status: string;
  }): Promise<string> {
    const response = await this.api.post('/connections/create', params);
    return response.data.connectionId as string;
  }
 
  async completeFarosWorkspaceSetup(workspaceId: string): Promise<string> {
    return await this.completeWorkspaceSetup({
      workspaceId,
      initialSetupComplete: true,
      anonymousDataCollection: false,
      news: false,
      securityUpdates: false,
    });
  }
 
  async createFarosDestinationDefinition(
    workspaceId: string,
    version: string
  ): Promise<string> {
    return await this.createCustomDestinationDefinition({
      workspaceId,
      destinationDefinition: {
        name: 'Faros Destination',
        dockerRepository: 'farosai/airbyte-faros-destination',
        dockerImageTag: version,
        documentationUrl: 'https://docs.faros.ai',
      },
    });
  }
 
  async createFarosDestination(
    workspaceId: string,
    farosDestinationDefinitionId: string,
    hasura_url: string,
    hasura_admin_secret: string,
    segment_user_id: string
  ): Promise<string> {
    return await this.createDestination({
      workspaceId,
      destinationDefinitionId: farosDestinationDefinitionId,
      name: 'Faros Destination',
      connectionConfiguration: {
        dry_run: false,
        jsonata_mode: 'FALLBACK',
        edition_configs: {
          edition: 'community',
          hasura_url,
          hasura_admin_secret,
          segment_user_id,
        },
        invalid_record_strategy: 'SKIP',
      },
    });
  }
 
  async getFarosDestinationId(workspaceId: string): Promise<string> {
    return (await this.listDestinationNames({workspaceId})).filter(
      (name: string) => name === 'Faros Destination'
    )[0];
  }
 
  async createSourceFromYAML(
    workspaceId: string,
    yamlData: any,
    sourceName: string,
    sourceDefinitionId: string
  ): Promise<string> {
    const source = findEntryWithAttributeValue(yamlData, 'name', sourceName);
 
    return await this.createSource({
      workspaceId,
      sourceDefinitionId,
      name: source.name,
      connectionConfiguration: source.configuration,
    });
  }
 
  async createConnectionToFaros(
    sourceId: string,
    farosDestinationId: string,
    yamlData: any,
    connectionName: string
  ): Promise<string> {
    const connection = findEntryWithAttributeValue(
      yamlData,
      'name',
      connectionName
    );
    const streams: any[] = connection.catalog.streams;
    const streamsWithConfig = streams.map((stream) => {
      const streamWithConfig = {...stream};
      streamWithConfig.config = {
        syncMode: stream.syncMode,
        cursorField: stream.cursorField,
        destinationSyncMode: stream.destinationSyncMode,
        primaryKey: stream.primaryKey,
        selected: true,
      };
 
      delete streamWithConfig.syncMode;
      delete streamWithConfig.cursorField;
      delete streamWithConfig.destinationSyncMode;
      delete streamWithConfig.primaryKey;
      // removing it completely causes the sync to not start
      streamWithConfig.stream.jsonSchema = {};
      return streamWithConfig;
    });
 
    return await this.createConnection({
      name: connection.name,
      sourceId,
      destinationId: farosDestinationId,
      syncCatalog: {
        streams: streamsWithConfig,
      },
      prefix: connection.prefix,
      status: connection.status,
    });
  }
 
  async handleFarosSource(
    name: string,
    workspaceId: string,
    farosDestinationId: string,
    farosConnectorsVersion: string,
    yamlSourceData: any,
    yamlCatalogData: any
  ): Promise<void> {
    const sourceDefinitionId = await this.createCustomSourceDefinition({
      workspaceId,
      sourceDefinition: {
        name,
        dockerRepository: 'farosai/airbyte-' + name.toLowerCase() + '-source',
        dockerImageTag: farosConnectorsVersion,
        documentationUrl: 'https://docs.faros.ai',
      },
    });
    logger.info('sourceDefinitionId for ' + name + ': ' + sourceDefinitionId);
 
    await this.createAndConnectSource(
      name,
      workspaceId,
      farosDestinationId,
      yamlSourceData,
      yamlCatalogData,
      sourceDefinitionId
    );
  }
 
  async createAndConnectSource(
    name: string,
    workspaceId: string,
    farosDestinationId: string,
    yamlSourceData: any,
    yamlCatalogData: any,
    sourceDefinitionId: string
  ): Promise<void> {
    const sourceId = await this.createSourceFromYAML(
      workspaceId,
      yamlSourceData,
      name,
      sourceDefinitionId
    );
    logger.info('sourceId for ' + name + ': ' + sourceId);
 
    const connectionId = await this.createConnectionToFaros(
      sourceId,
      farosDestinationId,
      yamlCatalogData,
      name + ' - Faros'
    );
    logger.info('connectionId for ' + name + ': ' + connectionId);
  }
 
  async addWorkItemsConnector(workspaceId: string) {
    try {
        const response = await this.api.post('/source_definitions/create_custom', {
            workspaceId: `${workspaceId}`,
            sourceDefinition: {
                name: "azure-workitems-source-99x",
                documentationUrl: "",
                dockerImageTag: "0.2.02-candidate",
                dockerRepository: "bksdrodrigo/azure-workitems-source-99x"
            }
        }, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });
        console.log('Response:', response.data);
        return response.data.sourceDefinitionId;
    } catch (error) {
        console.error('Error:', error);
        // You can return an error value or rethrow the error depending on your needs
        throw error;
    }
  }
 
 
  async addAzureReposConnector(workspaceId: string) {
    try {
        const response = await this.api.post('/source_definitions/create_custom', {
            workspaceId: `${workspaceId}`,
            sourceDefinition: {
              name: "azure-repos-source-99x",
              documentationUrl: "",
              dockerImageTag: "0.2.02-candidate",
              dockerRepository: "bksdrodrigo/azure-repos-source-99x"
            }
          }, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });
        console.log('Response:', response.data);
        return response.data.sourceDefinitionId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
  }
 
  async createFlowyzerDestination(workspaceId: string) {
    try {
        const response = await this.api.post('/destination_definitions/create_custom', {
          workspaceId: `${workspaceId}`,
          destinationDefinition: {
            name: "airbyte-faros-destination-99x",
            documentationUrl: "",
            dockerImageTag: "0.2.02-candidate",
            dockerRepository: "bksdrodrigo/airbyte-faros-destination-99x"
          }
        }, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });
        console.log('Response:', response.data);
        return response.data;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
  }
 
  async checkConnectorsExist(workspaceId: string) {
    try {
        const response = await this.api.post('/source_definitions/list', {}, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });
 
        // console.log('Response:', response.data);
 
        // Extract the source definitions from the response
        const sourceDefinitions = response.data.sourceDefinitions;
 
        // Check if the desired sources exist
        const azureReposExists = sourceDefinitions.some((source: { name: string; }) => source.name === 'azure-repos-source-99x');
        const azureWorkitemsExists = sourceDefinitions.some((source: { name: string; }) => source.name === 'azure-workitems-source-99x');
 
        // If either source doesn't exist, run the createWorkitems function
        if (!azureReposExists || !azureWorkitemsExists) {
            console.log('One or both of the sources do not exist. Creating them...');
            await this.addWorkItemsConnector(workspaceId).then((workItemsDefId) => {
              return this.createSourceWorkItems(workspaceId, workItemsDefId);
            });
            await this.addAzureReposConnector(workspaceId).then((azureReposDefId) => {
              return this.createSourceAzureRepo(workspaceId, azureReposDefId);
            });
        } else {
            console.log('Both sources exist.');
        }
 
        return response.data;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
  }
 
  async checkDestinationExist(workspaceId: string) {
    try {
        const response = await this.api.post('/destination_definitions/list', {}, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });
 
        // console.log('Response:', response.data);
 
        // Extract the source definitions from the response
        const destinationDefinitions = response.data.destinationDefinitions;
 
        const farosDestination = destinationDefinitions.some((destination: { name: string; }) => destination.name === 'airbyte-faros-destination-99x');
 
        if (!farosDestination) {
            console.log('Destination doesnt exist. Creating them...');
            await this.createFlowyzerDestination(workspaceId);
        } else {
            console.log('Destination exists.');
        }
 
        return response.data;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
  }
 
  async getWorkspace(): Promise<string> {
    try {
        const response = await this.api.post('/workspaces/list', {}, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });
 
        console.log('Response:', response.data);
 
        // Return the workspaceId of the first workspace
        return response.data.workspaces[0].workspaceId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
  }
 
  async createSourceAzureRepo(workspaceId: string, sourceDefId: string): Promise<string> {
    try {
      const response = await this.api.post('/sources/create', {
          name: "Flowyzer-AzureRepoSource-BUS",
          sourceDefinitionId: `${sourceDefId}`,
          workspaceId: `${workspaceId}`,
          connectionConfiguration: {
              api_url: "https://dev.azure.com",
              page_size: 100,
              api_version: "7.0",
              cutoff_days: 90,
              max_retries: 3,
              graph_api_url: "https://vssps.dev.azure.com",
              graph_version: "7.1-preview.1",
              branch_pattern: ".*",
              request_timeout: 60000,
              reject_unauthorized: false,
              organization: "BUS-AS-Norway",
              access_token: `${process.env.AZURE_DEVOPS_PAT}`,
              projects: ["BUS"]
          }
      }, {
          headers: {
              'Authorization': basicAuth,
              'Content-Type': 'application/json'
          }
      });
 
      console.log('Response:', response.data.sourceId);
      return response.data.sourceId;
  } catch (error) {
      console.error('Error:', error);
      throw error;
  }
  }
 
 
  async createSourceWorkItems(workspaceId: string, sourceDefId: string): Promise<string> {
    try {
      const response = await this.api.post('/sources/create', {
          name: "Flowyzer-AzureRepoWorkitem-BUS",
          sourceDefinitionId: `${sourceDefId}`,
          workspaceId: `${workspaceId}`,
          connectionConfiguration: {
            api_version: "7.1",
            cutoff_days: 90,
            graph_version: "7.1-preview.1",
            request_timeout: 60000,
            organization: "BUS-AS-Norway",
            access_token: `${process.env.AZURE_DEVOPS_PAT}`,
            projects: [
                "BUS"
            ]
          }
      }, {
          headers: {
              'Authorization': basicAuth,
              'Content-Type': 'application/json'
          }
      });
 
      console.log('Response:', response.data.sourceId);
      return response.data.sourceId;
  } catch (error) {
      console.error('Error:', error);
      throw error;
  }
  }
 
 
  async init(
    farosConnectorsVersion: string,
    hasuraUrl: string,
    hasuraAdminSecret: string,
    segmentUserId: string
  ): Promise<void> {
    logger.info('init');
 
    const workspaceId = await this.getWorkspace()
    console.log('This is workspace id ', workspaceId)
    await this.checkConnectorsExist(workspaceId);
    await this.checkDestinationExist(workspaceId);
 
    // const workspaceId = await this.getFirstWorkspace();
    logger.info('workspaceId: ' + workspaceId);
    await this.completeFarosWorkspaceSetup(workspaceId);
 
    const farosDestinationDefintionId =
      await this.createFarosDestinationDefinition(
        workspaceId,
        farosConnectorsVersion
      );
    logger.info('farosDestinationDefintionId: ' + farosDestinationDefintionId);
 
    const farosDestinationId = await this.createFarosDestination(
      workspaceId,
      farosDestinationDefintionId,
      hasuraUrl,
      hasuraAdminSecret,
      segmentUserId
    );
    logger.info('farosDestinationId: ' + farosDestinationId);
 
    // do NOT converstion to camel case
    const yamlSourceData = loadYamlFile(SOURCES);
 
    // convert to camel case because of sync_mode (file) vs syncMode (API)
    const yamlCatalogData = convertKeysToCamelCase(loadYamlFile(CATALOGS));
 
    const communitySources = [
      ['GitHub', 'ef69ef6e-aa7f-4af1-a01d-ef775033524e'],
      ['GitLab', '5e6175e5-68e1-4c17-bff9-56103bbb0d80'],
      ['Jira', '68e63de2-bb83-4c7e-93fa-a8a9051e3993'],
    ];
    for (const communitySource of communitySources) {
      logger.info(
        'sourceDefinitionId for ' +
          communitySource[0] +
          ': ' +
          communitySource[1] +
          ' (community)'
      );
      await this.createAndConnectSource(
        communitySource[0],
        workspaceId,
        farosDestinationId,
        yamlSourceData,
        yamlCatalogData,
        communitySource[1]
      );
    }
 
    const farosSources = [
      'Bitbucket',
      'Phabricator',
      'Buildkite',
      'CircleCI',
      'Harness',
      'Jenkins',
      'Datadog',
      'OpsGenie',
      'PagerDuty',
      'SquadCast',
      'Statuspage',
      'VictorOps',
    ];
    for (const farosSource of farosSources) {
      await this.handleFarosSource(
        farosSource,
        workspaceId,
        farosDestinationId,
        farosConnectorsVersion,
        yamlSourceData,
        yamlCatalogData
      );
    }
  }
}
 
 