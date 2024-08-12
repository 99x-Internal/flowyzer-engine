
CREATE TABLE "flowyzer_user_roles" (
  "id" uuid PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" text DEFAULT ''
);

CREATE TABLE "flowyzer_users" (
  "id" uuid PRIMARY KEY,
  "email" varchar NOT NULL,
  "name" varchar NOT NULL,
  "profileImg" text DEFAULT '',
  "createdAt" timestamp NOT NULL,
  "updatedAt" timestamp NOT NULL
);

CREATE TABLE "flowyzer_users_roles_associations" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid,
  "role_id" uuid,
  "created_date" timestamp NOT NULL,
  "description" text DEFAULT ''
);

CREATE TABLE "flowyzer_organizations" (
  "id" uuid PRIMARY KEY,
  "name" varchar NOT NULL,
  "isActive" boolean DEFAULT false,
  "createdAt" timestamp NOT NULL,
  "updatedAt" timestamp NOT NULL
);

CREATE TABLE "flowyzer_teams" (
  "id" uuid PRIMARY KEY,
  "name" varchar NOT NULL,
  "organization_id" uuid,
  "createdAt" timestamp NOT NULL,
  "updatedAt" timestamp NOT NULL
);

CREATE TABLE "flowyzer_dashboards" (
  "id" uuid PRIMARY KEY,
  "name" varchar NOT NULL,
  "team_id" uuid
);

CREATE TABLE "flowyzer_connections" (
  "id" uuid PRIMARY KEY,
  "name" varchar NOT NULL,
  "sourceProvider" json,
  "sourceId" uuid,
  "destinationSourceId" uuid,
  "destinationId" uuid,
  "sourceCatalogId" uuid,
  "connectionId" uuid,
  "dashboard_id" uuid
);

CREATE TYPE "flowyzer_sync_status" AS ENUM (
  'scheduled',
  'in_progress',
  'completed',
  'failed'
);

CREATE TABLE "flowyzer_syncs" (
  "id" uuid PRIMARY KEY,
  "jobStarted" timestamp NOT NULL,
  "jobLastUpdated" timestamp NOT NULL,
  "syncDateTime" timestamp NOT NULL,
  "status" flowyzer_sync_status DEFAULT 'scheduled',
  "connection_id" uuid
);

CREATE TABLE "flowyzer_user_organizations" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid,
  "organization_id" uuid,
  "created_date" timestamp NOT NULL
);