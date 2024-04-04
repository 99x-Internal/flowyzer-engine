import { AxiosInstance } from 'axios';
import pino from 'pino';
import { ForeignKey, Source } from './types';
export declare class HasuraInit {
    private readonly api;
    private readonly logger;
    private readonly resourcesDir;
    constructor(api: AxiosInstance, logger: pino.Logger, resourcesDir?: string);
    private listAllTables;
    private listAllForeignKeys;
    private getMetadata;
    private getDbSource;
    private getQueryCollections;
    private getEndpoints;
    private trackTable;
    private createObjectRelationship;
    private createArrayRelationship;
    private loadMetadata;
    static createSourceMetadata(tableNames: ReadonlyArray<string>, foreignKeys: ReadonlyArray<ForeignKey>, databaseUrl?: string): Source;
    private loadQueryCollectionFromResources;
    private addQueryToCollection;
    private addEndpoint;
    private updateQueryCollections;
    private updateEndpoints;
    createEndpoints(): Promise<void>;
    trackAllTablesAndRelationships(databaseUrl?: string): Promise<void>;
}
