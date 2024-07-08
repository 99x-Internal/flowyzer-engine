## Canonical Schema

## Consolidated SQL File

The `consolidated.sql` file contains all the Flyway migrations applied to the database.

### Overview

The canonical schema creates a database schema for a system involving several models related to Continuous Integration/Continuous Deployment (CI/CD), Incident Management System (IMS), Task Management System (TMS), and Version Control System (VCS).

### CI/CD Models

- **cicd_ArtifactCommitAssociation**: Associates artifacts with commits.
- **cicd_ArtifactDeployment**: Associates artifacts with deployments.
- **cicd_Artifact**: Represents an artifact with details such as repository, UID, name, URL, type, creation date, tags, build, and repository.
- **cicd_BuildCommitAssociation**: Associates builds with commits.
- **cicd_BuildStep**: Represents a step in a build process.
- **cicd_Build**: Represents a build within a pipeline.
- **cicd_DeploymentChangeset**: Associates deployments with commits.
- **cicd_Deployment**: Represents a deployment with details such as start and end time, environment, status, source, application, and build.
- **cicd_EnvBranchAssociation**: Associates environments with branches in repositories.
- **cicd_Organization**: Represents an organization in the CI/CD system.
- **cicd_Pipeline**: Represents a pipeline within an organization.
- **cicd_ReleaseTagAssociation**: Associates releases with tags.
- **cicd_Release**: Represents a release with details such as name, URL, description, draft status, creation, and release date.
- **cicd_Repository**: Represents a repository within an organization.

### Compute Models

- **compute_ApplicationSource**: Associates applications with repositories.
- **compute_Application**: Represents an application with details such as UID, name, and platform.

### Incident Management System (IMS) Models

- **ims_IncidentApplicationImpact**: Associates incidents with applications.
- **ims_IncidentAssignment**: Associates incidents with assignees.
- **ims_IncidentEvent**: Represents events related to incidents.
- **ims_IncidentTag**: Associates incidents with tags.
- **ims_IncidentTasks**: Associates incidents with tasks.
- **ims_Incident**: Represents an incident with details such as title, description, severity, priority, status, and timestamps for various stages.
- **ims_Label**: Represents a label in the IMS.
- **ims_TeamIncidentAssociation**: Associates incidents with teams.
- **ims_Team**: Represents a team within the IMS.
- **ims_User**: Represents a user within the IMS.

### Task Management System (TMS) Models

- **tms_Epic**: Represents an epic with details such as name, description, status, and project.
- **tms_Label**: Represents a label in the TMS.
- **tms_ProjectReleaseRelationship**: Associates projects with releases.
- **tms_Project**: Represents a project with details such as name, description, creation, and update date.
- **tms_Release**: Represents a release with details such as name, description, start and release date.
- **tms_Sprint**: Represents a sprint with details such as name, description, planned and completed points, state, and start and end date.
- **tms_TaskAssignment**: Associates tasks with assignees.
- **tms_TaskBoardProjectRelationship**: Associates task boards with projects.
- **tms_TaskBoardRelationship**: Associates tasks with boards.
- **tms_TaskBoard**: Represents a task board.
- **tms_TaskDependency**: Represents dependencies between tasks.
- **tms_TaskProjectRelationship**: Associates tasks with projects.
- **tms_TaskPullRequestAssociation**: Associates tasks with pull requests.
- **tms_TaskReleaseRelationship**: Associates tasks with releases.
- **tms_TaskTag**: Associates tasks with tags.
- **tms_Task**: Represents a task with details such as name, description, type, priority, status, points, additional fields, timestamps, and associations with other entities.
- **tms_User**: Represents a user within the TMS.

### Version Control System (VCS) Models

- **vcs_BranchCommitAssociation**: Associates commits with branches.
- **vcs_Branch**: Represents a branch within a repository.
- **vcs_Commit**: Represents a commit within a repository.
- **vcs_Membership**: Associates organizations with users.
- **vcs_Organization**: Represents an organization in the VCS.
- **vcs_PullRequestComment**: Represents comments on pull requests.
- **vcs_PullRequestReview**: Represents reviews of pull requests.
- **vcs_PullRequest**: Represents a pull request within a repository.
- **vcs_Repository**: Represents a repository within an organization.
- **vcs_Tag**: Represents a tag within a repository.
- **vcs_User**: Represents a user within the VCS.

### Detailed Entity Reference

| Entity                         | Description                                                                                                           | Related Entities                                                                                                                                                                                                                                                                     |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| vcs_Commit                     | A commit in an VCS                                                                                                    | - Belongs to exactly 1 vcs_Repository<br>- Is the code version used to build 0-n cicd_Artifact (relation captured in cicd_ArtifactCommitAssociation)                                                                                                                                 |
| cicd_ArtifactCommitAssociation | Entity linking a vcs_Commit and a cicd_Artifact                                                                       | - Is built from 0-n vcs_Commit (relation captured in cicd_ArtifactCommitAssociation)<br>- Its build is captured in 1 cicd_Build for status and timing details<br>- Is stored in 1 cicd_Repository<br>- Is part of 0-n cicd_Deployment (relation captured in cicd_ArtifactDeployment) |
| cicd_Artifact                  | An artifact, like a Docker image. Built from your code, and deployed as part of an application                        | - Is built from 0-n vcs_Commit (relation captured in cicd_ArtifactCommitAssociation)<br>- Its build is captured in 1 cicd_Build for status and timing details<br>- Is stored in 1 cicd_Repository<br>- Is part of 0-n cicd_Deployment (relation captured in cicd_ArtifactDeployment) |
| cicd_ArtifactDeployment        | Entity linking a cicd_Artifact and a cicd_Deployment                                                                  | - Made of 0-n cicd_Artifact (relation captured in cicd_ArtifactDeployment)<br>- About exactly 1 compute_Application<br>- Its deployment captured in 1 cicd_Build for status and timing details                                                                                       |
| cicd_Deployment                | A deployment of one or more artifacts for an application in an environment                                            | - Made of 0-n cicd_Artifact (relation captured in cicd_ArtifactDeployment)<br>- About exactly 1 compute_Application<br>- Its deployment captured in 1 cicd_Build for status and timing details                                                                                       |
| vcs_Repository                 | The VCS repository that contains commits                                                                              | - Contains 0-n vcs_Commit<br>- Belongs to exactly 1 vcs_Organization                                                                                                                                                                                                                 |
| vcs_Organization               | The organization that owns the VCS repository                                                                         | - Has 0-n vcs_Repository                                                                                                                                                                                                                                                             |
| cicd_Build                     | A run of a pipeline (that builds an artifact, deploys code, ...). Top-most entity that has a status for CI/CD systems | - Can link to 0-n cicd_Artifact or 0-n cicd_Deployment for status and timing details<br>- Belongs to 1 cicd_Pipeline                                                                                                                                                                 |
| cicd_Pipeline                  | The "template" of a cicd_Build                                                                                        | - Has 0-n "runs" captured as cicd_Build<br>- Belongs to exactly 1 cicd_Organization                                                                                                                                                                                                  |
| cicd_Repository                | The repository that contains artifacts                                                                                | - Contains 0-n cicd_Artifact<br>- Belongs to exactly 1 cicd_Organization                                                                                                                                                                                                             |
| cicd_Organization              | The organization that owns the (CI/CD) repository or pipeline                                                         | - Links to 0-n cicd_Repository or 0-n cicd_Pipeline                                                                                                                                                                                                                                  |

| Stream                | Sync                   | Destination Table                                    |
| --------------------- | ---------------------- | ---------------------------------------------------- |
| branches              | Full refresh \| Append | vcs_Branch, vcs_BranchCommitAssociation              |
| commits               | Incremental \| Append  | vcs_BranchCommitAssociation, vcs_Commit              |
| group_labels          | Full refresh \| Append | tms_Label                                            |
| group_milestones      | Full refresh \| Append | tms_Epic                                             |
| groups                | Full refresh \| Append | cicd_Organization, vcs_Organization                  |
| issues                | Incremental \| Append  | tms_Label, tms_Task, tms_TaskAssignment, tms_TaskTag |
| jobs                  | Full refresh \| Append | cicd_BuildStep                                       |
| merge_request_commits | Full refresh \| Append | vcs_Commit                                           |
| merge_requests        | Incremental \| Append  | vcs_PullRequest                                      |
| pipelines             | Incremental \| Append  | cicd_Build, cicd_BuildCommitAssociation              |
| project_labels        | Full refresh \| Append | tms_Label                                            |
| project_milestones    | Full refresh \| Append | tms_Epic                                             |
| projects              | Full refresh \| Append | cicd_Pipeline, vcs_Repository                        |
| releases              | Full refresh \| Append | cicd_Release, cicd_ReleaseTagAssociation             |
| tags                  | Full refresh \| Append | vcs_Tag                                              |
| users                 | Full refresh \| Append | vcs_User                                             |

_Notes_
