-- Inserting into flowyzer_organizations
INSERT INTO "flowyzer_organizations" ("id", "name", "isActive", "createdAt", "updatedAt")
VALUES
('d902f6a0-5315-49ea-9ebb-65c3df507de3', 'SAMPLE-AS-Norway', false, '2024-06-18T05:32:09.254Z', '2024-06-18T05:32:09.254Z');

-- Inserting into flowyzer_teams
INSERT INTO "flowyzer_teams" ("id", "name", "organization_id", "createdAt", "updatedAt")
VALUES
('f63597b2-1ead-4800-b5e5-5c0dce21750e', 'SAMPLE', 'd902f6a0-5315-49ea-9ebb-65c3df507de3', '2024-06-18T05:32:09.254Z', '2024-06-18T05:32:09.254Z');

-- Inserting into flowyzer_dashboards
INSERT INTO "flowyzer_dashboards" ("id", "name", "team_id")
VALUES
('85d0c497-3eb5-4369-ae98-6331d6249bad', 'SAMPLE Dashboard', 'f63597b2-1ead-4800-b5e5-5c0dce21750e');

-- Inserting into flowyzer_connections
INSERT INTO "flowyzer_connections" ("id", "name", "sourceProvider", "sourceId", "destinationSourceId", "destinationId", "sourceCatalogId", "connectionId", "dashboard_id")
VALUES
('5918e9fc-d958-4f27-9344-eda48612cefb', 'SAMPLE-AS-Norway-SAMPLE-AzureRepo<->Faros Destination', '{"apiUrl":"https://dev.azure.com", "apiVersion":"7.0", "pageSize":100, "maxRetries":3, "graphApiUrl":"https://vssps.dev.azure.com", "graphVersion":"7.1-preview.1", "requestTimeout":60000, "rejectUnauthorized":true, "kind":"AzureRepo", "branchName":".*", "name":"SAMPLE-AS-Norway-SAMPLE-AzureRepo", "organization":"SAMPLE-AS-Norway", "accessToken":"Sample_token", "projects":["SAMPLE"], "refreshToken":"sample_token", "lastRenewed":"2024-06-27T07:16:02.148Z"}', '751f0de4-6446-429f-8145-d00e0238144d', '76018b0c-1db4-483b-b1d7-f54c0ceb7533', 'c6ae16ef-7fd1-4472-873b-1e6498913e7a', '11c8bb04-9138-41bb-b817-fdb53bcfc236', 'b8fc3678-4d50-4a09-93dc-e7a9983a4adc', '85d0c497-3eb5-4369-ae98-6331d6249bad'),
('5220dcbf-3d39-4803-9467-00e7f23ee9db', 'SAMPLE-AS-Norway-SAMPLE-AzureWorkItems<->Faros Destination', '{"apiVersion":"7.0", "graphVersion":"7.1-preview.1", "requestTimeout":60000, "kind":"AzureWorkItems", "name":"SAMPLE-AS-Norway-SAMPLE-AzureWorkItems", "organization":"SAMPLE-AS-Norway", "accessToken":"sample_token", "projects":["SAMPLE"], "refreshToken":"sample_token"}', 'f7d18b3d-7462-4b4b-b470-7623ce3199fb', '76018b0c-1db4-483b-b1d7-f54c0ceb7533', 'c6ae16ef-7fd1-4472-873b-1e6498913e7a', '2ca33027-59ff-442c-bebd-436eb7258f3d', 'ee3b84ab-f3f0-43d3-a0a2-6117df2e330e', '85d0c497-3eb5-4369-ae98-6331d6249bad');

-- Inserting into flowyzer_syncs
INSERT INTO "flowyzer_syncs" ("id", "jobStarted", "jobLastUpdated", "syncDateTime", "status", "connection_id")
VALUES
('a23e7e12-2582-4ab3-8ce9-491906d2d111', '2024-06-18T05:33:23.226Z', '2024-06-18T05:33:23.226Z', '2024-06-18T05:33:23.226Z', 'completed', '5918e9fc-d958-4f27-9344-eda48612cefb'),
('80674683-7dc9-4178-9df6-9cdd402b9f59', '2024-06-18T05:33:23.217Z', '2024-06-18T05:33:23.217Z', '2024-06-18T05:33:23.217Z', 'completed', '5220dcbf-3d39-4803-9467-00e7f23ee9db');

-- Inserting into flowyzer_user_roles
INSERT INTO "flowyzer_user_roles" ("id", "name", "description")
VALUES
('c0a29fde-3f0d-424a-a582-89fe8eaf7f68', 'Administrator', 'Role assigned to system administrators with full access');

-- Inserting into flowyzer_users
INSERT INTO "flowyzer_users" ("id", "email", "name", "profileImg", "createdAt", "updatedAt")
VALUES
('01008ea5-b677-4727-9b51-49293fbad342', 'surenr@99x.io', 'Suren Rodrigo', '', '2024-06-18T05:33:23.396Z', '2024-06-18T05:33:23.396Z');

-- Insert into flowyzer_users_roles_associations
INSERT INTO "flowyzer_users_roles_associations" ("id", "user_id", "role_id", "created_date", "description")
VALUES
('65fc0b14-77aa-4cea-b6cd-fea611cc1dc9', '01008ea5-b677-4727-9b51-49293fbad342', 'c0a29fde-3f0d-424a-a582-89fe8eaf7f68', '2024-06-18T05:33:23.396Z', 'Role assigned to system administrators with full access');

-- Insert into flowyzer_user_organizations
INSERT INTO "flowyzer_user_organizations" ( "id", "user_id", "organization_id", "created_date")
VALUES
('f0b1b1b4-0b1b-4b1b-8b1b-1b1b1b1b1b1b', '01008ea5-b677-4727-9b51-49293fbad342', 'd902f6a0-5315-49ea-9ebb-65c3df507de3', '2024-06-18T05:33:23.396Z');