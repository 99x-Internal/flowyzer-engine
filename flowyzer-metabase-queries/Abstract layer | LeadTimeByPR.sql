WITH workitem_task AS (
    SELECT
        REPLACE(id, 'Azure-Workitems', 'Azure-Repos') AS transformed_id,
        *,
        expanded_data.value AS statusChange
    FROM "tms_Task"
    LEFT JOIN LATERAL json_array_elements("statusChangelog"::json) AS expanded_data ON true
    WHERE origin='azure_workitems'
),
task AS (
    SELECT
        *,
        statusChange::json->'status'->>'oldValue' AS "statusChangeOldValue",
        statusChange::json->'status'->>'newValue' AS "statusChangeNewValue",
        (statusChange::json->>'changedAt')::timestamptz AS "statusChangeChangedAt"
    FROM workitem_task
),
lead_time_by_pr AS (
    SELECT
        pr.id AS "prId",
        pr.origin AS "prOrigin",
        pr.number AS "prUID",
        pr.author AS "prAuthor",
        pr."createdAt" AS "prCreatedAt",
        pr."mergedAt" AS "prMergedAt",
        pr."stateDetail",
        pr."stateCategory",
        task.id AS "taskId",
        task.origin AS "taskOrigin",
        org.id AS "orgId",
        org.uid AS "orgUID",
        repo.id AS "repoId",
        repo.origin AS "repoOrigin",
        repo.name AS "repoName",
        repo."fullName" AS "repoFullName",
        task."createdAt" AS "TaskPickupTime_Start",
        "statusChangeChangedAt" AS "CodingTime_Start",
        pr."createdAt" AS "ReviewPickupTime_Start",
        CASE WHEN position('pull request status to' in pr_comment.comment) > 0 THEN
            pr."createdAt"
        ELSE
            pr_comment."createdAt"
        END AS "ReviewTime_Start",
        pr."mergedAt" AS "ReviewTime_End",
        rank() OVER (PARTITION BY pr.id ORDER BY "statusChangeChangedAt" ASC, pr_comment."createdAt" ASC) as "rank"
    FROM "vcs_PullRequest" AS pr
    JOIN "tms_TaskPullRequestAssociation" AS task_pr
        ON task_pr."pullRequest"=pr.id
    LEFT JOIN (
        SELECT *
        FROM "vcs_PullRequestComment"
        WHERE comment NOT LIKE '% as a reviewer' AND comment NOT LIKE 'The reference % was updated.' AND comment NOT LIKE '%removed%from the reviewers%'
    ) AS pr_comment
        ON pr_comment."pullRequest"=pr.id
    JOIN task
        ON task_pr.task=task.transformed_id
    JOIN "vcs_Organization" AS org
        ON org.id=task.organization
    JOIN "vcs_Repository" As repo
        ON repo.id=pr.repository
    WHERE "statusChangeNewValue" = {{devInprogressStatus}}
    ORDER BY pr.id
)
SELECT
    *,
    EXTRACT(EPOCH FROM ("CodingTime_Start" - "TaskPickupTime_Start"))/3600 AS "TaskPickupTime",
    EXTRACT(EPOCH FROM ("ReviewPickupTime_Start" - "CodingTime_Start"))/3600 AS "CodingTime",
    EXTRACT(EPOCH FROM ("ReviewTime_Start" - "ReviewPickupTime_Start"))/3600 AS "ReviewPickupTime",
    EXTRACT(EPOCH FROM ("ReviewTime_End" - "ReviewTime_Start"))/3600 AS "ReviewTime"
FROM lead_time_by_pr
WHERE
    rank=1 AND
    "CodingTime_Start" > "TaskPickupTime_Start" AND
    "ReviewPickupTime_Start" > "CodingTime_Start" AND
    "ReviewTime_Start" > "ReviewPickupTime_Start" AND
    "ReviewTime_End" > "ReviewTime_Start"