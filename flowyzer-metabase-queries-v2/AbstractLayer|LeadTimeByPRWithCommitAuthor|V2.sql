with task AS (
    SELECT
        REPLACE(id, 'Azure-Workitems', 'Azure-Repos') AS transformed_id,
        t.*,
        expanded_data::json->'status'->>'category' AS "statusValue",
        (expanded_data::json->>'changedAt')::timestamptz AS "statusChangeChangedAt" --,
    FROM "tms_Task" t
    LEFT JOIN LATERAL json_array_elements(t."statusChangelog"::json) AS expanded_data ON true
    WHERE t.origin = 'azure_workitems'
),
status_new_tasks AS (
    SELECT
        task.*,
        task."statusChangeChangedAt" AS "statusChangedToNewAt",
        ROW_NUMBER() OVER (PARTITION BY task.id ORDER BY task."statusChangeChangedAt" ASC) AS "statusChangedToNewAtRank"
    FROM task
    WHERE task."statusValue" = 'New' or task."statusValue" = 'To Do'
)
,
status_Dev_tasks AS (
    SELECT
        task.*,
        task."statusChangeChangedAt" AS "statusChangedToDevAt",
        ROW_NUMBER() OVER (PARTITION BY task.id ORDER BY task."statusChangeChangedAt" ASC) AS "statusChangedToDevAtRank"
    FROM task
    WHERE task."statusValue" = 'Development In Progress' 
    or task."statusValue" = 'Active'
    or task."statusValue" = 'In Progress'-- Make sure we add the or statements to cover the different statusValues untill we create a variable
),
tasks_with_status_changes AS (
    SELECT
        t.*,
        tn."statusChangedToNewAt",
        td."statusChangedToDevAt"
    FROM task t
    LEFT JOIN status_new_tasks tn ON t.id = tn.id AND tn."statusChangedToNewAtRank" = 1
    LEFT JOIN status_Dev_tasks td ON t.id = td.id AND td."statusChangedToDevAtRank" = 1
),
task_with_sprint AS ( -- all the tasks with proper sprint data. We will join this with pull requests tasks (Primary Join Table 1)
    SELECT
        task.transformed_id,
        task.organization as "taskOrganization",
        task.id AS "taskId",
        task.sprint AS "sprintId",
        task."statusChangeChangedAt",
        task."createdAt" AS "taskCreatedAt",
        task."createdAt" AS "shelfTimeStart",
        case when ts."startedAt" is not null then
        	ts."startedAt"
        else 
        	task."createdAt"
        end  AS "shelfTimeEnd",
        task."statusChangedToNewAt" AS "taskPickupTimeStart",
        task."statusChangedToDevAt" AS "codingTimeStart",
        task.origin AS "taskOrigin"
    FROM tasks_with_status_changes task
    JOIN "tms_Sprint" ts ON task.sprint = ts.id
),
prs_with_tasks AS (
    SELECT
        *,
    ttpra.task as "prAssociatedTaskId",
    pr.id as "prId",
    pr."createdAt" as "prCreatedAt",
    pr."mergedAt" AS "prMergedAt",
    pr.origin AS "prOrigin",
    pr.number AS "prUID",
    pr."stateDetail" as "prStateDetail",
    pr."stateCategory" as "prStateCategory",
    pr.author AS "prAuthor",
    org.id AS "orgId",
    org.uid AS "orgUID",
    repo.id AS "repoId",
	repo.origin AS "repoOrigin",
	repo.name AS "repoName",
	repo."fullName" AS "repoFullName"
    FROM "tms_TaskPullRequestAssociation" ttpra
    JOIN public."vcs_PullRequest" pr ON ttpra."pullRequest" = pr."id"
    join public."vcs_Repository" repo on pr."repository" = repo.id
    join public."vcs_Organization" org on repo."organization" = org.id
    WHERE pr."stateDetail" <> 'active'
),
prWithTaskAndCommentdetails AS (
    SELECT
        vpr.*,
        vprc."createdAt" AS "pullRequestCommentCreatedAt",
        RANK() OVER (PARTITION BY vpr."task" ORDER BY vpr."prCreatedAt" ASC, vprc."createdAt" ASC) AS "pullRequestRank"
    FROM "prs_with_tasks" vpr
    LEFT JOIN "vcs_PullRequestComment" vprc ON vprc."pullRequest" = vpr."prId"
),
prWithTaskCommentDetailsAndPRCommitAuthor as (
	select pr.*, prc.*, prc."prCommitAuthor" AS "commitAuthor"
	from prWithTaskAndCommentdetails pr
	left join (
	SELECT
    LOWER(vc.author) as "prCommitAuthor", prc."pullRequest"
	FROM "vcs_Commit" AS vc
	JOIN "vcs_PullRequestCommit" AS prc
	    ON vc.id=REGEXP_REPLACE(prc."pullRequest", '\|\d+$', prc."commit")
	WHERE vc.message NOT LIKE 'Merged PR%'
	GROUP BY LOWER(vc.author), prc."pullRequest"
	) as prc on prc."pullRequest"=pr."prId"
),
prWithTaskCommentDetailsPrCommitUser as (
	select pr.*, userData.*
	from prWithTaskCommentDetailsAndPRCommitAuthor as pr
	left join (
		select user1.id as "userId", user2.*, user2.name as "commitAuthorName"
		from public."vcs_User" user1
		join (select * from "vcs_User" where name is not NULL) as user2 on user2.uid=user1.uid
		) as userData on LOWER(userData."userId")=pr."prCommitAuthor"
),
selected_task_prs AS ( -- all the PR with associated tasks, repos, organization, and pr comments. We will join this with Tasks above (Primary Join Table 2)
    SELECT *
    FROM prWithTaskCommentDetailsPrCommitUser
    WHERE "pullRequestRank" = 1
),
pr_joind_tasks as (
	select pr.*, task.*
	from selected_task_prs pr
	join task_with_sprint task on pr."prAssociatedTaskId"=task.transformed_id
),
lead_time_data as (
	select
	t."prId",
    t."prOrigin",
    t."prUID",
    t."prAuthor",
    t."prCreatedAt",
    t."prMergedAt",
    t."commitAuthor",
    t."commitAuthorName",
    t."stateDetail",
    t."stateCategory",
    t."taskId",
    t."taskOrigin",
    t."taskCreatedAt",
    t."shelfTimeStart",
    t."shelfTimeEnd",
    t."taskPickupTimeStart",
    t."codingTimeStart",
    t."orgId",
    t."orgUID",
    t."repoId",
    t."repoOrigin",
    t."repoName",
   	t."repoFullName",
    GREATEST(EXTRACT(EPOCH FROM (t."shelfTimeEnd" - t."shelfTimeStart")) / 3600, 0) AS "ShelfTime",
    GREATEST(EXTRACT(EPOCH FROM (t."codingTimeStart" - t."taskPickupTimeStart")) / 3600, 0) AS "TaskPickupTime",
    GREATEST(EXTRACT(EPOCH FROM (t."prCreatedAt" - t."codingTimeStart")) / 3600, 0) AS "CodingTime",
    EXTRACT(EPOCH FROM (t."pullRequestCommentCreatedAt" - t."prCreatedAt")) / 3600 AS "ReviewPickupTime",
    GREATEST(EXTRACT(EPOCH FROM (t."prMergedAt" - t."pullRequestCommentCreatedAt")) / 3600, 0) AS "ReviewTime"
	from pr_joind_tasks as t
	-- where t."orgUID"='cultureintelligence' -- DO NOT Uncomment on Production. For Testing only
    --where t."orgUID"='compello' -- DO NOT Uncomment on Production. For Testing only
	--where t."orgUID"='BUS-AS-Norway' -- DO NOT Uncomment on Production. For Testing only
)

SELECT
    t."prId",
    t."prOrigin",
    t."prUID",
    t."prAuthor",
    t."prCreatedAt",
    t."prMergedAt",
    t."commitAuthor",
    t."commitAuthorName",
    t."orgId",
    t."orgUID",
    t."repoId",
    t."repoOrigin",
    t."repoName",
    t."repoFullName",
    AVG(t."ShelfTime") AS "ShelfTime",
    AVG(t."TaskPickupTime") AS "TaskPickupTime",
    AVG(t."CodingTime") AS "CodingTime",
    AVG(t."ReviewPickupTime") AS "ReviewPickupTime",
    AVG(t."ReviewTime") AS "ReviewTime"
FROM lead_time_data t
GROUP BY
    t."prId",
    t."prOrigin",
    t."prUID",
    t."prAuthor",
    t."prCreatedAt",
    t."prMergedAt",
    t."commitAuthor",
    t."commitAuthorName",
    t."orgId",
    t."orgUID",
    t."repoId",
    t."repoOrigin",
    t."repoName",
    t."repoFullName";