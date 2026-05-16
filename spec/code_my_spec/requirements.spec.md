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

- Components
