SELECT "source"."repoId" AS "repoId", 
"source"."repoOrigin" AS "repoOrigin", 
"source"."repoName" AS "repoName", 
"source"."repoFullName" AS "repoFullName", 
"source"."repoVisibility" AS "repoVisibility", 
"source"."mainBranch" AS "mainBranch", 
"source"."orgId" AS "orgId", "source"."orgName" AS "orgName"
FROM (SELECT
    repo.id AS "repoId",
    repo.origin as "repoOrigin",
    repo.name as "repoName",
    repo."fullName" as "repoFullName",
    repo.private as "repoVisibility",
    "mainBranch",
    org.id AS "orgId",
    org.name AS "orgName"
FROM "vcs_Repository" As repo
JOIN "vcs_Organization" AS org ON org.id=repo.organization) "source"

