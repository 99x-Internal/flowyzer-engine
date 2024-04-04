import { AxiosInstance } from 'axios';
import { Dictionary } from 'lodash';
export declare class AirbyteInitV40 {
    private readonly api;
    constructor(api: AxiosInstance);
    createWorkspace(params: {
        name: string;
    }): Promise<string>;
    getWorkspaceBySlug(params: {
        slug: string;
    }): Promise<string>;
    getFirstWorkspace(): Promise<string>;
    completeWorkspaceSetup(params: {
        workspaceId: string;
        initialSetupComplete: boolean;
        anonymousDataCollection: boolean;
        news: boolean;
        securityUpdates: boolean;
    }): Promise<string>;
    createCustomSourceDefinition(params: {
        workspaceId: string;
        sourceDefinition: {
            name: string;
            dockerRepository: string;
            dockerImageTag: string;
            documentationUrl: string;
        };
    }): Promise<string>;
    createCustomDestinationDefinition(params: {
        workspaceId: string;
        destinationDefinition: {
            name: string;
            dockerRepository: string;
            dockerImageTag: string;
            documentationUrl: string;
        };
    }): Promise<string>;
    createSource(params: {
        sourceDefinitionId: string;
        connectionConfiguration: Dictionary<any>;
        workspaceId: string;
        name: string;
    }): Promise<string>;
    createDestination(params: {
        destinationDefinitionId: string;
        connectionConfiguration: Dictionary<any>;
        workspaceId: string;
        name: string;
    }): Promise<string>;
    listDestinationNames(params: {
        workspaceId: string;
    }): Promise<string[]>;
    getCatalog(params: {
        sourceId: string;
    }): Promise<Dictionary<any>>;
    createConnection(params: {
        name: string;
        prefix: string;
        sourceId: string;
        destinationId: string;
        syncCatalog: Dictionary<any>;
        status: string;
    }): Promise<string>;
    completeFarosWorkspaceSetup(workspaceId: string): Promise<string>;
    createFarosDestinationDefinition(workspaceId: string, version: string): Promise<string>;
    createFarosDestination(workspaceId: string, farosDestinationDefinitionId: string, hasura_url: string, hasura_admin_secret: string, segment_user_id: string): Promise<string>;
    getFarosDestinationId(workspaceId: string): Promise<string>;
    createSourceFromYAML(workspaceId: string, yamlData: any, sourceName: string, sourceDefinitionId: string): Promise<string>;
    createConnectionToFaros(sourceId: string, farosDestinationId: string, yamlData: any, connectionName: string): Promise<string>;
    handleFarosSource(name: string, workspaceId: string, farosDestinationId: string, farosConnectorsVersion: string, yamlSourceData: any, yamlCatalogData: any): Promise<void>;
    createAndConnectSource(name: string, workspaceId: string, farosDestinationId: string, yamlSourceData: any, yamlCatalogData: any, sourceDefinitionId: string): Promise<void>;
    init(farosConnectorsVersion: string, hasuraUrl: string, hasuraAdminSecret: string, segmentUserId: string): Promise<void>;
}
