WITH pr_commit AS (
    SELECT *, REGEXP_REPLACE(prc."pullRequest", '\|\d+$', prc."commit") AS "tranformed_pr_id"
    FROM "vcs_PullRequestCommit" AS prc
),
first_layer AS (
    SELECT
        pr.id AS "prId",
        pr.origin AS "prOrigin",
        pr.number AS "prUID",
        pr.author AS "prAuthor",
        pr."createdAt" AS "prCreatedAt",
        pr."updatedAt" AS "prUpdatedAt",
        pr."mergedAt" AS "prMergedAt",
        pr."stateDetail",
        pr."stateCategory",
        pr_comment.id AS "commentId",
        pr_comment.comment,
        pr_comment."createdAt" AS "commentCreatedAt",
        pr_comment.author,
        pr_commit.tranformed_pr_id AS "prCommitId",
        commit.sha,
        commit.message AS "commitMessage",
        commit."createdAt" AS "commitCreatedAt",
        commit.author AS "commitAuthor",
        (CASE WHEN "user".name IS NULL THEN commit.author ELSE "user".name END) AS "commitAuthorName",
        commit."linesAdded",
        commit."linesDeleted",
        commit."linesChanged",
        GREATEST(pr."updatedAt", pr."mergedAt", pr_comment."createdAt", commit."createdAt") AS "lastActivityTime",
        org.id AS "orgId",
        org.uid AS "orgUID",
        repo.id AS "repoId",
        repo.origin AS "repoOrigin",
        repo.name AS "repoName",
        repo."fullName" AS "repoFullName"
    FROM "vcs_PullRequest" AS pr
    LEFT JOIN "vcs_PullRequestComment" AS pr_comment
        ON pr_comment."pullRequest"=pr.id
    JOIN "vcs_Repository" As repo
        ON repo.id=pr.repository
    JOIN "vcs_Organization" AS org
        ON org.id=repo.organization
    JOIN pr_commit
        ON pr_commit."pullRequest" = pr.id
    LEFT JOIN "vcs_Commit" AS commit
        ON commit.id=pr_commit.tranformed_pr_id
    LEFT JOIN (
        SELECT * FROM "vcs_User" WHERE "vcs_User".name IS NOT NULL
    ) AS "user"
        ON LOWER("user".id)=LOWER(commit.author)
    WHERE (pr."createdAt" < pr_comment."createdAt" AND pr_comment."createdAt" < pr."mergedAt") OR (pr."createdAt" < commit."createdAt" AND commit."createdAt" < pr."mergedAt")
    ORDER BY pr.id
),
second_layer AS (
    SELECT *, "prCreatedAt" as "timeStamp" from first_layer
    UNION ALL
    SELECT *, "prMergedAt" as "timeStamp" from first_layer
    UNION ALL
    SELECT *, "commentCreatedAt" as "timeStamp" from first_layer WHERE "prCreatedAt" < "commentCreatedAt" AND "commentCreatedAt" < "prMergedAt"
    UNION ALL
    SELECT *, "commitCreatedAt" as "timeStamp" from first_layer WHERE "prCreatedAt" < "commitCreatedAt" AND "commitCreatedAt" < "prMergedAt"
),
third_layer AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY "prId", "timeStamp")
    FROM second_layer
)
SELECT
    t1.*, t2."timeStamp" AS "t2_timestamp", 
    (CASE WHEN t1."prId"=t2."prId" THEN
        EXTRACT(EPOCH FROM (t1."timeStamp" - t2."timeStamp"))/3600
    ELSE
        0
    END) AS "time_interval"
FROM third_layer AS t1
JOIN third_layer AS t2
    ON t1."row_number" = (t2."row_number" + 1)