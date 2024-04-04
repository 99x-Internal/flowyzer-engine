"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AirbyteInit = exports.FAROS_DEST_REPO = void 0;
const analytics_node_1 = require("@segment/analytics-node");
const async_retry_1 = __importDefault(require("async-retry"));
const axios_1 = __importDefault(require("axios"));
const commander_1 = require("commander");
const lodash_1 = require("lodash");
const pino_1 = __importDefault(require("pino"));
const uuid_1 = require("uuid");
const verror_1 = require("verror");
const initv40_1 = require("./initv40");
const logger = (0, pino_1.default)({
    name: 'airbyte-init',
    level: process.env.LOG_LEVEL || 'info',
});
exports.FAROS_DEST_REPO = 'farosai/airbyte-faros-destination';
const UUID_NAMESPACE = 'bb229e18-eb5f-4309-a863-893cbec53758';
class AirbyteInit {
    constructor(api) {
        this.api = api;
    }
    async waitUntilHealthy() {
        await (0, async_retry_1.default)(async () => {
            var _a;
            const response = await this.api.get('/health');
            if (!((_a = response.data.available) !== null && _a !== void 0 ? _a : false)) {
                throw new verror_1.VError('Airbyte is not healthy yet');
            }
        }, {
            retries: 30,
            minTimeout: 1000,
            maxTimeout: 1000,
        });
    }
    static makeSegmentUser() {
        const version = process.env.FAROS_INIT_VERSION || '';
        const source = process.env.FAROS_START_SOURCE || '';
        const envEmail = process.env.FAROS_EMAIL;
        if (envEmail && envEmail !== undefined && envEmail !== '') {
            return {
                userId: (0, uuid_1.v5)(envEmail, UUID_NAMESPACE),
                email: envEmail,
                version,
                source,
            };
        }
        return undefined;
    }
    static async sendIdentityAndStartEvent(segmentUser, host) {
        if (segmentUser === undefined) {
            logger.info('Skipping Telemetry');
            return Promise.resolve();
        }
        const analytics = new analytics_node_1.Analytics({
            writeKey: 'YFJm3AJBKwOm0Hp4o4vD9iqnZN5bVn45',
            // Segment host is used for testing purposes only
            host,
        });
        try {
            analytics.identify({
                userId: segmentUser === null || segmentUser === void 0 ? void 0 : segmentUser.userId,
                traits: {
                    email: segmentUser === null || segmentUser === void 0 ? void 0 : segmentUser.email,
                    version: segmentUser === null || segmentUser === void 0 ? void 0 : segmentUser.version,
                    source: segmentUser === null || segmentUser === void 0 ? void 0 : segmentUser.source,
                },
            });
            analytics.track({ userId: segmentUser === null || segmentUser === void 0 ? void 0 : segmentUser.userId, event: 'Start' });
            await analytics.closeAndFlush();
        }
        catch (err) {
            if (err instanceof Error) {
                logger.error(`Failed to send identity and start event: ${err.message}`);
            }
        }
    }
    async setupWorkspace(segmentUser, hasuraAdminSecret, airbyteDestinationHasuraUrl, forceSetup) {
        var _a, _b;
        const response = await this.api.post('/workspaces/list');
        const workspaces = (_a = response.data.workspaces) !== null && _a !== void 0 ? _a : [];
        if (workspaces.length === 0) {
            throw new verror_1.VError('Default workspace not found');
        }
        else if (workspaces.length > 1) {
            throw new verror_1.VError('Cannot support more than one workspace');
        }
        const workspace = workspaces[0];
        const workspaceId = workspace.workspaceId;
        if (workspace.initialSetupComplete) {
            logger.info(`Workspace ${workspaceId} is already set up`);
            // TODO: force setup
            if (forceSetup) {
                throw new verror_1.VError('Forced setup not supported');
            }
            return; // TODO: connector upgrades
        }
        logger.info(`Setting up workspace ${workspaceId}`);
        // TODO: connectors upgrades
        const farosConnectorsVersion = await AirbyteInit.getLatestImageTag(exports.FAROS_DEST_REPO);
        logger.info('faros connectors version: ' + farosConnectorsVersion);
        const airbyteInitV40 = new initv40_1.AirbyteInitV40(this.api);
        try {
            // destination spec expects uuid for segment_user_id
            // empty string fails validation
            await airbyteInitV40.init(farosConnectorsVersion, airbyteDestinationHasuraUrl, hasuraAdminSecret, (_b = segmentUser === null || segmentUser === void 0 ? void 0 : segmentUser.userId) !== null && _b !== void 0 ? _b : '00000000-0000-0000-0000-000000000000');
        }
        catch (error) {
            throw new verror_1.VError(`Failed to set up workspace: ${error}`);
        }
    }
    static async getLatestImageTag(repository, page = 1, pageSize = 10) {
        var _a;
        const response = await axios_1.default.get(`https://hub.docker.com/v2/repositories/${repository}/tags`, { params: { page, page_size: pageSize, ordering: 'last_updated' } });
        const tags = response.data.results;
        const version = (_a = (0, lodash_1.find)(tags, (t) => t.name !== 'latest' && !t.name.endsWith('-rc'))) === null || _a === void 0 ? void 0 : _a.name;
        if (!version) {
            if (response.data.next) {
                return await AirbyteInit.getLatestImageTag(repository, page + 1, pageSize);
            }
            throw new verror_1.VError('Unable to determine latest image version of %s', repository);
        }
        return version;
    }
}
exports.AirbyteInit = AirbyteInit;
async function main() {
    commander_1.program
        .requiredOption('--airbyte-url <string>')
        .requiredOption('--airbyte-destination-hasura-url <string>')
        .requiredOption('--hasura-admin-secret <string>')
        .option('--force-setup')
        .option('--airbyte-api-calls-concurrency <num>', 'the max number of concurrent Airbyte api calls', parseInt);
    commander_1.program.parse();
    const options = commander_1.program.opts();
    if ((options === null || options === void 0 ? void 0 : options.airbyteApiCallsConcurrency) <= 0) {
        throw new commander_1.InvalidArgumentError('airbyte-api-calls-concurrency must be a positive integer');
    }
    const airbyte = new AirbyteInit(axios_1.default.create({
        baseURL: `${options.airbyteUrl}/api/v1`,
    }));
    const segmentUser = AirbyteInit.makeSegmentUser();
    await AirbyteInit.sendIdentityAndStartEvent(segmentUser);
    await airbyte.waitUntilHealthy();
    await airbyte.setupWorkspace(segmentUser, options.hasuraAdminSecret, options.airbyteDestinationHasuraUrl, options.forceSetup);
    logger.info('Airbyte setup is complete');
}
if (require.main === module) {
    main().catch((err) => {
        console.error(err);
        process.exit(1);
    });
}
