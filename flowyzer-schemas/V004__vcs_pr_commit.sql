create table "vcs_PullRequestCommitAssociation" (
  id text generated always as (pkey("pullRequest", commit)) stored primary key,
  origin text,
  "refreshedAt" timestamptz not null default now(),
  "pullRequest" text,
  commit text
);


create index "vcs_PullRequestCommitAssociation_origin_idx" on "vcs_PullRequestCommitAssociation"(origin);
create index "vcs_PullRequestCommitAssociation_pullRequest_idx" on "vcs_PullRequestCommitAssociation"("pullRequest");
create index "vcs_PullRequestCommitAssociation_commit_idx" on "vcs_PullRequestCommitAssociation"(commit);

comment on column "vcs_PullRequestCommitAssociation".id is 'generated';
