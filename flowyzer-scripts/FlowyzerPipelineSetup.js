const path = require('path');
const axios = require('axios');
const fs = require('fs');

const username = "airbyte";
const password = "password";
const basicAuth = 'Basic ' + Buffer.from(`${username}:${password}`).toString('base64');

const BASE_RESOURCES_DIR = path.join(__dirname, '../init/resources/airbyte');
const CREATE_DESTINATION_CONFIG = path.join(BASE_RESOURCES_DIR, 'workspace', 'destination_config', 'config.json');

// Load the JSON file that contains the source data
const sourcesDataPath = path.join(BASE_RESOURCES_DIR, 'workspace', 'customers', 'customers.json');
const sourcesData = JSON.parse(fs.readFileSync(sourcesDataPath, 'utf-8'));

let destinationDefId = "3a0d819b-a2fa-4a41-a3bd-d23f3bf0bcea";
let destinationId;
let workspaceId = "cfefa45f-5049-4925-ab7b-1c24751d8304";

async function createSource(sourceData) {
    const projectNames = sourceData.project_name.join(', ');
    try {
        const response = await axios.post('http://localhost:8000/api/v1/sources/create', {
            name: `${sourceData.organization_Name}-${projectNames}`,
            sourceDefinitionId: sourceData.sourceDefinitionID,
            workspaceId: workspaceId,
            connectionConfiguration: {
                api_url: "https://dev.azure.com",
                page_size: 100,
                api_version: "7.0",
                cutoff_days: sourceData.cut_off_days,
                max_retries: 3,
                graph_api_url: "https://vssps.dev.azure.com",
                graph_version: "7.1-preview.1",
                branch_pattern: ".*",
                request_timeout: 60000,
                reject_unauthorized: false,
                organization: sourceData.organization_Name,
                access_token: sourceData.PAT,
                projects: sourceData.project_name
            }
        }, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });

        console.log(`Source ID for ${sourceData.project_name}:`, response.data.sourceId);
        return response.data.sourceId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}

async function discoverSchemaCatalog(sourceId) {
    try {
        const response = await axios.post('http://localhost:8000/api/v1/sources/discover_schema', {
            sourceId: sourceId
        }, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });

        console.log('CatalogId: ', response.data.catalogId);
        return response.data.catalogId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}

async function createFlowyzerDestination(workspaceId) {
    try {
        const fileContent = fs.readFileSync(CREATE_DESTINATION_CONFIG, 'utf-8');
        const data = JSON.parse(fileContent);
        data.workspaceId = workspaceId;
        data.destinationDefinitionId = destinationDefId;

        const response = await axios.post('http://localhost:8000/api/v1/destinations/create', data, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });

        console.log('Destination ID :', response.data.destinationId);
        destinationId = response.data.destinationId;
        return response.data.destinationId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}

async function createConnection(sourceId, destinationId, sourceCatalogId, sourceData) {
    let connectionFilePath;

    // Select the appropriate configuration file based on the connecter_type
    if (sourceData.connecter_type === 'Azure_Workitems') {
        connectionFilePath = path.join(BASE_RESOURCES_DIR, 'workspace', 'create_connection', 'workitems_connection_config.json');
    } else if (sourceData.connecter_type === 'Azure_Repos') {
        connectionFilePath = path.join(BASE_RESOURCES_DIR, 'workspace', 'create_connection', 'repos_source_connection_config.json');
    } else {
        console.error(`Unknown connecter_type: ${sourceData.connecter_type}`);
        return;
    }

    try {
        const fileContent = fs.readFileSync(connectionFilePath, 'utf-8');
        const data = JSON.parse(fileContent);

        data.sourceId = sourceId;
        data.destinationId = destinationId;
        data.sourceCatalogId = sourceCatalogId;
        data.name = `${sourceData.project_name} --> Flowyzer Destination`;

        const response = await axios.post('http://localhost:8000/api/v1/web_backend/connections/create', data, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });

        console.log(`Connection ID for ${sourceData.project_name}:`, response.data.connectionId);
        return response.data.connectionId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}

async function main() {
    destinationId = await createFlowyzerDestination(workspaceId);

    // Iterate through each source data object and create sources and connections
    for (const sourceData of sourcesData) {
        const sourceId = await createSource(sourceData);
        const sourceCatalogId = await discoverSchemaCatalog(sourceId);
        await createConnection(sourceId, destinationId, sourceCatalogId, sourceData);
    }
}

main().catch(error => {
    console.error('Error during execution:', error);
});
