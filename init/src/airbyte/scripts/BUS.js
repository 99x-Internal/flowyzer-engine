const path = require('path')
const axios = require('axios')
const fs = require('fs')
const username = "airbyte";
const password = "password";

const basicAuth = 'Basic ' + Buffer.from(`${username}:${password}`).toString('base64');

const BASE_RESOURCES_DIR = path.join(__dirname, '../../../resources/airbyte');

const CREATE_CONNECTION_REPO = path.join(
    BASE_RESOURCES_DIR,
    'workspace',
    'create_connection',
    'azureRepo.json'
);

const CREATE_CONNECTION_WORKITEMS = path.join(
    BASE_RESOURCES_DIR,
    'workspace',
    'create_connection',
    'workItems.json'
);

const CREATE_DESTINATION_CONFIG = path.join(
    BASE_RESOURCES_DIR,
    'workspace',
    'destination_config',
    'config.json'
);


let workItemsDefId = "9be05d25-a8d4-4022-ac1f-b4c41bef467c";
let workItemsSourceId;
let workItemsCatalog;

let azureReposDefId = "8b6aa84d-1278-44e8-a04f-a1d3a6f694e1";
let azureReposSourceId;
let azureRepoCatalog;

let destinationDefId = "5b52c998-f0cc-4f9f-a38f-e9f542db5c88";
let destinationId;
let workspaceId = "ae8b4894-5a48-49e4-8d67-7179107e164e";
const organization = "BUS-AS-Norway";
const project="BUS";


async function createSourceAzureRepo(workspaceId, sourceDefId){
    try {
        const response = await axios.post('http://localhost:8000/api/v1/sources/create', {
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
                organization: `${organization}`,
                access_token: `${process.env.AZURE_DEVOPS_PAT}`,
                projects: [`${project}`]
            }
        }, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });

        console.log('Azure Repo Source ID:', response.data.sourceId);
        return response.data.sourceId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}
 
 
async function createSourceWorkItems(workspaceId, sourceDefId) {
    try {
        const response = await axios.post('http://localhost:8000/api/v1/sources/create', {
            name: "Flowyzer-AzureRepoWorkitem-BUS",
            sourceDefinitionId: `${sourceDefId}`,
            workspaceId: `${workspaceId}`,
            connectionConfiguration: {
            api_version: "7.1",
            cutoff_days: 90,
            graph_version: "7.1-preview.1",
            request_timeout: 60000,
            organization: `${organization}`,
            access_token: `${process.env.AZURE_DEVOPS_PAT}`,
            projects: [
                `${project}`
            ]
            }
        }, {
            headers: {
                'Authorization': basicAuth,
                'Content-Type': 'application/json'
            }
        });

        console.log('Azure Workitems Source ID: ', response.data.sourceId);
        return response.data.sourceId;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}

async function discoverSchemaCatalog(sourceId){
    try {
        const response = await axios.post('http://localhost:8000/api/v1/sources/discover_schema', {
            sourceId: `${sourceId}`
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


async function createFlowyzerDestination(workspaceId, definitionId){
    try {

      const fileContent = fs.readFileSync(CREATE_DESTINATION_CONFIG, 'utf-8');
      const data = JSON.parse(fileContent);
  
      data.workspaceId = workspaceId;
      data.destinationDefinitionId = destinationDefId;  

      const response = await axios.post('http://localhost:8000/api/v1/destinations/create', data, {
        headers: {
            'Authorization': basicAuth,
            'Content-Type': 'application/json'
        }}
    );
 
      console.log('Destination ID :', response.data.destinationId);
      destinationId = response.data.destinationId;
      return response.data.destinationId;
  } catch (error) {
      console.error('Error:', error);
      throw error;
  }
  }

  
  async function createConnectionAzureRepo(
    sourceDefId,
    destinationId,
    sourceCatalogId
  ) {
    try {
      const fileContent = fs.readFileSync(CREATE_CONNECTION_REPO, 'utf-8');
      const data = JSON.parse(fileContent);
  
      // Update the sourceId, destinationId, and sourceCatalogId with the provided parameters
      data.sourceId = sourceDefId;
      data.destinationId = destinationId;
      data.sourceCatalogId = sourceCatalogId;
  
      // Make the API call to create the connection (assuming the data is to be sent in the request)
      const response = await axios.post('http://localhost:8000/api/v1/web_backend/connections/create', data, {
        headers: {
            'Authorization': basicAuth,
            'Content-Type': 'application/json'
        }});
  
      console.log('AzureRepo Connection ID :', response.data.connectionId);
      return response.data.connectionId;
    } catch (error) {
      console.error('Error:', error);
      throw error;
    }
  }
  
  async function createConnectionWorkItems(
    sourceId,
    destinationId,
    sourceCatalogId
  ) {
    try {
      const fileContent = fs.readFileSync(CREATE_CONNECTION_WORKITEMS, 'utf-8');
      const data = JSON.parse(fileContent);
  
      data.sourceId = sourceId;
      data.destinationId = destinationId;
      data.sourceCatalogId = sourceCatalogId;
  
      const response = await axios.post('http://localhost:8000/api/v1/web_backend/connections/create', data, {
        headers: {
            'Authorization': basicAuth,
            'Content-Type': 'application/json'
        }});
  
      console.log('Azure Workitems Connection ID :', response.data.connectionId);
      return response.data.connectionId;
    } catch (error) {
      console.error('Error:', error);
      throw error;
    }
  }

async function main() {
    azureReposSourceId = await createSourceAzureRepo(workspaceId, azureReposDefId)
    workItemsSourceId = await createSourceWorkItems(workspaceId, workItemsDefId)
    destinationId = await createFlowyzerDestination(workspaceId, destinationDefId)
    azureRepoCatalog = await discoverSchemaCatalog(azureReposSourceId)
    workItemsCatalog = await discoverSchemaCatalog(workItemsSourceId)
    await createConnectionWorkItems(workItemsSourceId, destinationId, azureRepoCatalog)
    await createConnectionAzureRepo(azureReposSourceId, destinationId, workItemsCatalog)
}

main().catch(error => {
    console.error('Error during execution:', error);
});