-- Function to generate primary keys for models --
create function pkey(variadic list text[]) returns text as
'select array_to_string($1, ''|'', '''')'
language sql immutable;

-- cicd models --
create table "cicd_ArtifactCommitAssociation" (
  id text generated always as (pkey(artifact, commit)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  artifact text,
  commit text
);
create table "cicd_ArtifactDeployment" (
  id text generated always as (pkey(artifact, deployment)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  artifact text,
  deployment text
);
create table "cicd_Artifact" (
  id text generated always as (pkey(repository, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  url text,
  type text,
  "createdAt" timestamptz,
  tags jsonb,
  build text,
  repository text
);
create table "cicd_BuildCommitAssociation" (
  id text generated always as (pkey(build, commit)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  build text,
  commit text
);
create table "cicd_BuildStep" (
  id text generated always as (pkey(build, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  command text,
  type jsonb,
  "createdAt" timestamptz,
  "startedAt" timestamptz,
  "endedAt" timestamptz,
  status jsonb,
  url text,
  build text
);
create table "cicd_Build" (
  id text generated always as (pkey(pipeline, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  number integer,
  "createdAt" timestamptz,
  "startedAt" timestamptz,
  "endedAt" timestamptz,
  status jsonb,
  url text,
  pipeline text
);
create table "cicd_DeploymentChangeset" (
  id text generated always as (pkey(deployment, commit)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  deployment text,
  commit text
);
create table "cicd_Deployment" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  "startedAt" timestamptz,
  "endedAt" timestamptz,
  env jsonb,
  status jsonb,
  source text,
  application text,
  build text
);
create table "cicd_EnvBranchAssociation" (
  id text generated always as (pkey(repository, environment::text)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  environment jsonb,
  branch text,
  repository text
);
create table "cicd_Organization" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  description text,
  url text,
  source text
);
create table "cicd_Pipeline" (
  id text generated always as (pkey(organization, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  description text,
  url text,
  organization text
);
create table "cicd_ReleaseTagAssociation" (
  id text generated always as (pkey(release, tag)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  release text,
  tag text
);
create table "cicd_Release" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  url text,
  description text,
  draft boolean,
  "createdAt" timestamptz,
  "releasedAt" timestamptz,
  source text,
  author text
);
create table "cicd_Repository" (
  id text generated always as (pkey(organization, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  description text,
  url text,
  organization text
);

-- compute models --
create table "compute_ApplicationSource" (
  id text generated always as (pkey(application, repository)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  application text,
  repository text
);
create table "compute_Application" (
  id text generated always as (pkey(uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  platform text
);

-- ims models --
create table "ims_IncidentApplicationImpact" (
  id text generated always as (pkey(incident, application)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  incident text,
  application text
);
create table "ims_IncidentAssignment" (
  id text generated always as (pkey(incident, assignee)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  incident text,
  assignee text
);
create table "ims_IncidentEvent" (
  id text generated always as (pkey(incident, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  type jsonb,
  "createdAt" timestamptz,
  detail text,
  incident text
);
create table "ims_IncidentTag" (
  id text generated always as (pkey(incident, label)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  incident text,
  label text
);
create table "ims_IncidentTasks" (
  id text generated always as (pkey(incident, task)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  incident text,
  task text
);
create table "ims_Incident" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  title text,
  description text,
  url text,
  severity jsonb,
  priority jsonb,
  status jsonb,
  "createdAt" timestamptz,
  "updatedAt" timestamptz,
  "acknowledgedAt" timestamptz,
  "resolvedAt" timestamptz,
  source text
);
create table "ims_Label" (
  id text generated always as (pkey(name)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  name text
);
create table "ims_TeamIncidentAssociation" (
  id text generated always as (pkey(incident, team)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  incident text,
  team text
);
create table "ims_Team" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  url text,
  source text
);
create table "ims_User" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  email text,
  name text,
  source text
);

-- tms models --
create table "tms_Epic" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  description text,
  status jsonb,
  source text,
  project text
);
create table "tms_Label" (
  id text generated always as (pkey(name)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  name text
);
create table "tms_ProjectReleaseRelationship" (
  id text generated always as (pkey(project, release)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  project text,
  release text
);
create table "tms_Project" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  description text,
  "createdAt" timestamptz,
  "updatedAt" timestamptz,
  source text
);
create table "tms_Release" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  description text,
  "startedAt" timestamptz,
  "releasedAt" timestamptz,
  source text
);
create table "tms_Sprint" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  description text,
  "plannedPoints" real,
  "completedPoints" real,
  state jsonb,
  "startedAt" timestamptz,
  "endedAt" timestamptz,
  source text
);
create table "tms_TaskAssignment" (
  id text generated always as (pkey(task, assignee)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  "assignedAt" timestamptz,
  task text,
  assignee text
);
create table "tms_TaskBoardProjectRelationship" (
  id text generated always as (pkey(board, project)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  board text,
  project text
);
create table "tms_TaskBoardRelationship" (
  id text generated always as (pkey(task, board)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  task text,
  board text
);
create table "tms_TaskBoard" (
  id text generated always as (pkey(organization, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  source text,
  organization text
);
create table "tms_TaskDependency" (
  id text generated always as (pkey("dependentTask", "fulfillingTask")) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  blocking boolean,
  "dependentTask" text,
  "fulfillingTask" text
);
create table "tms_TaskProjectRelationship" (
  id text generated always as (pkey(task, project)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  task text,
  project text
);
create table "tms_TaskPullRequestAssociation" (
  id text generated always as (pkey(task, "pullRequest")) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  task text,
  "pullRequest" text
);
create table "tms_TaskReleaseRelationship" (
  id text generated always as (pkey(task, release)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  task text,
  release text
);
create table "tms_TaskTag" (
  id text generated always as (pkey(label, task)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  label text,
  task text
);
create table "tms_Task" (
  id text generated always as (pkey(organization, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  description text,
  url text,
  type jsonb,
  priority text,
  status jsonb,
  points real,
  "additionalFields" jsonb,
  "createdAt" timestamptz,
  "updatedAt" timestamptz,
  "statusChangedAt" timestamptz,
  "statusChangelog" jsonb,
  source text,
  parent text,
  creator text,
  epic text,
  sprint text,
  organization text
);
create table "tms_User" (
  id text generated always as (pkey(organization, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  "emailAddress" text,
  name text,
  source text,
  organization text
);

-- vcs models --
create table "vcs_BranchCommitAssociation" (
  id text generated always as (pkey(commit, branch)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  commit text,
  branch text
);
create table "vcs_Branch" (
  id text generated always as (pkey(repository, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  repository text
);
create table "vcs_Commit" (
  id text generated always as (pkey(repository, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  sha text,
  message text,
  url text,
  "createdAt" timestamptz,
  author text,
  repository text
);
create table "vcs_Membership" (
  id text generated always as (pkey(organization, "user")) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  organization text,
  "user" text
);
create table "vcs_Organization" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  url text,
  type jsonb,
  source text,
  "createdAt" timestamptz
);
create table "vcs_PullRequestComment" (
  id text generated always as (pkey("pullRequest", uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  number bigint,
  comment text,
  "createdAt" timestamptz,
  "updatedAt" timestamptz,
  author text,
  "pullRequest" text
);
create table "vcs_PullRequestReview" (
  id text generated always as (pkey("pullRequest", uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  number bigint,
  url text,
  state jsonb,
  "submittedAt" timestamptz,
  reviewer text,
  "pullRequest" text
);
create table "vcs_PullRequest" (
  id text generated always as (pkey(repository, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  number integer,
  title text,
  state jsonb,
  url text,
  "createdAt" timestamptz,
  "updatedAt" timestamptz,
  "mergedAt" timestamptz,
  "commitCount" integer,
  "commentCount" integer,
  "diffStats" jsonb,
  author text,
  "mergeCommit" text,
  repository text
);
create table "vcs_Repository" (
  id text generated always as (pkey(organization, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  "fullName" text,
  private boolean,
  description text,
  language text,
  size bigint,
  "mainBranch" text,
  url text,
  "createdAt" timestamptz,
  "updatedAt" timestamptz,
  organization text
);
create table "vcs_Tag" (
  id text generated always as (pkey(repository, name)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  name text,
  message text,
  commit text,
  repository text
);
create table "vcs_User" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  email text,
  type jsonb,
  url text,
  source text
);
