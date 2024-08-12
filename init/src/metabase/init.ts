import {Option, program} from 'commander';
import pino from 'pino';
import axios from 'axios';
import fs from 'fs';
import path from 'path';
import {Metabase} from './metabase';

const CONFIG = {
  DATABASE_NAME: process.env.DATABASE_NAME || 'Faros Data',
  QUERIES_DIR: path.join(
    __dirname,
    '../../resources/metabase/abstract_queries'
  ),
  DASHBOARD_QUERIES_DIR: path.join(
    __dirname,
    '../../resources/metabase/dashboards'
  ),
  SPEED_CHARTS_DIR: path.join(
    __dirname,
    '../../resources/metabase/charts/speed'
  ),
  PRODUCTIVITY_CHARTS_DIR: path.join(
    __dirname,
    '../../resources/metabase/charts/productivity'
  ),
};

interface DashboardResponse {
  data: {
    id: number;
  };
}

interface DashboardQuery {
  [key: string]: any;
}

type DatasetQuery = {
  database: number;
  type: string;
  query: {
    aggregation: any[];
    breakout: any[];
    'source-table': string;
    filter: any[];
  };
};

type Dashcard = {
  card: {
    dataset_query: {
      query: {
        'source-table': string;
        filter: any[];
      };
    };
  };
};

type Query = {
  name: string;
  dataset_query: DatasetQuery;
  visualization_settings: {
    graph_type: string;
  };
  display: string;
  collection_id: number | string;
  dashcards?: Dashcard[];
};

// Helper function to wrap API errors
function wrapApiError(cause: unknown, msg: string): Error {
  const truncated = new Error((cause as Error).message);
  return new Error(`${msg}: ${truncated.message}`);
}

// Ensure required environment variables are set
if (
  !process.env.METABASE_URL ||
  !process.env.METABASE_USER ||
  !process.env.METABASE_PASSWORD ||
  !process.env.ORG_UID
) {
  throw new Error('Missing required environment variables');
}

async function getSessionToken(): Promise<string> {
  try {
    const response = await axios.post(
      `${process.env.METABASE_URL}/api/session`,
      {
        username: process.env.METABASE_USER,
        password: process.env.METABASE_PASSWORD,
      }
    );
    return response.data.id;
  } catch (err) {
    throw wrapApiError(err, 'Failed to get session token');
  }
}

async function checkIfCollection(
  token: string,
  name: string
): Promise<number | null> {
  try {
    const response = await axios.get(
      `${process.env.METABASE_URL}/api/collection`,
      {
        headers: {'X-Metabase-Session': token},
      }
    );
    const collections = response.data;

    for (const collection of collections) {
      if (collection.name === name) {
        return collection.id;
      }
    }
    return null; // Return null if the collection doesn't exist
  } catch (err) {
    throw wrapApiError(err, 'Failed to retrieve collections');
  }
}

async function createCollection(
  token: string,
  name: string,
  parentId?: number
): Promise<number> {
  try {
    const response = await axios.post(
      `${process.env.METABASE_URL}/api/collection`,
      {name, parent_id: parentId},
      {headers: {'X-Metabase-Session': token}}
    );
    return response.data.id;
  } catch (err) {
    throw wrapApiError(err, 'Failed to create collection');
  }
}

async function getOrCreateCollection(
  token: string,
  name: string,
  parentId?: number
): Promise<number> {
  let collectionId = await checkIfCollection(token, name);
  if (collectionId === null) {
    collectionId = await createCollection(token, name, parentId);
  }
  return collectionId;
}

async function createQuery(
  token: string,
  collectionId: number,
  query: any
): Promise<any> {
  try {
    query.collection_id = collectionId;
    const response = await axios.post(
      `${process.env.METABASE_URL}/api/card`,
      query,
      {
        headers: {'X-Metabase-Session': token},
      }
    );
    return response.data.id;
  } catch (err) {
    throw wrapApiError(err, 'Failed to create query');
  }
}

async function createMetabaseQueries(
  queriesDir: string,
  token: string,
  collectionId: number
): Promise<number[]> {
  const queryIds = [];
  const files = fs.readdirSync(queriesDir);

  for (const file of files) {
    const filePath = path.join(queriesDir, file);
    if (filePath.endsWith('.json')) {
      try {
        const query = readAndParseJSON(filePath);
        const response = await createQuery(token, collectionId, query);
        queryIds.push(response);
      } catch (err) {
        logger.error(`Failed to create query from file ${filePath}:`, err);
      }
    }
  }

  logger.info('Setup complete');
  return queryIds;
}

function readAndParseJSON(filePath: string): any {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  } catch (err) {
    logger.error(`Failed to read or parse JSON file ${filePath}:`, err);
    throw err;
  }
}

async function createSpeedCharts(
  spd_chrt_dir: string,
  token: string,
  collectionId: any,
  cards: any[]
): Promise<number[]> {
  const cardIDs = [];
  const files = fs.readdirSync(spd_chrt_dir);

  for (const file of files) {
    const filePath = path.join(spd_chrt_dir, file);
    if (filePath.endsWith('.json')) {
      try {
        const query = readAndParseJSON(filePath);
        const updated_query = updateSpeedQueries(query, collectionId, cards);
        const response = await createQuery(token, collectionId, updated_query);
        cardIDs.push(response);
      } catch (err) {
        logger.error(`Failed to create query from file ${filePath}:`, err);
      }
    }
  }

  logger.info('Speed charts setup complete');
  return cardIDs;
}

async function createProdCharts(
  prod_chrt_dir: string,
  token: string,
  collectionId: any,
  cards: any[]
): Promise<number[]> {
  const cardIDs = [];
  const files = fs.readdirSync(prod_chrt_dir);

  for (const file of files) {
    const filePath = path.join(prod_chrt_dir, file);
    if (filePath.endsWith('.json')) {
      try {
        const query = readAndParseJSON(filePath);
        const updated_query = updateProdQueries(query, collectionId, cards);
        const response = await createQuery(token, collectionId, updated_query);
        cardIDs.push(response);
      } catch (err) {
        logger.error(`Failed to create query from file ${filePath}:`, err);
      }
    }
  }

  logger.info('Productivity charts setup complete');
  return cardIDs;
}

function updateSpeedQueries(
  query: Query,
  collection_id: string,
  cards: string[]
): Query {
  const [
    productivityCardId,
    leadTimebyPrCardId,
    prlosscardId,
    weekscardId,
    leadTimebyPrCardIdwithCommit,
  ] = cards;
  query.collection_id = collection_id;

  function replaceOrgUID(filter: any): any {
    if (Array.isArray(filter)) {
      return filter.map((item) => {
        if (Array.isArray(item)) {
          return replaceOrgUID(item);
        } else if (item === 'BUS-AS-Norway') {
          return process.env.ORG_UID;
        }
        return item;
      });
    }
    return filter;
  }

  if (query.dataset_query && query.dataset_query.query) {
    switch (query.dataset_query.query['source-table']) {
      case 'card__351':
        query.dataset_query.query['source-table'] =
          `card__${leadTimebyPrCardIdwithCommit}`;
        break;
      case 'card__352':
        query.dataset_query.query['source-table'] =
          `card__${leadTimebyPrCardId}`;
        break;
      default:
        break;
    }

    if (query.dataset_query.query.filter) {
      query.dataset_query.query.filter = replaceOrgUID(
        query.dataset_query.query.filter
      );
    }
  }

  return query;
}

function updateProdQueries(
  query: Query,
  collection_id: string,
  cards: string[]
): Query {
  const [
    productivityCardId,
    leadTimebyPrCardId,
    prlosscardId,
    weekscardId,
    leadTimebyPrCardIdwithCommit,
  ] = cards;
  query.collection_id = collection_id;

  function updateFields(obj: any) {
    if (typeof obj !== 'object' || obj === null) return;

    for (const key in obj) {
      if (typeof obj[key] === 'object' && obj[key] !== null) {
        updateFields(obj[key]);
      } else {
        if (key === 'source-table' && typeof obj[key] === 'string') {
          switch (obj[key]) {
            case 'card__129':
              obj[key] = `card__${productivityCardId}`;
              break;
            case 'card__133':
              obj[key] = `card__${weekscardId}`;
              break;
            case 'card__128':
              obj[key] = `card__${prlosscardId}`;
              break;
          }
        }
        if (key === 'join-alias' && typeof obj[key] === 'string') {
          switch (obj[key]) {
            case 'Question 133':
              obj[key] = `Question ${weekscardId}`;
              break;
          }
        }
        if (key === 'alias' && typeof obj[key] === 'string') {
          switch (obj[key]) {
            case 'Question 133':
              obj[key] = `Question ${weekscardId}`;
              break;
          }
        }
      }
    }
  }

  updateFields(query);

  return query;
}

async function createDashboards(
  token: string,
  collectionId: number
): Promise<number[]> {
  try {
    const speedResponse: DashboardResponse = await axios.post(
      `${process.env.METABASE_URL}/api/dashboard`,
      {name: 'Speed Dashboard', description: null, collection_id: collectionId},
      {headers: {'X-Metabase-Session': token}}
    );

    const productivityResponse: DashboardResponse = await axios.post(
      `${process.env.METABASE_URL}/api/dashboard`,
      {
        name: 'Productivity Dashboard',
        description: null,
        collection_id: collectionId,
      },
      {headers: {'X-Metabase-Session': token}}
    );

    const speedDashId = speedResponse.data.id;
    const productivityDashId = productivityResponse.data.id;
    return [speedDashId, productivityDashId];
  } catch (err) {
    throw new Error(`Error creating dashboards: ${err}`);
  }
}

function updateDashboardQueries(
  jsonData: DashboardQuery,
  cardIds: any
): DashboardQuery {
  function updateFields(obj: any) {
    if (typeof obj !== 'object' || obj === null) return;

    for (const key in obj) {
      if (typeof obj[key] === 'object' && obj[key] !== null) {
        updateFields(obj[key]);
      } else {
        if (key === 'card_id' && typeof obj[key] === 'number') {
          switch (obj[key]) {
            case 414:
              obj[key] = cardIds[1];
              break;
            case 416:
            case 418:
              obj[key] = cardIds[2];
              break;
            case 420:
              obj[key] = cardIds[3];
              break;
            case 417:
              obj[key] = cardIds[4];
              break;
            case 419:
              obj[key] = cardIds[5];
              break;
            case 421:
              obj[key] = cardIds[6];
              break;
            case 422:
              obj[key] = cardIds[7];
              break;
            case 423:
              obj[key] = cardIds[8];
              break;
          }
        }
      }
    }
  }

  updateFields(jsonData);

  return jsonData;
}

async function updateDashboards(
  token: string,
  speedDashboardId: number,
  productivityDashboardId: number,
  cards: any[]
): Promise<void> {
  try {
    const [speed_chartids, prod_chartids] = cards;

    const speedJsonPath = path.join(CONFIG.DASHBOARD_QUERIES_DIR, 'speed.json');
    const productivityJsonPath = path.join(
      CONFIG.DASHBOARD_QUERIES_DIR,
      'productivity.json'
    );

    const speedJsonData: DashboardQuery = readAndParseJSON(speedJsonPath);
    const productivityJsonData: DashboardQuery =
      readAndParseJSON(productivityJsonPath);

    const updatedSpeedJsonData = updateDashboardQueries(
      speedJsonData,
      speed_chartids
    );
    const updatedProductivityJsonData = updateDashboardQueries(
      productivityJsonData,
      prod_chartids
    );

    await axios.put(
      `${process.env.METABASE_URL}/api/dashboard/${speedDashboardId}`,
      updatedSpeedJsonData,
      {
        headers: {
          'X-Metabase-Session': token,
          'Content-Type': 'application/json',
        },
      }
    );
    await axios.put(
      `${process.env.METABASE_URL}/api/dashboard/${productivityDashboardId}`,
      updatedProductivityJsonData,
      {
        headers: {
          'X-Metabase-Session': token,
          'Content-Type': 'application/json',
        },
      }
    );

    logger.info('Dashboards updated successfully');
  } catch (err) {
    logger.error('Error updating dashboards:', err);
  }
}

async function setup(
  metabaseQueriesDir: string,
  speed_chrt_dir: string,
  prod_chrt_dir: string
) {
  try {
    const token = await getSessionToken();
    let collectionId = await getOrCreateCollection(token, 'Flowyzer');
    const queriesCollectionId = await getOrCreateCollection(
      token,
      'metabase-queries',
      collectionId
    );

    const queryIds = await createMetabaseQueries(
      metabaseQueriesDir,
      token,
      queriesCollectionId
    );

    if (queryIds && queryIds.length > 3) {
      const productivityCardId = queryIds[3];
      const leadTimebyPrCardId = queryIds[4];
      const prlosscardId = queryIds[2];
      const weekscardId = queryIds[7];
      const leadTimebyPrCardIdwithCommit = queryIds[5];
      const cards = [
        productivityCardId,
        leadTimebyPrCardId,
        prlosscardId,
        weekscardId,
        leadTimebyPrCardIdwithCommit,
      ];

      const speed_collection_id = await createCollection(
        token,
        'Speed Charts',
        collectionId
      );
      const prod_collection_id = await createCollection(
        token,
        'Productivity Charts',
        collectionId
      );
      const speed_chartids = await createSpeedCharts(
        speed_chrt_dir,
        token,
        speed_collection_id,
        cards
      );
      const prod_chartids = await createProdCharts(
        prod_chrt_dir,
        token,
        prod_collection_id,
        cards
      );

      logger.info(speed_chartids, 'Speed Charts', prod_chartids, 'Prod Charts');

      const dashboards = await createDashboards(token, collectionId);
      const [speed_dash_Id, producitivity_dash_Id] = dashboards || [];
      const cardIDs = [speed_chartids, prod_chartids];

      if (speed_dash_Id !== undefined && producitivity_dash_Id !== undefined) {
        updateDashboards(token, speed_dash_Id, producitivity_dash_Id, cardIDs);
      } else {
        logger.error('Dashboard IDs must be defined');
      }
    }
  } catch (error) {
    logger.error('Error setting up Metabase:', error);
  }
}

const logger = pino({
  name: 'metabase-init',
  level: process.env.LOG_LEVEL || 'info',
});

async function main(): Promise<void> {
  program
    .requiredOption('--metabase-url <string>')
    .requiredOption('--username <string>')
    .requiredOption('--password <string>')
    .requiredOption('--database <string>')
    .addOption(
      new Option('--export <dashboardId>')
        .conflicts('importOne')
        .conflicts('importNew')
    )
    .addOption(
      new Option('--import-one <filename>')
        .conflicts('export')
        .conflicts('importNew')
    )
    .addOption(
      new Option('--import-new').conflicts('export').conflicts('importOne')
    )
    .addOption(new Option('--sync-schema'));

  program.parse();
  const options = program.opts();

  if (options.syncSchema) {
    const metabase = await Metabase.fromConfig({
      url: options.metabaseUrl,
      username: options.username,
      password: options.password,
    });

    await metabase.syncSchema(options.database);
    logger.info('Metabase sync schema triggered');
  } else {
    if (!options.export && !options.importOne && !options.importNew) {
      program.help();
    }

    if (options.importNew) {
      await setup(
        CONFIG.QUERIES_DIR,
        CONFIG.SPEED_CHARTS_DIR,
        CONFIG.PRODUCTIVITY_CHARTS_DIR
      );
      logger.info('Metabase import is complete');
    }
  }
}

if (require.main === module) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
