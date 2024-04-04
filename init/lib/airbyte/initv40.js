"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AirbyteInitV40 = void 0;
const fs = __importStar(require("fs"));
const yaml = __importStar(require("js-yaml"));
const path_1 = __importDefault(require("path"));
const pino_1 = __importDefault(require("pino"));
const logger = (0, pino_1.default)({
    name: 'airbytev40-init',
    level: process.env.LOG_LEVEL || 'info',
});
const config_1 = require("../config");
const CATALOGS = path_1.default.join(config_1.BASE_RESOURCES_DIR, 'airbyte', 'workspace', 'airbyte_config', 'STANDARD_SYNC.yaml');
const SOURCES = path_1.default.join(config_1.BASE_RESOURCES_DIR, 'airbyte', 'workspace', 'airbyte_config', 'SOURCE_CONNECTION.yaml');
// Function to load and parse a YAML file
function loadYamlFile(filePath) {
    try {
        const fileContent = fs.readFileSync(filePath, 'utf-8');
        const data = yaml.load(fileContent);
        return data;
    }
    catch (error) {
        console.error(`Error loading YAML file: ${error}`);
        return null;
    }
}
// Function to find an entry with a specific attribute value
function findEntryWithAttributeValue(data, attribute, value) {
    return data.find((entry) => entry[attribute] === value);
}
function snakeCaseToCamelCase(snakeCaseStr) {
    return snakeCaseStr.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase());
}
function convertKeysToCamelCase(data) {
    if (Array.isArray(data)) {
        return data.map(convertKeysToCamelCase);
    }
    else if (data !== null && typeof data === 'object') {
        const newData = {};
        for (const key in data) {
            const camelCaseKey = snakeCaseToCamelCase(key);
            newData[camelCaseKey] = convertKeysToCamelCase(data[key]);
        }
        return newData;
    }
    return data;
}
class AirbyteInitV40 {
    constructor(api) {
        this.api = api;
    }
    async createWorkspace(params) {
        const response = await this.api.post('/workspaces/create', params);
        return response.data.workspaceId;
    }
    async getWorkspaceBySlug(params) {
        const response = await this.api.post('/workspaces/get_by_slug', params);
        return response.data.workspaceId;
    }
    async getFirstWorkspace() {
        const response = await this.api.post('/workspaces/list', {});
        return response.data.workspaces[0].workspaceId;
    }
    // extra settings appear to be needed
    async completeWorkspaceSetup(params) {
        const response = await this.api.post('/workspaces/update', params);
        return response.data.initialSetupComplete;
    }
    async createCustomSourceDefinition(params) {
        const response = await this.api.post('/source_definitions/create_custom', params);
        return response.data.sourceDefinitionId;
    }
    async createCustomDestinationDefinition(params) {
        const response = await this.api.post('/destination_definitions/create_custom', params);
        return response.data.destinationDefinitionId;
    }
    async createSource(params) {
        const response = await this.api.post('/sources/create', params);
        return response.data.sourceId;
    }
    async createDestination(params) {
        const response = await this.api.post('/destinations/create', params);
        return response.data.destinationId;
    }
    async listDestinationNames(params) {
        const response = await this.api.post('/destinations/list', params);
        return response.data.destinations.map((destination) => destination.name);
    }
    async getCatalog(params) {
        const response = await this.api.post('/sources/discover_schema', params);
        return response.data.catalog;
    }
    async createConnection(params) {
        const response = await this.api.post('/connections/create', params);
        return response.data.connectionId;
    }
    async completeFarosWorkspaceSetup(workspaceId) {
        return await this.completeWorkspaceSetup({
            workspaceId,
            initialSetupComplete: true,
            anonymousDataCollection: false,
            news: false,
            securityUpdates: false,
        });
    }
    async createFarosDestinationDefinition(workspaceId, version) {
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
    async createFarosDestination(workspaceId, farosDestinationDefinitionId, hasura_url, hasura_admin_secret, segment_user_id) {
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
    async getFarosDestinationId(workspaceId) {
        return (await this.listDestinationNames({ workspaceId })).filter((name) => name === 'Faros Destination')[0];
    }
    async createSourceFromYAML(workspaceId, yamlData, sourceName, sourceDefinitionId) {
        const source = findEntryWithAttributeValue(yamlData, 'name', sourceName);
        return await this.createSource({
            workspaceId,
            sourceDefinitionId,
            name: source.name,
            connectionConfiguration: source.configuration,
        });
    }
    async createConnectionToFaros(sourceId, farosDestinationId, yamlData, connectionName) {
        const connection = findEntryWithAttributeValue(yamlData, 'name', connectionName);
        const streams = connection.catalog.streams;
        const streamsWithConfig = streams.map((stream) => {
            const streamWithConfig = { ...stream };
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
    async handleFarosSource(name, workspaceId, farosDestinationId, farosConnectorsVersion, yamlSourceData, yamlCatalogData) {
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
        await this.createAndConnectSource(name, workspaceId, farosDestinationId, yamlSourceData, yamlCatalogData, sourceDefinitionId);
    }
    async createAndConnectSource(name, workspaceId, farosDestinationId, yamlSourceData, yamlCatalogData, sourceDefinitionId) {
        const sourceId = await this.createSourceFromYAML(workspaceId, yamlSourceData, name, sourceDefinitionId);
        logger.info('sourceId for ' + name + ': ' + sourceId);
        const connectionId = await this.createConnectionToFaros(sourceId, farosDestinationId, yamlCatalogData, name + ' - Faros');
        logger.info('connectionId for ' + name + ': ' + connectionId);
    }
    async init(farosConnectorsVersion, hasuraUrl, hasuraAdminSecret, segmentUserId) {
        logger.info('init');
        const workspaceId = await this.getFirstWorkspace();
        logger.info('workspaceId: ' + workspaceId);
        await this.completeFarosWorkspaceSetup(workspaceId);
        const farosDestinationDefintionId = await this.createFarosDestinationDefinition(workspaceId, farosConnectorsVersion);
        logger.info('farosDestinationDefintionId: ' + farosDestinationDefintionId);
        const farosDestinationId = await this.createFarosDestination(workspaceId, farosDestinationDefintionId, hasuraUrl, hasuraAdminSecret, segmentUserId);
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
            logger.info('sourceDefinitionId for ' +
                communitySource[0] +
                ': ' +
                communitySource[1] +
                ' (community)');
            await this.createAndConnectSource(communitySource[0], workspaceId, farosDestinationId, yamlSourceData, yamlCatalogData, communitySource[1]);
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
            await this.handleFarosSource(farosSource, workspaceId, farosDestinationId, farosConnectorsVersion, yamlSourceData, yamlCatalogData);
        }
    }
}
exports.AirbyteInitV40 = AirbyteInitV40;
