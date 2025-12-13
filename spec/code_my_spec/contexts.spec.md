# Contexts

Manages Phoenix Contexts based on standard Phoenix project directory structure stored in the database. Provides query capabilities.

## Components

- ./contexts/context.spec.md
- ./contexts/contexts_repository.spec.md
- ./contexts/sync.spec.md

## Delegates

- list_contexts/1: Contexts.ContextsRepository.list_contexts/1
- search_contexts/2: Contexts.ContextsRepository.search_contexts/2
- get_context/2: Contexts.ContextsRepository.get_context/2
- get_by_module_name/2: Contexts.ContextsRepository.get_by_module_name/2
- sync_context/2: Contexts.Sync.sync_context/2
- sync_all_contexts/1: Contexts.Sync.sync_all_contexts/1

## Dependencies

- components.spec.md