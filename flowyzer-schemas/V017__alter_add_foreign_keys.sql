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
alter table "tms_Project" add foreign key (organization) references "vcs_Organization"(id);
alter table "tms_ProjectReleaseRelationship" add foreign key (project) references "tms_Project"(id);
alter table "tms_ProjectReleaseRelationship" add foreign key (release) references "tms_Release"(id);
alter table "tms_Sprint" add foreign key (organization) references "vcs_Organization"(id);
alter table "tms_Task" add foreign key (creator) references "tms_User"(id);
alter table "tms_Task" add foreign key (epic) references "tms_Epic"(id);
alter table "tms_Task" add foreign key (parent) references "tms_Task"(id);
alter table "tms_Task" add foreign key (sprint) references "tms_Sprint"(id);
alter table "tms_Task" add foreign key (organization) references "vcs_Organization"(id);
alter table "tms_TaskBoard" add foreign key (organization) references "vcs_Organization"(id);
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
alter table "tms_User" add foreign key (organization) references "vcs_Organization"(id);
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


alter table "vcs_PullRequestCommit" add foreign key ("pullRequest") references "vcs_PullRequest"(id);
alter table "vcs_PullRequestCommit" add foreign key (commit) references "vcs_Commit"(id);

alter table "vcs_PullRequestLabel" add foreign key (label) references "vcs_Label"(id);
alter table "vcs_PullRequestLabel" add foreign key ("pullRequest") references "vcs_PullRequest"(id);

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

alter table "vcs_TeamMembership" add foreign key ("user") references "vcs_User"(id);
alter table "vcs_TeamMembership" add foreign key (team) references "vcs_Team"(id);