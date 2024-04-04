import { AxiosInstance } from 'axios';
export declare const FAROS_DEST_REPO = "farosai/airbyte-faros-destination";
interface SegmentUser {
    readonly userId: string;
    readonly email: string;
    readonly version: string;
    readonly source: string;
}
export declare class AirbyteInit {
    private readonly api;
    constructor(api: AxiosInstance);
    waitUntilHealthy(): Promise<void>;
    static makeSegmentUser(): SegmentUser | undefined;
    static sendIdentityAndStartEvent(segmentUser: SegmentUser | undefined, host?: string | undefined): Promise<void>;
    setupWorkspace(segmentUser: SegmentUser | undefined, hasuraAdminSecret: string, airbyteDestinationHasuraUrl: string, forceSetup?: boolean): Promise<void>;
    static getLatestImageTag(repository: string, page?: number, pageSize?: number): Promise<string>;
}
export {};
