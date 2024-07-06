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
