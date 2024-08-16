import {AxiosInstance} from 'axios';
import {Dictionary} from 'lodash';
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
 

let workItemsDefId: string;
let azureReposDefId: string;
let destinationDefId: string;


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
 
  async checkConnectorsExist(workspaceId: string) {
    try {
        const response = await this.api.post('/source_definitions/list', {},); 
        const sourceDefinitions = response.data.sourceDefinitions;
 
        const azureWorkitemsExists = sourceDefinitions.some((source: { name: string; }) => source.name === 'azure-workitems-source-99x');

        const azureReposExists = sourceDefinitions.some((source: { name: string; }) => source.name === 'azure-repos-source-99x');
 
        // If either source doesn't exist, run the createWorkitems function
        if (!azureWorkitemsExists) {
          console.log('WorkItems Connector doesnt exist. Adding source connector...');

          const sourceDefinition = {
            name: "azure-workitems-source-99x",
            dockerRepository: "bksdrodrigo/azure-workitems-source-99x",
            dockerImageTag: "0.2.02-candidate",
            documentationUrl: ""
          }

          workItemsDefId = await this.createCustomSourceDefinition({
            workspaceId,
            sourceDefinition
          });

          console.log('WorkItems Connector Definition ID: ', workItemsDefId)
      
      } else {
          console.log('Both sources exist.');
      }

        if (!azureReposExists){
          console.log('WorkItems Connector doesnt exist. Adding source connector...');
          const sourceDefinition = {
            name: "azure-repos-source-99x",
            dockerRepository: "bksdrodrigo/azure-repos-source-99x",
            dockerImageTag: "0.2.02-candidate",
            documentationUrl: ""
          }

          // Adding Azure repos connector and handling the result
          azureReposDefId = await this.createCustomSourceDefinition({
            workspaceId,
            sourceDefinition
          });
        }
        
        console.log('Azure Repos Definition ID: ', azureReposDefId)
        return response.data;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
  }
 
  async checkDestinationExist(workspaceId: string) {
    try {
        const response = await this.api.post('/destination_definitions/list', {}, );
 
        // console.log('Response:', response.data);
 
        const destinationDefinitions = response.data.destinationDefinitions;
 
        const farosDestination = destinationDefinitions.some((destination: { name: string; }) => destination.name === 'airbyte-faros-destination-99x');
 
        if (!farosDestination) {
            console.log('Destination doesnt exist. Adding destination connector...');
            destinationDefId =  await this.createCustomDestinationDefinition({
              workspaceId: workspaceId,
              destinationDefinition: {
                  name: "airbyte-faros-destination-99x",
                  dockerRepository: "bksdrodrigo/airbyte-faros-destination-99x",
                  dockerImageTag: "0.2.02-candidate",
                  documentationUrl: "",
              }
            })
            console.log('Destination Definition ID: ', destinationDefId)
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
        const response = await this.api.post('/workspaces/list', {}, ); 
        // Return the workspaceId of the first workspace
        return response.data.workspaces[0].workspaceId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
  }

  async discoverSchemaCatalog(sourceId: string){
    try {
      const response = await this.api.post('/sources/discover_schema', {
          sourceId: `${sourceId}`
      }, );
 
      console.log('CatalogId:', response.data.catalogId);
      return response.data.catalogId;
  } catch (error) {
      console.error('Error:', error);
      throw error;
  }
  }
 

 
  async init(): Promise<void> {
    logger.info('init');
 
    const workspaceId = await this.getWorkspace()
    console.log('Workspace ID: ', workspaceId)
    await this.checkConnectorsExist(workspaceId);
    await this.checkDestinationExist(workspaceId);

    await this.completeFarosWorkspaceSetup(workspaceId);
  }
}
 
 