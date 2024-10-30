SELECT
    repo.id AS "repoId",
    repo.origin as "repoOrigin",
    repo.name as "repoName",
    repo."fullName" as "repoFullName",
    repo.private as "repoVisibility",
    "mainBranch",
    org.id AS "orgId",
    org.name AS "orgName",
    org.uid AS "orgUID"
FROM "vcs_Repository" As repo
JOIN "vcs_Organization" AS org
    ON org.id=repo.organization