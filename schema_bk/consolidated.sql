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
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  name text,
  source text
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
  id text generated always as (pkey(source, uid)) stored primary key,
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
  sprint text
);
create table "tms_User" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text not null,
  "emailAddress" text,
  name text,
  source text
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

-- foreign keys --
alter table "cicd_Artifact" add foreign key (build) references "cicd_Build"(id);
alter table "cicd_Artifact" add foreign key (repository) references "cicd_Repository"(id);
alter table "cicd_ArtifactCommitAssociation" add foreign key (artifact) references "cicd_Artifact"(id);
alter table "cicd_ArtifactCommitAssociation" add foreign key (commit) references "vcs_Commit"(id);
alter table "cicd_ArtifactDeployment" add foreign key (artifact) references "cicd_Artifact"(id);
alter table "cicd_ArtifactDeployment" add foreign key (deployment) references "cicd_Deployment"(id);
alter table "cicd_Build" add foreign key (pipeline) references "cicd_Pipeline"(id);
alter table "cicd_BuildCommitAssociation" add foreign key (build) references "cicd_Build"(id);
alter table "cicd_BuildCommitAssociation" add foreign key (commit) references "vcs_Commit"(id);
alter table "cicd_BuildStep" add foreign key (build) references "cicd_Build"(id);
alter table "cicd_Deployment" add foreign key (application) references "compute_Application"(id);
alter table "cicd_Deployment" add foreign key (build) references "cicd_Build"(id);
alter table "cicd_DeploymentChangeset" add foreign key (commit) references "vcs_Commit"(id);
alter table "cicd_DeploymentChangeset" add foreign key (deployment) references "cicd_Deployment"(id);
alter table "cicd_EnvBranchAssociation" add foreign key (branch) references "vcs_Branch"(id);
alter table "cicd_EnvBranchAssociation" add foreign key (repository) references "vcs_Repository"(id);
alter table "cicd_Pipeline" add foreign key (organization) references "cicd_Organization"(id);
alter table "cicd_Release" add foreign key (author) references "vcs_User"(id);
alter table "cicd_ReleaseTagAssociation" add foreign key (release) references "cicd_Release"(id);
alter table "cicd_ReleaseTagAssociation" add foreign key (tag) references "vcs_Tag"(id);
alter table "cicd_Repository" add foreign key (organization) references "cicd_Organization"(id);
alter table "compute_ApplicationSource" add foreign key (application) references "compute_Application"(id);
alter table "compute_ApplicationSource" add foreign key (repository) references "vcs_Repository"(id);
alter table "ims_IncidentApplicationImpact" add foreign key (application) references "compute_Application"(id);
alter table "ims_IncidentApplicationImpact" add foreign key (incident) references "ims_Incident"(id);
alter table "ims_IncidentAssignment" add foreign key (assignee) references "ims_User"(id);
alter table "ims_IncidentAssignment" add foreign key (incident) references "ims_Incident"(id);
alter table "ims_IncidentEvent" add foreign key (incident) references "ims_Incident"(id);
alter table "ims_IncidentTag" add foreign key (incident) references "ims_Incident"(id);
alter table "ims_IncidentTag" add foreign key (label) references "ims_Label"(id);
alter table "ims_IncidentTasks" add foreign key (incident) references "ims_Incident"(id);
alter table "ims_IncidentTasks" add foreign key (task) references "tms_Task"(id);
alter table "ims_TeamIncidentAssociation" add foreign key (incident) references "ims_Incident"(id);
alter table "ims_TeamIncidentAssociation" add foreign key (team) references "ims_Team"(id);
alter table "tms_Epic" add foreign key (project) references "tms_Project"(id);
alter table "tms_ProjectReleaseRelationship" add foreign key (project) references "tms_Project"(id);
alter table "tms_ProjectReleaseRelationship" add foreign key (release) references "tms_Release"(id);
alter table "tms_Task" add foreign key (creator) references "tms_User"(id);
alter table "tms_Task" add foreign key (epic) references "tms_Epic"(id);
alter table "tms_Task" add foreign key (parent) references "tms_Task"(id);
alter table "tms_Task" add foreign key (sprint) references "tms_Sprint"(id);
alter table "tms_TaskAssignment" add foreign key (assignee) references "tms_User"(id);
alter table "tms_TaskAssignment" add foreign key (task) references "tms_Task"(id);
alter table "tms_TaskBoardProjectRelationship" add foreign key (board) references "tms_TaskBoard"(id);
alter table "tms_TaskBoardProjectRelationship" add foreign key (project) references "tms_Project"(id);
alter table "tms_TaskBoardRelationship" add foreign key (board) references "tms_TaskBoard"(id);
alter table "tms_TaskBoardRelationship" add foreign key (task) references "tms_Task"(id);
alter table "tms_TaskDependency" add foreign key ("dependentTask") references "tms_Task"(id);
alter table "tms_TaskDependency" add foreign key ("fulfillingTask") references "tms_Task"(id);
alter table "tms_TaskProjectRelationship" add foreign key (project) references "tms_Project"(id);
alter table "tms_TaskProjectRelationship" add foreign key (task) references "tms_Task"(id);
alter table "tms_TaskPullRequestAssociation" add foreign key ("pullRequest") references "vcs_PullRequest"(id);
alter table "tms_TaskPullRequestAssociation" add foreign key (task) references "tms_Task"(id);
alter table "tms_TaskReleaseRelationship" add foreign key (release) references "tms_Release"(id);
alter table "tms_TaskReleaseRelationship" add foreign key (task) references "tms_Task"(id);
alter table "tms_TaskTag" add foreign key (label) references "tms_Label"(id);
alter table "tms_TaskTag" add foreign key (task) references "tms_Task"(id);
alter table "vcs_Branch" add foreign key (repository) references "vcs_Repository"(id);
alter table "vcs_BranchCommitAssociation" add foreign key (branch) references "vcs_Branch"(id);
alter table "vcs_BranchCommitAssociation" add foreign key (commit) references "vcs_Commit"(id);
alter table "vcs_Commit" add foreign key (author) references "vcs_User"(id);
alter table "vcs_Commit" add foreign key (repository) references "vcs_Repository"(id);
alter table "vcs_Membership" add foreign key ("user") references "vcs_User"(id);
alter table "vcs_Membership" add foreign key (organization) references "vcs_Organization"(id);
alter table "vcs_PullRequest" add foreign key ("mergeCommit") references "vcs_Commit"(id);
alter table "vcs_PullRequest" add foreign key (author) references "vcs_User"(id);
alter table "vcs_PullRequest" add foreign key (repository) references "vcs_Repository"(id);
alter table "vcs_PullRequestComment" add foreign key ("pullRequest") references "vcs_PullRequest"(id);
alter table "vcs_PullRequestComment" add foreign key (author) references "vcs_User"(id);
alter table "vcs_PullRequestReview" add foreign key ("pullRequest") references "vcs_PullRequest"(id);
alter table "vcs_PullRequestReview" add foreign key (reviewer) references "vcs_User"(id);
alter table "vcs_Repository" add foreign key (organization) references "vcs_Organization"(id);
alter table "vcs_Tag" add foreign key (commit) references "vcs_Commit"(id);
alter table "vcs_Tag" add foreign key (repository) references "vcs_Repository"(id);
create index "cicd_ArtifactCommitAssociation_origin_idx" on "cicd_ArtifactCommitAssociation"(origin);
create index "cicd_ArtifactCommitAssociation_artifact_idx" on "cicd_ArtifactCommitAssociation"(artifact);
create index "cicd_ArtifactCommitAssociation_commit_idx" on "cicd_ArtifactCommitAssociation"(commit);
create index "cicd_ArtifactDeployment_origin_idx" on "cicd_ArtifactDeployment"(origin);
create index "cicd_ArtifactDeployment_artifact_idx" on "cicd_ArtifactDeployment"(artifact);
create index "cicd_ArtifactDeployment_deployment_idx" on "cicd_ArtifactDeployment"(deployment);
create index "cicd_Artifact_origin_idx" on "cicd_Artifact"(origin);
create index "cicd_Artifact_uid_idx" on "cicd_Artifact"(uid);
create index "cicd_Artifact_name_idx" on "cicd_Artifact"(name);
create index "cicd_Artifact_type_idx" on "cicd_Artifact"(type);
create index "cicd_Artifact_createdAt_idx" on "cicd_Artifact"("createdAt");
create index "cicd_Artifact_tags_idx" on "cicd_Artifact" using gin(tags);
create index "cicd_Artifact_build_idx" on "cicd_Artifact"(build);
create index "cicd_Artifact_repository_idx" on "cicd_Artifact"(repository);
create index "cicd_BuildCommitAssociation_origin_idx" on "cicd_BuildCommitAssociation"(origin);
create index "cicd_BuildCommitAssociation_build_idx" on "cicd_BuildCommitAssociation"(build);
create index "cicd_BuildCommitAssociation_commit_idx" on "cicd_BuildCommitAssociation"(commit);
create index "cicd_BuildStep_origin_idx" on "cicd_BuildStep"(origin);
create index "cicd_BuildStep_uid_idx" on "cicd_BuildStep"(uid);
create index "cicd_BuildStep_name_idx" on "cicd_BuildStep"(name);
create index "cicd_BuildStep_command_idx" on "cicd_BuildStep"(command);
create index "cicd_BuildStep_type_idx" on "cicd_BuildStep" using gin(type);
create index "cicd_BuildStep_createdAt_idx" on "cicd_BuildStep"("createdAt");
create index "cicd_BuildStep_startedAt_idx" on "cicd_BuildStep"("startedAt");
create index "cicd_BuildStep_endedAt_idx" on "cicd_BuildStep"("endedAt");
create index "cicd_BuildStep_status_idx" on "cicd_BuildStep" using gin(status);
create index "cicd_BuildStep_build_idx" on "cicd_BuildStep"(build);
create index "cicd_Build_origin_idx" on "cicd_Build"(origin);
create index "cicd_Build_uid_idx" on "cicd_Build"(uid);
create index "cicd_Build_name_idx" on "cicd_Build"(name);
create index "cicd_Build_number_idx" on "cicd_Build"(number);
create index "cicd_Build_createdAt_idx" on "cicd_Build"("createdAt");
create index "cicd_Build_startedAt_idx" on "cicd_Build"("startedAt");
create index "cicd_Build_endedAt_idx" on "cicd_Build"("endedAt");
create index "cicd_Build_status_idx" on "cicd_Build" using gin(status);
create index "cicd_Build_pipeline_idx" on "cicd_Build"(pipeline);
create index "cicd_DeploymentChangeset_origin_idx" on "cicd_DeploymentChangeset"(origin);
create index "cicd_DeploymentChangeset_deployment_idx" on "cicd_DeploymentChangeset"(deployment);
create index "cicd_DeploymentChangeset_commit_idx" on "cicd_DeploymentChangeset"(commit);
create index "cicd_Deployment_origin_idx" on "cicd_Deployment"(origin);
create index "cicd_Deployment_uid_idx" on "cicd_Deployment"(uid);
create index "cicd_Deployment_startedAt_idx" on "cicd_Deployment"("startedAt");
create index "cicd_Deployment_endedAt_idx" on "cicd_Deployment"("endedAt");
create index "cicd_Deployment_env_idx" on "cicd_Deployment" using gin(env);
create index "cicd_Deployment_status_idx" on "cicd_Deployment" using gin(status);
create index "cicd_Deployment_source_idx" on "cicd_Deployment"(source);
create index "cicd_Deployment_application_idx" on "cicd_Deployment"(application);
create index "cicd_Deployment_build_idx" on "cicd_Deployment"(build);
create index "cicd_EnvBranchAssociation_origin_idx" on "cicd_EnvBranchAssociation"(origin);
create index "cicd_EnvBranchAssociation_environment_idx" on "cicd_EnvBranchAssociation" using gin(environment);
create index "cicd_EnvBranchAssociation_branch_idx" on "cicd_EnvBranchAssociation"(branch);
create index "cicd_EnvBranchAssociation_repository_idx" on "cicd_EnvBranchAssociation"(repository);
create index "cicd_Organization_origin_idx" on "cicd_Organization"(origin);
create index "cicd_Organization_uid_idx" on "cicd_Organization"(uid);
create index "cicd_Organization_name_idx" on "cicd_Organization"(name);
create index "cicd_Organization_source_idx" on "cicd_Organization"(source);
create index "cicd_Pipeline_origin_idx" on "cicd_Pipeline"(origin);
create index "cicd_Pipeline_uid_idx" on "cicd_Pipeline"(uid);
create index "cicd_Pipeline_name_idx" on "cicd_Pipeline"(name);
create index "cicd_Pipeline_organization_idx" on "cicd_Pipeline"(organization);
create index "cicd_ReleaseTagAssociation_origin_idx" on "cicd_ReleaseTagAssociation"(origin);
create index "cicd_ReleaseTagAssociation_release_idx" on "cicd_ReleaseTagAssociation"(release);
create index "cicd_ReleaseTagAssociation_tag_idx" on "cicd_ReleaseTagAssociation"(tag);
create index "cicd_Release_origin_idx" on "cicd_Release"(origin);
create index "cicd_Release_uid_idx" on "cicd_Release"(uid);
create index "cicd_Release_name_idx" on "cicd_Release"(name);
create index "cicd_Release_draft_idx" on "cicd_Release"(draft);
create index "cicd_Release_createdAt_idx" on "cicd_Release"("createdAt");
create index "cicd_Release_releasedAt_idx" on "cicd_Release"("releasedAt");
create index "cicd_Release_source_idx" on "cicd_Release"(source);
create index "cicd_Release_author_idx" on "cicd_Release"(author);
create index "cicd_Repository_origin_idx" on "cicd_Repository"(origin);
create index "cicd_Repository_uid_idx" on "cicd_Repository"(uid);
create index "cicd_Repository_name_idx" on "cicd_Repository"(name);
create index "cicd_Repository_organization_idx" on "cicd_Repository"(organization);
create index "compute_ApplicationSource_origin_idx" on "compute_ApplicationSource"(origin);
create index "compute_ApplicationSource_application_idx" on "compute_ApplicationSource"(application);
create index "compute_ApplicationSource_repository_idx" on "compute_ApplicationSource"(repository);
create index "compute_Application_origin_idx" on "compute_Application"(origin);
create index "compute_Application_uid_idx" on "compute_Application"(uid);
create index "compute_Application_name_idx" on "compute_Application"(name);
create index "compute_Application_platform_idx" on "compute_Application"(platform);
create index "ims_IncidentApplicationImpact_origin_idx" on "ims_IncidentApplicationImpact"(origin);
create index "ims_IncidentApplicationImpact_incident_idx" on "ims_IncidentApplicationImpact"(incident);
create index "ims_IncidentApplicationImpact_application_idx" on "ims_IncidentApplicationImpact"(application);
create index "ims_IncidentAssignment_origin_idx" on "ims_IncidentAssignment"(origin);
create index "ims_IncidentAssignment_incident_idx" on "ims_IncidentAssignment"(incident);
create index "ims_IncidentAssignment_assignee_idx" on "ims_IncidentAssignment"(assignee);
create index "ims_IncidentEvent_origin_idx" on "ims_IncidentEvent"(origin);
create index "ims_IncidentEvent_uid_idx" on "ims_IncidentEvent"(uid);
create index "ims_IncidentEvent_type_idx" on "ims_IncidentEvent" using gin(type);
create index "ims_IncidentEvent_createdAt_idx" on "ims_IncidentEvent"("createdAt");
create index "ims_IncidentEvent_detail_idx" on "ims_IncidentEvent"(detail);
create index "ims_IncidentEvent_incident_idx" on "ims_IncidentEvent"(incident);
create index "ims_IncidentTag_origin_idx" on "ims_IncidentTag"(origin);
create index "ims_IncidentTag_incident_idx" on "ims_IncidentTag"(incident);
create index "ims_IncidentTag_label_idx" on "ims_IncidentTag"(label);
create index "ims_IncidentTasks_origin_idx" on "ims_IncidentTasks"(origin);
create index "ims_IncidentTasks_incident_idx" on "ims_IncidentTasks"(incident);
create index "ims_IncidentTasks_task_idx" on "ims_IncidentTasks"(task);
create index "ims_Incident_origin_idx" on "ims_Incident"(origin);
create index "ims_Incident_uid_idx" on "ims_Incident"(uid);
create index "ims_Incident_title_idx" on "ims_Incident"(title);
create index "ims_Incident_severity_idx" on "ims_Incident" using gin(severity);
create index "ims_Incident_priority_idx" on "ims_Incident" using gin(priority);
create index "ims_Incident_status_idx" on "ims_Incident" using gin(status);
create index "ims_Incident_createdAt_idx" on "ims_Incident"("createdAt");
create index "ims_Incident_updatedAt_idx" on "ims_Incident"("updatedAt");
create index "ims_Incident_acknowledgedAt_idx" on "ims_Incident"("acknowledgedAt");
create index "ims_Incident_resolvedAt_idx" on "ims_Incident"("resolvedAt");
create index "ims_Incident_source_idx" on "ims_Incident"(source);
create index "ims_Label_origin_idx" on "ims_Label"(origin);
create index "ims_Label_name_idx" on "ims_Label"(name);
create index "ims_TeamIncidentAssociation_origin_idx" on "ims_TeamIncidentAssociation"(origin);
create index "ims_TeamIncidentAssociation_incident_idx" on "ims_TeamIncidentAssociation"(incident);
create index "ims_TeamIncidentAssociation_team_idx" on "ims_TeamIncidentAssociation"(team);
create index "ims_Team_origin_idx" on "ims_Team"(origin);
create index "ims_Team_uid_idx" on "ims_Team"(uid);
create index "ims_Team_name_idx" on "ims_Team"(name);
create index "ims_Team_source_idx" on "ims_Team"(source);
create index "ims_User_origin_idx" on "ims_User"(origin);
create index "ims_User_uid_idx" on "ims_User"(uid);
create index "ims_User_email_idx" on "ims_User"(email);
create index "ims_User_name_idx" on "ims_User"(name);
create index "ims_User_source_idx" on "ims_User"(source);
create index "tms_Epic_origin_idx" on "tms_Epic"(origin);
create index "tms_Epic_uid_idx" on "tms_Epic"(uid);
create index "tms_Epic_name_idx" on "tms_Epic"(name);
create index "tms_Epic_status_idx" on "tms_Epic" using gin(status);
create index "tms_Epic_source_idx" on "tms_Epic"(source);
create index "tms_Epic_project_idx" on "tms_Epic"(project);
create index "tms_Label_origin_idx" on "tms_Label"(origin);
create index "tms_Label_name_idx" on "tms_Label"(name);
create index "tms_ProjectReleaseRelationship_origin_idx" on "tms_ProjectReleaseRelationship"(origin);
create index "tms_ProjectReleaseRelationship_project_idx" on "tms_ProjectReleaseRelationship"(project);
create index "tms_ProjectReleaseRelationship_release_idx" on "tms_ProjectReleaseRelationship"(release);
create index "tms_Project_origin_idx" on "tms_Project"(origin);
create index "tms_Project_uid_idx" on "tms_Project"(uid);
create index "tms_Project_name_idx" on "tms_Project"(name);
create index "tms_Project_createdAt_idx" on "tms_Project"("createdAt");
create index "tms_Project_updatedAt_idx" on "tms_Project"("updatedAt");
create index "tms_Project_source_idx" on "tms_Project"(source);
create index "tms_Release_origin_idx" on "tms_Release"(origin);
create index "tms_Release_uid_idx" on "tms_Release"(uid);
create index "tms_Release_name_idx" on "tms_Release"(name);
create index "tms_Release_startedAt_idx" on "tms_Release"("startedAt");
create index "tms_Release_releasedAt_idx" on "tms_Release"("releasedAt");
create index "tms_Release_source_idx" on "tms_Release"(source);
create index "tms_Sprint_origin_idx" on "tms_Sprint"(origin);
create index "tms_Sprint_uid_idx" on "tms_Sprint"(uid);
create index "tms_Sprint_name_idx" on "tms_Sprint"(name);
create index "tms_Sprint_plannedPoints_idx" on "tms_Sprint"("plannedPoints");
create index "tms_Sprint_completedPoints_idx" on "tms_Sprint"("completedPoints");
create index "tms_Sprint_state_idx" on "tms_Sprint" using gin(state);
create index "tms_Sprint_startedAt_idx" on "tms_Sprint"("startedAt");
create index "tms_Sprint_endedAt_idx" on "tms_Sprint"("endedAt");
create index "tms_Sprint_source_idx" on "tms_Sprint"(source);
create index "tms_TaskAssignment_origin_idx" on "tms_TaskAssignment"(origin);
create index "tms_TaskAssignment_assignedAt_idx" on "tms_TaskAssignment"("assignedAt");
create index "tms_TaskAssignment_task_idx" on "tms_TaskAssignment"(task);
create index "tms_TaskAssignment_assignee_idx" on "tms_TaskAssignment"(assignee);
create index "tms_TaskBoardProjectRelationship_origin_idx" on "tms_TaskBoardProjectRelationship"(origin);
create index "tms_TaskBoardProjectRelationship_board_idx" on "tms_TaskBoardProjectRelationship"(board);
create index "tms_TaskBoardProjectRelationship_project_idx" on "tms_TaskBoardProjectRelationship"(project);
create index "tms_TaskBoardRelationship_origin_idx" on "tms_TaskBoardRelationship"(origin);
create index "tms_TaskBoardRelationship_task_idx" on "tms_TaskBoardRelationship"(task);
create index "tms_TaskBoardRelationship_board_idx" on "tms_TaskBoardRelationship"(board);
create index "tms_TaskBoard_origin_idx" on "tms_TaskBoard"(origin);
create index "tms_TaskBoard_uid_idx" on "tms_TaskBoard"(uid);
create index "tms_TaskBoard_name_idx" on "tms_TaskBoard"(name);
create index "tms_TaskBoard_source_idx" on "tms_TaskBoard"(source);
create index "tms_TaskDependency_origin_idx" on "tms_TaskDependency"(origin);
create index "tms_TaskDependency_blocking_idx" on "tms_TaskDependency"(blocking);
create index "tms_TaskDependency_dependentTask_idx" on "tms_TaskDependency"("dependentTask");
create index "tms_TaskDependency_fulfillingTask_idx" on "tms_TaskDependency"("fulfillingTask");
create index "tms_TaskProjectRelationship_origin_idx" on "tms_TaskProjectRelationship"(origin);
create index "tms_TaskProjectRelationship_task_idx" on "tms_TaskProjectRelationship"(task);
create index "tms_TaskProjectRelationship_project_idx" on "tms_TaskProjectRelationship"(project);
create index "tms_TaskPullRequestAssociation_origin_idx" on "tms_TaskPullRequestAssociation"(origin);
create index "tms_TaskPullRequestAssociation_task_idx" on "tms_TaskPullRequestAssociation"(task);
create index "tms_TaskPullRequestAssociation_pullRequest_idx" on "tms_TaskPullRequestAssociation"("pullRequest");
create index "tms_TaskReleaseRelationship_origin_idx" on "tms_TaskReleaseRelationship"(origin);
create index "tms_TaskReleaseRelationship_task_idx" on "tms_TaskReleaseRelationship"(task);
create index "tms_TaskReleaseRelationship_release_idx" on "tms_TaskReleaseRelationship"(release);
create index "tms_TaskTag_origin_idx" on "tms_TaskTag"(origin);
create index "tms_TaskTag_label_idx" on "tms_TaskTag"(label);
create index "tms_TaskTag_task_idx" on "tms_TaskTag"(task);
create index "tms_Task_origin_idx" on "tms_Task"(origin);
create index "tms_Task_uid_idx" on "tms_Task"(uid);
create index "tms_Task_name_idx" on "tms_Task"(name);
create index "tms_Task_type_idx" on "tms_Task" using gin(type);
create index "tms_Task_priority_idx" on "tms_Task"(priority);
create index "tms_Task_status_idx" on "tms_Task" using gin(status);
create index "tms_Task_points_idx" on "tms_Task"(points);
create index "tms_Task_additionalFields_idx" on "tms_Task" using gin("additionalFields");
create index "tms_Task_createdAt_idx" on "tms_Task"("createdAt");
create index "tms_Task_updatedAt_idx" on "tms_Task"("updatedAt");
create index "tms_Task_statusChangedAt_idx" on "tms_Task"("statusChangedAt");
create index "tms_Task_statusChangelog_idx" on "tms_Task" using gin("statusChangelog");
create index "tms_Task_source_idx" on "tms_Task"(source);
create index "tms_Task_parent_idx" on "tms_Task"(parent);
create index "tms_Task_creator_idx" on "tms_Task"(creator);
create index "tms_Task_epic_idx" on "tms_Task"(epic);
create index "tms_Task_sprint_idx" on "tms_Task"(sprint);
create index "tms_User_origin_idx" on "tms_User"(origin);
create index "tms_User_uid_idx" on "tms_User"(uid);
create index "tms_User_emailAddress_idx" on "tms_User"("emailAddress");
create index "tms_User_name_idx" on "tms_User"(name);
create index "tms_User_source_idx" on "tms_User"(source);
create index "vcs_BranchCommitAssociation_origin_idx" on "vcs_BranchCommitAssociation"(origin);
create index "vcs_BranchCommitAssociation_commit_idx" on "vcs_BranchCommitAssociation"(commit);
create index "vcs_BranchCommitAssociation_branch_idx" on "vcs_BranchCommitAssociation"(branch);
create index "vcs_Branch_origin_idx" on "vcs_Branch"(origin);
create index "vcs_Branch_uid_idx" on "vcs_Branch"(uid);
create index "vcs_Branch_name_idx" on "vcs_Branch"(name);
create index "vcs_Branch_repository_idx" on "vcs_Branch"(repository);
create index "vcs_Commit_origin_idx" on "vcs_Commit"(origin);
create index "vcs_Commit_uid_idx" on "vcs_Commit"(uid);
create index "vcs_Commit_sha_idx" on "vcs_Commit"(sha);
create index "vcs_Commit_message_idx" on "vcs_Commit"(message);
create index "vcs_Commit_createdAt_idx" on "vcs_Commit"("createdAt");
create index "vcs_Commit_author_idx" on "vcs_Commit"(author);
create index "vcs_Commit_repository_idx" on "vcs_Commit"(repository);
create index "vcs_Membership_origin_idx" on "vcs_Membership"(origin);
create index "vcs_Membership_organization_idx" on "vcs_Membership"(organization);
create index "vcs_Membership_user_idx" on "vcs_Membership"("user");
create index "vcs_Organization_origin_idx" on "vcs_Organization"(origin);
create index "vcs_Organization_uid_idx" on "vcs_Organization"(uid);
create index "vcs_Organization_name_idx" on "vcs_Organization"(name);
create index "vcs_Organization_type_idx" on "vcs_Organization" using gin(type);
create index "vcs_Organization_source_idx" on "vcs_Organization"(source);
create index "vcs_Organization_createdAt_idx" on "vcs_Organization"("createdAt");
create index "vcs_PullRequestComment_origin_idx" on "vcs_PullRequestComment"(origin);
create index "vcs_PullRequestComment_uid_idx" on "vcs_PullRequestComment"(uid);
create index "vcs_PullRequestComment_number_idx" on "vcs_PullRequestComment"(number);
create index "vcs_PullRequestComment_comment_idx" on "vcs_PullRequestComment"(comment);
create index "vcs_PullRequestComment_createdAt_idx" on "vcs_PullRequestComment"("createdAt");
create index "vcs_PullRequestComment_updatedAt_idx" on "vcs_PullRequestComment"("updatedAt");
create index "vcs_PullRequestComment_author_idx" on "vcs_PullRequestComment"(author);
create index "vcs_PullRequestComment_pullRequest_idx" on "vcs_PullRequestComment"("pullRequest");
create index "vcs_PullRequestReview_origin_idx" on "vcs_PullRequestReview"(origin);
create index "vcs_PullRequestReview_uid_idx" on "vcs_PullRequestReview"(uid);
create index "vcs_PullRequestReview_number_idx" on "vcs_PullRequestReview"(number);
create index "vcs_PullRequestReview_state_idx" on "vcs_PullRequestReview" using gin(state);
create index "vcs_PullRequestReview_submittedAt_idx" on "vcs_PullRequestReview"("submittedAt");
create index "vcs_PullRequestReview_reviewer_idx" on "vcs_PullRequestReview"(reviewer);
create index "vcs_PullRequestReview_pullRequest_idx" on "vcs_PullRequestReview"("pullRequest");
create index "vcs_PullRequest_origin_idx" on "vcs_PullRequest"(origin);
create index "vcs_PullRequest_uid_idx" on "vcs_PullRequest"(uid);
create index "vcs_PullRequest_number_idx" on "vcs_PullRequest"(number);
create index "vcs_PullRequest_title_idx" on "vcs_PullRequest"(title);
create index "vcs_PullRequest_state_idx" on "vcs_PullRequest" using gin(state);
create index "vcs_PullRequest_createdAt_idx" on "vcs_PullRequest"("createdAt");
create index "vcs_PullRequest_updatedAt_idx" on "vcs_PullRequest"("updatedAt");
create index "vcs_PullRequest_mergedAt_idx" on "vcs_PullRequest"("mergedAt");
create index "vcs_PullRequest_commitCount_idx" on "vcs_PullRequest"("commitCount");
create index "vcs_PullRequest_commentCount_idx" on "vcs_PullRequest"("commentCount");
create index "vcs_PullRequest_diffStats_idx" on "vcs_PullRequest" using gin("diffStats");
create index "vcs_PullRequest_author_idx" on "vcs_PullRequest"(author);
create index "vcs_PullRequest_mergeCommit_idx" on "vcs_PullRequest"("mergeCommit");
create index "vcs_PullRequest_repository_idx" on "vcs_PullRequest"(repository);
create index "vcs_Repository_origin_idx" on "vcs_Repository"(origin);
create index "vcs_Repository_uid_idx" on "vcs_Repository"(uid);
create index "vcs_Repository_name_idx" on "vcs_Repository"(name);
create index "vcs_Repository_fullName_idx" on "vcs_Repository"("fullName");
create index "vcs_Repository_private_idx" on "vcs_Repository"(private);
create index "vcs_Repository_language_idx" on "vcs_Repository"(language);
create index "vcs_Repository_size_idx" on "vcs_Repository"(size);
create index "vcs_Repository_mainBranch_idx" on "vcs_Repository"("mainBranch");
create index "vcs_Repository_createdAt_idx" on "vcs_Repository"("createdAt");
create index "vcs_Repository_updatedAt_idx" on "vcs_Repository"("updatedAt");
create index "vcs_Repository_organization_idx" on "vcs_Repository"(organization);
create index "vcs_Tag_origin_idx" on "vcs_Tag"(origin);
create index "vcs_Tag_name_idx" on "vcs_Tag"(name);
create index "vcs_Tag_message_idx" on "vcs_Tag"(message);
create index "vcs_Tag_commit_idx" on "vcs_Tag"(commit);
create index "vcs_Tag_repository_idx" on "vcs_Tag"(repository);
create index "vcs_User_origin_idx" on "vcs_User"(origin);
create index "vcs_User_uid_idx" on "vcs_User"(uid);
create index "vcs_User_name_idx" on "vcs_User"(name);
create index "vcs_User_email_idx" on "vcs_User"(email);
create index "vcs_User_type_idx" on "vcs_User" using gin(type);
create index "vcs_User_source_idx" on "vcs_User"(source);
alter table "cicd_BuildStep" add column "typeDetail" text generated always as (type ->> 'detail') stored;
alter table "cicd_BuildStep" add column "typeCategory" text generated always as (type ->> 'category') stored;
alter table "cicd_BuildStep" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "cicd_BuildStep" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "cicd_Build" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "cicd_Build" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "cicd_Deployment" add column "envDetail" text generated always as (env ->> 'detail') stored;
alter table "cicd_Deployment" add column "envCategory" text generated always as (env ->> 'category') stored;
alter table "cicd_Deployment" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "cicd_Deployment" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "cicd_EnvBranchAssociation" add column "environmentDetail" text generated always as (environment ->> 'detail') stored;
alter table "cicd_EnvBranchAssociation" add column "environmentCategory" text generated always as (environment ->> 'category') stored;
alter table "ims_IncidentEvent" add column "typeDetail" text generated always as (type ->> 'detail') stored;
alter table "ims_IncidentEvent" add column "typeCategory" text generated always as (type ->> 'category') stored;
alter table "ims_Incident" add column "severityDetail" text generated always as (severity ->> 'detail') stored;
alter table "ims_Incident" add column "severityCategory" text generated always as (severity ->> 'category') stored;
alter table "ims_Incident" add column "priorityDetail" text generated always as (priority ->> 'detail') stored;
alter table "ims_Incident" add column "priorityCategory" text generated always as (priority ->> 'category') stored;
alter table "ims_Incident" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "ims_Incident" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "tms_Epic" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "tms_Epic" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "tms_Sprint" add column "stateDetail" text generated always as (state ->> 'detail') stored;
alter table "tms_Sprint" add column "stateCategory" text generated always as (state ->> 'category') stored;
alter table "tms_Task" add column "typeDetail" text generated always as (type ->> 'detail') stored;
alter table "tms_Task" add column "typeCategory" text generated always as (type ->> 'category') stored;
alter table "tms_Task" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "tms_Task" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "vcs_Organization" add column "typeDetail" text generated always as (type ->> 'detail') stored;
alter table "vcs_Organization" add column "typeCategory" text generated always as (type ->> 'category') stored;
alter table "vcs_PullRequestReview" add column "stateDetail" text generated always as (state ->> 'detail') stored;
alter table "vcs_PullRequestReview" add column "stateCategory" text generated always as (state ->> 'category') stored;
alter table "vcs_PullRequest" add column "stateDetail" text generated always as (state ->> 'detail') stored;
alter table "vcs_PullRequest" add column "stateCategory" text generated always as (state ->> 'category') stored;
alter table "vcs_PullRequest" add column "linesAdded" integer generated always as (("diffStats" -> 'linesAdded')::integer) stored;
alter table "vcs_PullRequest" add column "linesDeleted" integer generated always as (("diffStats" -> 'linesDeleted')::integer) stored;
alter table "vcs_PullRequest" add column "filesChanged" integer generated always as (("diffStats" -> 'filesChanged')::integer) stored;
alter table "vcs_User" add column "typeDetail" text generated always as (type ->> 'detail') stored;
alter table "vcs_User" add column "typeCategory" text generated always as (type ->> 'category') stored;

-- Mark these columns as 'generated' so that Faros Airbyte Destination will not try to mutate them --
comment on column "cicd_ArtifactCommitAssociation".id is 'generated';
comment on column "cicd_ArtifactDeployment".id is 'generated';
comment on column "cicd_Artifact".id is 'generated';
comment on column "cicd_BuildCommitAssociation".id is 'generated';
comment on column "cicd_BuildStep".id is 'generated';
comment on column "cicd_Build".id is 'generated';
comment on column "cicd_DeploymentChangeset".id is 'generated';
comment on column "cicd_Deployment".id is 'generated';
comment on column "cicd_EnvBranchAssociation".id is 'generated';
comment on column "cicd_Organization".id is 'generated';
comment on column "cicd_Pipeline".id is 'generated';
comment on column "cicd_ReleaseTagAssociation".id is 'generated';
comment on column "cicd_Release".id is 'generated';
comment on column "cicd_Repository".id is 'generated';
comment on column "compute_ApplicationSource".id is 'generated';
comment on column "compute_Application".id is 'generated';
comment on column "ims_IncidentApplicationImpact".id is 'generated';
comment on column "ims_IncidentAssignment".id is 'generated';
comment on column "ims_IncidentEvent".id is 'generated';
comment on column "ims_IncidentTag".id is 'generated';
comment on column "ims_IncidentTasks".id is 'generated';
comment on column "ims_Incident".id is 'generated';
comment on column "ims_Label".id is 'generated';
comment on column "ims_TeamIncidentAssociation".id is 'generated';
comment on column "ims_Team".id is 'generated';
comment on column "ims_User".id is 'generated';
comment on column "tms_Epic".id is 'generated';
comment on column "tms_Label".id is 'generated';
comment on column "tms_ProjectReleaseRelationship".id is 'generated';
comment on column "tms_Project".id is 'generated';
comment on column "tms_Release".id is 'generated';
comment on column "tms_Sprint".id is 'generated';
comment on column "tms_TaskAssignment".id is 'generated';
comment on column "tms_TaskBoardProjectRelationship".id is 'generated';
comment on column "tms_TaskBoardRelationship".id is 'generated';
comment on column "tms_TaskBoard".id is 'generated';
comment on column "tms_TaskDependency".id is 'generated';
comment on column "tms_TaskProjectRelationship".id is 'generated';
comment on column "tms_TaskPullRequestAssociation".id is 'generated';
comment on column "tms_TaskReleaseRelationship".id is 'generated';
comment on column "tms_TaskTag".id is 'generated';
comment on column "tms_Task".id is 'generated';
comment on column "tms_User".id is 'generated';
comment on column "vcs_BranchCommitAssociation".id is 'generated';
comment on column "vcs_Branch".id is 'generated';
comment on column "vcs_Commit".id is 'generated';
comment on column "vcs_Membership".id is 'generated';
comment on column "vcs_Organization".id is 'generated';
comment on column "vcs_PullRequestComment".id is 'generated';
comment on column "vcs_PullRequestReview".id is 'generated';
comment on column "vcs_PullRequest".id is 'generated';
comment on column "vcs_Repository".id is 'generated';
comment on column "vcs_Tag".id is 'generated';
comment on column "vcs_User".id is 'generated';

comment on column "cicd_BuildStep"."typeDetail" is 'generated';
comment on column "cicd_BuildStep"."typeCategory" is 'generated';
comment on column "cicd_BuildStep"."statusDetail" is 'generated';
comment on column "cicd_BuildStep"."statusCategory" is 'generated';
comment on column "cicd_Build"."statusDetail" is 'generated';
comment on column "cicd_Build"."statusCategory" is 'generated';
comment on column "cicd_Deployment"."envDetail" is 'generated';
comment on column "cicd_Deployment"."envCategory" is 'generated';
comment on column "cicd_Deployment"."statusDetail" is 'generated';
comment on column "cicd_Deployment"."statusCategory" is 'generated';
comment on column "cicd_EnvBranchAssociation"."environmentDetail" is 'generated';
comment on column "cicd_EnvBranchAssociation"."environmentCategory" is 'generated';
comment on column "ims_IncidentEvent"."typeDetail" is 'generated';
comment on column "ims_IncidentEvent"."typeCategory" is 'generated';
comment on column "ims_Incident"."severityDetail" is 'generated';
comment on column "ims_Incident"."severityCategory" is 'generated';
comment on column "ims_Incident"."priorityDetail" is 'generated';
comment on column "ims_Incident"."priorityCategory" is 'generated';
comment on column "ims_Incident"."statusDetail" is 'generated';
comment on column "ims_Incident"."statusCategory" is 'generated';
comment on column "tms_Epic"."statusDetail" is 'generated';
comment on column "tms_Epic"."statusCategory" is 'generated';
comment on column "tms_Sprint"."stateDetail" is 'generated';
comment on column "tms_Sprint"."stateCategory" is 'generated';
comment on column "tms_Task"."typeDetail" is 'generated';
comment on column "tms_Task"."typeCategory" is 'generated';
comment on column "tms_Task"."statusDetail" is 'generated';
comment on column "tms_Task"."statusCategory" is 'generated';
comment on column "vcs_Organization"."typeDetail" is 'generated';
comment on column "vcs_Organization"."typeCategory" is 'generated';
comment on column "vcs_PullRequestReview"."stateDetail" is 'generated';
comment on column "vcs_PullRequestReview"."stateCategory" is 'generated';
comment on column "vcs_PullRequest"."stateDetail" is 'generated';
comment on column "vcs_PullRequest"."stateCategory" is 'generated';
comment on column "vcs_PullRequest"."linesAdded" is 'generated';
comment on column "vcs_PullRequest"."linesDeleted" is 'generated';
comment on column "vcs_PullRequest"."filesChanged" is 'generated';
comment on column "vcs_User"."typeDetail" is 'generated';
comment on column "vcs_User"."typeCategory" is 'generated';
create table "vcs_PullRequestCommitAssociation" (
  id text generated always as (pkey("pullRequest", commit)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  "pullRequest" text,
  commit text
);

alter table "vcs_PullRequestCommitAssociation" add foreign key ("pullRequest") references "vcs_PullRequest"(id);
alter table "vcs_PullRequestCommitAssociation" add foreign key (commit) references "vcs_Commit"(id);


create index "vcs_PullRequestCommitAssociation_origin_idx" on "vcs_PullRequestCommitAssociation"(origin);
create index "vcs_PullRequestCommitAssociation_pullRequest_idx" on "vcs_PullRequestCommitAssociation"("pullRequest");
create index "vcs_PullRequestCommitAssociation_commit_idx" on "vcs_PullRequestCommitAssociation"(commit);

comment on column "vcs_PullRequestCommitAssociation".id is 'generated';
alter table "vcs_PullRequestCommitAssociation" rename to "vcs_PullRequestCommit";

alter table "vcs_PullRequestCommit" rename constraint "vcs_PullRequestCommitAssociation_pkey" to "vcs_PullRequestCommit_pkey";

drop index "vcs_Commit_message_idx";
create index "vcs_Commit_message_idx" on "vcs_Commit" USING hash(message);
create table "vcs_Label" (
  id text generated always as (pkey(name)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  name text
);

create table "vcs_PullRequestLabel" (
  id text generated always as (pkey(label, "pullRequest")) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  label text,
  "pullRequest" text
);

alter table "vcs_PullRequestLabel" add foreign key (label) references "vcs_Label"(id);
alter table "vcs_PullRequestLabel" add foreign key ("pullRequest") references "vcs_PullRequest"(id);

create index "vcs_PullRequestLabel_origin_idx" on "vcs_PullRequestLabel"(origin);
create index "vcs_PullRequestLabel_label_idx" on "vcs_PullRequestLabel"(label);
create index "vcs_PullRequestLabel_pullRequest_idx" on "vcs_PullRequestLabel"("pullRequest");

comment on column "vcs_Label".id is 'generated';
comment on column "vcs_PullRequestLabel".id is 'generated';
drop index "vcs_Commit_message_idx";
create index "vcs_Commit_message_idx" on "vcs_Commit" using gin (to_tsvector('english', message));
-- qa models --
create table "qa_CodeQuality" (
    id text generated always as (pkey(uid)) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    uid text not null,
    bugs jsonb,
    "branchCoverage" jsonb,
    "codeSmells" jsonb,
    complexity jsonb,
    coverage jsonb,
    duplications jsonb,
    "duplicatedBlocks" jsonb,
    "lineCoverage" jsonb,
    "securityHotspots" jsonb,
    vulnerabilities jsonb,
    "createdAt" timestamptz,
    "pullRequest" text,
    repository text
  );
create table "qa_TestCase" (
    id text generated always as (pkey(source, uid)) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    uid text not null,
    name text,
    description text,
    source text,
    before jsonb,
    after jsonb,
    tags jsonb,
    type jsonb,
    task text
  );
create table"qa_TestCaseResult" (
    id text generated always as (pkey("testExecution", uid)) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    uid text not null,
    description text,
    "startedAt" timestamptz,
    "endedAt" timestamptz,
    status jsonb,
    "testCase" text,
    "testExecution" text
  );
create table "qa_TestCaseStep" (
    id text generated always as (pkey("testCase", uid)) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    uid text not null,
    name text,
    description text,
    data text,
    result text,
    "testCase" text
  );
create table "qa_TestCaseStepResult" (
  id text generated always as (pkey("testResult", uid)) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    uid text not null,
    status jsonb,
    "testStep" text,
    "testResult" text
  );
create table "qa_TestExecution" (
    id text generated always as (pkey(source, uid)) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    uid text not null,
    name text,
    description text,
    source text,
    "startedAt" timestamptz,
    "endedAt" timestamptz,
    status jsonb,
    environments jsonb,
    "testCaseResultsStats" jsonb,
    "deviceInfo" jsonb,
    tags jsonb,
    suite text,
    task text,
    build text
  );
create table "qa_TestExecutionCommitAssociation" (
    id text generated always as (pkey(commit, "testExecution")) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    "testExecution" text,
    commit text
  );
create table "qa_TestSuite" (
    id text generated always as (pkey(source, uid)) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    uid text not null,
    name text,
    description text,
    source text,
    tags jsonb,
    type jsonb,
    task text
  );
create table "qa_TestSuiteTestCaseAssociation" (
    id text generated always as (pkey("testCase", "testSuite")) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    "testSuite" text,
    "testCase" text
  );
create table "tms_TaskTestCaseResultAssociation" (
    id text generated always as (pkey("defect", "testCaseResult")) stored primary key,
    origin text,
    "refreshedAt" timestamptz not null default now(),
    defect text,
    "testCaseResult" text
  );

-- foreign keys --
alter table "qa_CodeQuality" add foreign key ("pullRequest") references "vcs_PullRequest"(id);
alter table "qa_CodeQuality" add foreign key (repository) references "vcs_Repository"(id);
alter table "qa_TestCase" add foreign key (task) references "tms_Task"(id);
alter table "qa_TestCaseResult" add foreign key ("testCase") references "qa_TestCase"(id);
alter table "qa_TestCaseResult" add foreign key ("testExecution") references "qa_TestExecution"(id);
alter table "qa_TestCaseStep" add foreign key ("testCase") references "qa_TestCase"(id);
alter table "qa_TestCaseStepResult" add foreign key ("testStep") references "qa_TestCaseStep"(id);
alter table "qa_TestCaseStepResult" add foreign key ("testResult") references "qa_TestCaseResult"(id);
alter table "qa_TestExecution" add foreign key (suite) references "qa_TestSuite"(id);
alter table "qa_TestExecution" add foreign key (task) references "tms_Task"(id);
alter table "qa_TestExecution" add foreign key (build) references "cicd_Build"(id);
alter table "qa_TestExecutionCommitAssociation" add foreign key ("testExecution") references "qa_TestExecution"(id);
alter table "qa_TestExecutionCommitAssociation" add foreign key (commit) references "vcs_Commit"(id);
alter table "qa_TestSuite" add foreign key (task) references "tms_Task"(id);
alter table "qa_TestSuiteTestCaseAssociation" add foreign key ("testSuite") references "qa_TestSuite"(id);
alter table "qa_TestSuiteTestCaseAssociation" add foreign key ("testCase") references "qa_TestCase"(id);
alter table "tms_TaskTestCaseResultAssociation" add foreign key (defect) references "tms_Task"(id);
alter table "tms_TaskTestCaseResultAssociation" add foreign key ("testCaseResult") references "qa_TestCaseResult"(id);

comment on column "qa_CodeQuality".id is 'generated';
comment on column "qa_TestCase".id is 'generated';
comment on column "qa_TestCaseResult".id is 'generated';
comment on column "qa_TestCaseStep".id is 'generated';
comment on column "qa_TestCaseStepResult".id is 'generated';
comment on column "qa_TestExecution".id is 'generated';
comment on column "qa_TestExecutionCommitAssociation".id is 'generated';
comment on column "qa_TestSuite".id is 'generated';
comment on column "qa_TestSuiteTestCaseAssociation".id is 'generated';
comment on column "tms_TaskTestCaseResultAssociation".id is 'generated';

-- indices --
create index "qa_CodeQuality_origin_idx" on "qa_CodeQuality"(origin);
create index "qa_CodeQuality_uid_idx" on "qa_CodeQuality"(uid);
create index "qa_CodeQuality_createdAt_idx" on "qa_CodeQuality"("createdAt");
create index "qa_CodeQuality_pull_request_idx" on "qa_CodeQuality"("pullRequest");
create index "qa_CodeQuality_repository_idx" on "qa_CodeQuality"(repository);
create index "qa_TestCase_origin_idx" on "qa_TestCase"(origin);
create index "qa_TestCase_uid_idx" on "qa_TestCase"(uid);
create index "qa_TestCase_source_idx" on "qa_TestCase"(source);
create index "qa_TestCase_before_idx" on "qa_TestCase" using gin(before);
create index "qa_TestCase_after_idx" on "qa_TestCase" using gin(after);
create index "qa_TestCase_tags_idx" on "qa_TestCase" using gin(tags);
create index "qa_TestCase_type_idx" on "qa_TestCase" using gin(type);
create index "qa_TestCase_task_idx" on "qa_TestCase"(task);
create index "qa_TestCaseResult_origin_idx" on "qa_TestCaseResult"(origin);
create index "qa_TestCaseResult_uid_idx" on "qa_TestCaseResult"(uid);
create index "qa_TestCaseResult_startedAt_idx" on "qa_TestCaseResult"("startedAt");
create index "qa_TestCaseResult_endedAt_idx" on "qa_TestCaseResult"("endedAt");
create index "qa_TestCaseResult_status_idx" on "qa_TestCaseResult" using gin(status);
create index "qa_TestCaseResult_testCase_idx" on "qa_TestCaseResult"("testCase");
create index "qa_TestCaseResult_testExecution_idx" on "qa_TestCaseResult"("testExecution");
create index "qa_TestCaseStep_origin_idx" on "qa_TestCaseStep"(origin);
create index "qa_TestCaseStep_uid_idx" on "qa_TestCaseStep"(uid);
create index "qa_TestCaseStep_testCase_idx" on "qa_TestCaseStep"("testCase");
create index "qa_TestCaseStepResult_origin_idx" on "qa_TestCaseStepResult"(origin);
create index "qa_TestCaseStepResult_uid_idx" on "qa_TestCaseStepResult"(uid);
create index "qa_TestCaseStepResult_status_idx" on "qa_TestCaseStepResult" using gin(status);
create index "qa_TestCaseStepResult_testStep_idx" on "qa_TestCaseStepResult"("testStep");
create index "qa_TestCaseStepResult_testResult_idx" on "qa_TestCaseStepResult"("testResult");
create index "qa_TestExecution_origin_idx" on "qa_TestExecution"(origin);
create index "qa_TestExecution_uid_idx" on "qa_TestExecution"(uid);
create index "qa_TestExecution_source_idx" on "qa_TestExecution"(source);
create index "qa_TestExecution_startedAt_idx" on "qa_TestExecution"("startedAt");
create index "qa_TestExecution_endedAt_idx" on "qa_TestExecution"("endedAt");
create index "qa_TestExecution_status_idx" on "qa_TestExecution" using gin(status);
create index "qa_TestExecution_environments_idx" on "qa_TestExecution" using gin(environments);
create index "qa_TestExecution_tags_idx" on "qa_TestExecution" using gin(tags);
create index "qa_TestExecution_suite_idx" on "qa_TestExecution"(suite);
create index "qa_TestExecution_task_idx" on "qa_TestExecution"(task);
create index "qa_TestExecution_build_idx" on "qa_TestExecution"(build);
create index "qa_TestExecutionCommitAssociation_origin_idx" on "qa_TestExecutionCommitAssociation"(origin);
create index "qa_TestExecutionCommitAssociation_testExecution_idx" on "qa_TestExecutionCommitAssociation"("testExecution");
create index "qa_TestExecutionCommitAssociation_commit_idx" on "qa_TestExecutionCommitAssociation"(commit);
create index "qa_TestSuite_origin_idx" on "qa_TestSuite"(origin);
create index "qa_TestSuite_uid_idx" on "qa_TestSuite"(uid);
create index "qa_TestSuite_source_idx" on "qa_TestSuite"(source);
create index "qa_TestSuite_tags_idx" on "qa_TestSuite" using gin(tags);
create index "qa_TestSuite_type_idx" on "qa_TestSuite" using gin(type);
create index "qa_TestSuite_task_idx" on "qa_TestSuite"(task);
create index "qa_TestSuiteTestCaseAssociation_origin_idx" on "qa_TestSuiteTestCaseAssociation"(origin);
create index "qa_TestSuiteTestCaseAssociation_testSuite_idx" on "qa_TestSuiteTestCaseAssociation"("testSuite");
create index "qa_TestSuiteTestCaseAssociation_testCase_idx" on "qa_TestSuiteTestCaseAssociation"("testCase");
create index "tms_TaskTestCaseResultAssociation_defect_idx" on "tms_TaskTestCaseResultAssociation"(defect);
create index "tms_TaskTestCaseResultAssociation_testCaseResult_idx" on "tms_TaskTestCaseResultAssociation"("testCaseResult");

-- expansion --
alter table "qa_CodeQuality" add column "bugsValue" text generated always as (bugs ->> 'value') stored;
alter table "qa_CodeQuality" add column "branchCoverageValue" text generated always as ("branchCoverage" ->> 'value') stored;
alter table "qa_CodeQuality" add column "codeSmellsValue" text generated always as ("codeSmells" ->> 'value') stored;
alter table "qa_CodeQuality" add column "complexityValue" text generated always as (complexity ->> 'value') stored;
alter table "qa_CodeQuality" add column "coverageValue" text generated always as (coverage ->> 'value') stored;
alter table "qa_CodeQuality" add column "duplicationsValue" text generated always as (duplications ->> 'value') stored;
alter table "qa_CodeQuality" add column "duplicatedBlocksValue" text generated always as ("duplicatedBlocks" ->> 'value') stored;
alter table "qa_CodeQuality" add column "lineCoverageValue" text generated always as ("lineCoverage" ->> 'value') stored;
alter table "qa_CodeQuality" add column "securityHotspotsValue" text generated always as ("securityHotspots" ->> 'value') stored;
alter table "qa_CodeQuality" add column "vulnerabilitiesValue" text generated always as (vulnerabilities ->> 'value') stored;
alter table "qa_TestCase" add column "beforeDescription" text generated always as (before ->> 'description') stored;
alter table "qa_TestCase" add column "beforeCondition" text generated always as (before ->> 'condition') stored;
alter table "qa_TestCase" add column "afterDescription" text generated always as (after ->> 'description') stored;
alter table "qa_TestCase" add column "afterCondition" text generated always as (after ->> 'condition') stored;
alter table "qa_TestCase" add column "typeCategory" text generated always as (type ->> 'category') stored;
alter table "qa_TestCase" add column "typeDetail" text generated always as (type ->> 'detail') stored;
alter table "qa_TestCaseResult" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "qa_TestCaseResult" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "qa_TestCaseStepResult" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "qa_TestCaseStepResult" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "qa_TestExecution" add column "statusCategory" text generated always as (status ->> 'category') stored;
alter table "qa_TestExecution" add column "statusDetail" text generated always as (status ->> 'detail') stored;
alter table "qa_TestExecution" add column "testCaseResultsStatsFailure" integer generated always as (("testCaseResultsStats" -> 'failure')::integer) stored;
alter table "qa_TestExecution" add column "testCaseResultsStatsSuccess" integer generated always as (("testCaseResultsStats" -> 'success')::integer) stored;
alter table "qa_TestExecution" add column "testCaseResultsStatsSkipped" integer generated always as (("testCaseResultsStats" -> 'skipped')::integer) stored;
alter table "qa_TestExecution" add column "testCaseResultsStatsUnknown" integer generated always as (("testCaseResultsStats" -> 'unknown')::integer) stored;
alter table "qa_TestExecution" add column "testCaseResultsStatsCustom" integer generated always as (("testCaseResultsStats" -> 'custom')::integer) stored;
alter table "qa_TestExecution" add column "testCaseResultsStatsTotal" integer generated always as (("testCaseResultsStats" -> 'total')::integer) stored;
alter table "qa_TestExecution" add column "deviceInfoName" text generated always as ("deviceInfo" -> 'name') stored;
alter table "qa_TestExecution" add column "deviceInfoOs" text generated always as ("deviceInfo" -> 'os') stored;
alter table "qa_TestExecution" add column "deviceInfoBrowser" text generated always as ("deviceInfo" -> 'browser') stored;
alter table "qa_TestExecution" add column "deviceInfoType" text generated always as ("deviceInfo" -> 'type') stored;
alter table "qa_TestSuite" add column "typeCategory" text generated always as (type ->> 'category') stored;
alter table "qa_TestSuite" add column "typeDetail" text generated always as (type ->> 'detail') stored;

comment on column "qa_CodeQuality"."bugsValue" is 'generated';
comment on column "qa_CodeQuality"."branchCoverageValue" is 'generated';
comment on column "qa_CodeQuality"."codeSmellsValue" is 'generated';
comment on column "qa_CodeQuality"."complexityValue" is 'generated';
comment on column "qa_CodeQuality"."coverageValue" is 'generated';
comment on column "qa_CodeQuality"."duplicationsValue" is 'generated';
comment on column "qa_CodeQuality"."duplicatedBlocksValue" is 'generated';
comment on column "qa_CodeQuality"."lineCoverageValue" is 'generated';
comment on column "qa_CodeQuality"."securityHotspotsValue" is 'generated';
comment on column "qa_CodeQuality"."vulnerabilitiesValue" is 'generated';
comment on column "qa_TestCase"."typeCategory" is 'generated';
comment on column "qa_TestCase"."typeDetail" is 'generated';
comment on column "qa_TestCaseResult"."statusCategory" is 'generated';
comment on column "qa_TestCaseResult"."statusDetail" is 'generated';
comment on column "qa_TestCaseStepResult"."statusCategory" is 'generated';
comment on column "qa_TestCaseStepResult"."statusDetail" is 'generated';
comment on column "qa_TestExecution"."statusCategory" is 'generated';
comment on column "qa_TestExecution"."statusDetail" is 'generated';
comment on column "qa_TestExecution"."testCaseResultsStatsFailure" is 'generated';
comment on column "qa_TestExecution"."testCaseResultsStatsSuccess" is 'generated';
comment on column "qa_TestExecution"."testCaseResultsStatsSkipped" is 'generated';
comment on column "qa_TestExecution"."testCaseResultsStatsUnknown" is 'generated';
comment on column "qa_TestExecution"."testCaseResultsStatsCustom" is 'generated';
comment on column "qa_TestExecution"."testCaseResultsStatsTotal" is 'generated';
comment on column "qa_TestExecution"."deviceInfoName" is 'generated';
comment on column "qa_TestExecution"."deviceInfoOs" is 'generated';
comment on column "qa_TestExecution"."deviceInfoBrowser" is 'generated';
comment on column "qa_TestExecution"."deviceInfoType" is 'generated';
comment on column "qa_TestSuite"."typeCategory" is 'generated';
comment on column "qa_TestSuite"."typeDetail" is 'generated';
create table "vcs_Team" (
  id text generated always as (pkey(source, uid)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  uid text,
  name text,
  description text,
  source text
);

create table "vcs_TeamMembership" (
  id text generated always as (pkey(team, "user")) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  "user" text not null,
  team text not null
);


alter table "vcs_TeamMembership" add foreign key ("user") references "vcs_User"(id);
alter table "vcs_TeamMembership" add foreign key (team) references "vcs_Team"(id);