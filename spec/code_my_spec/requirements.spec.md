# CodeMySpec.Requirements

Manages component requirement checking, persistence, and workflow queries. Requirements are computed from checker modules and persisted for efficient UI queries.

## Type

context

## Components

- ./requirements/requirement.spec.md
- ./requirements/requirements_repository.spec.md
- ./requirements/requirements_registry.spec.md
- ./requirements/checker_behaviour.spec.md

## Delegates

- create_requirement/4: Requirements.RequirementsRepository.create_requirement/4
- update_requirement/3: Requirements.RequirementsRepository.update_requirement/3
- clear_requirements/3: Requirements.RequirementsRepository.clear_requirements/3
- components_with_unsatisfied_requirements/1: Requirements.RequirementsRepository.components_with_unsatisfied_requirements/1

## Dependencies

- CodeMySpec.AcceptanceCriteria
- CodeMySpec.AgentTasks
- CodeMySpec.BddRules
- CodeMySpec.Components
- CodeMySpec.Configurations
- CodeMySpec.Documents
- CodeMySpec.Environments
- CodeMySpec.Files
- CodeMySpec.Issues
- CodeMySpec.Paths
- CodeMySpec.Personas
- CodeMySpec.Problems
- CodeMySpec.Projects
- CodeMySpec.Qa
- CodeMySpec.Questions
- CodeMySpec.Repo
- CodeMySpec.Sessions
- CodeMySpec.Stories
- CodeMySpec.Users
- CodeMySpec.Utils

