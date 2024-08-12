import axios, {AxiosInstance} from 'axios';
import {VError} from 'verror';

export function wrapApiError(cause: unknown, msg: string): Error {
  // Omit verbose axios error
  const truncated = new VError((cause as Error).message);
  return new VError(truncated, msg);
}

// 12 hours
const SYNC_POLL_MILLIS = 2_000;

export interface AttributeMappings {
  readonly id: number;
  readonly group_id: number;
  readonly table_id: number;
  readonly card_id?: number;
  readonly attribute_mappings: Map<string, string | number>;
}

export interface MetabaseConfig {
  readonly url: string;
  readonly username: string;
  readonly password: string;
}

interface FieldParams {
  [param: string]: any;
}

export class Metabase {
  constructor(private readonly api: AxiosInstance) {}

  static async fromConfig(cfg: MetabaseConfig): Promise<Metabase> {
    const token = await Metabase.sessionToken(cfg);
    const api = axios.create({
      baseURL: `${cfg.url}/api`,
      headers: {
        'X-Metabase-Session': token,
      },
    });
    return new Metabase(api);
  }

  private static async sessionToken(cfg: MetabaseConfig): Promise<string> {
    const {url, username, password} = cfg;
    try {
      const {data} = await axios.post(`${url}/api/session`, {
        username,
        password,
      });
      return data.id;
    } catch (err) {
      throw wrapApiError(err, 'failed to get session token');
    }
  }

  async getDatabases(): Promise<any[]> {
    try {
      const {data} = await this.api.get('database');
      return Array.isArray(data) ? data : data?.data || [];
    } catch (err) {
      throw wrapApiError(err, 'unable to get databases');
    }
  }

  async getDatabase(name: string): Promise<any | undefined> {
    try {
      const dbs = await this.getDatabases();
      return dbs.find((d: any) => d?.details?.dbname === name);
    } catch (err) {
      throw wrapApiError(err, 'unable to find database: ' + name);
    }
  }

  async syncSchema(databaseName: string): Promise<void> {
    const db = await this.getDatabase(databaseName);

    if (!db) {
      throw new VError('unable to find database: ' + databaseName);
    }

    await this.api.post(`database/${db.id}/sync_schema`);
  }

  async syncTables(
    schema: string,
    fieldsByTable: Map<string, Set<string>>,
    timeout: number
  ): Promise<void> {
    const dbs = await this.getDatabases();
    for (const db of dbs) {
      try {
        await this.api.post(`database/${db.id}/sync_schema`);
      } catch (err) {
        throw wrapApiError(err, `failed to sync database ${db.id}`);
      }
    }

    const checkSync = async (allTables: any[]): Promise<boolean> => {
      const tables = allTables.filter((t: any) => {
        return t.schema === schema && fieldsByTable.has(t.name);
      });
      // First check all tables are synced
      if (tables.length < fieldsByTable.size) {
        return false;
      }
      // Next check all fields of each table are synced
      for (const table of tables) {
        const metadata = await this.getQueryMetadata(table.id);
        const actualFields = new Set<string>(
          metadata?.fields?.map((f: any) => f.name)
        );
        for (const field of fieldsByTable.get(table.name) || []) {
          if (!actualFields.has(field)) {
            return false;
          }
        }
      }
      return true;
    };

    let isSynced = await checkSync(await this.getTables());
    const deadline = Date.now() + timeout;
    while (!isSynced && Date.now() < deadline) {
      await new Promise((resolve) => {
        setTimeout(resolve, SYNC_POLL_MILLIS);
        return;
      });
      try {
        isSynced = await checkSync(await this.getTables());
      } catch (err) {
        throw wrapApiError(err, 'failed to get tables');
      }
    }
    if (!isSynced) {
      throw new VError(
        'failed to sync tables %s within timeout: %s ms',
        Array.from(fieldsByTable.keys()),
        timeout
      );
    }
  }

  async getTables(): Promise<any[]> {
    try {
      const {data} = await this.api.get('table');
      return data;
    } catch (err) {
      throw wrapApiError(err, 'unable to get tables');
    }
  }

  // eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
  async putTables(ids: ReadonlyArray<number>, params: any): Promise<void> {
    try {
      if (ids.length) {
        await this.api.put('table', {ids, ...params});
      }
    } catch (err) {
      throw wrapApiError(err, `unable to put tables: ${ids}`);
    }
  }

  async getQueryMetadata(tableId: number): Promise<any> {
    try {
      const {data} = await this.api.get(`table/${tableId}/query_metadata`, {
        params: {include_sensitive_fields: true},
      });
      return data;
    } catch (err) {
      throw wrapApiError(err, 'unable to get metadata for table: ' + tableId);
    }
  }
}