# CodeMySpec.Sessions

## Type

context

Manages agent task sessions backed by the filesystem. Each session is a directory under `.code_my_spec/internal/sessions/{id}/` containing `session.json` and working files. The stop hook evaluates the session stack to block the agent until tasks complete. Sessions are visible (`ls`) and cancellable (`rm -rf`) by users.

## Delegates

- create_session/2: Sessions.SessionsRepository.create_session/2
- get_session/2: Sessions.SessionsRepository.get_session/2
- list_sessions/1: Sessions.SessionsRepository.list_sessions/1
- update_session/2: Sessions.SessionsRepository.update_session/2
- delete_session/2: Sessions.SessionsRepository.delete_session/2
- clear_sessions/1: Sessions.SessionsRepository.clear_sessions/1

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Sessions.SessionsRepository
- CodeMySpec.Sessions.SessionStack

## Components

### Sessions.SessionStack

Evaluates the session stack on stop hook. Lists sessions, sorts by priority (highest first), calls each agent task module's evaluate function. Blocks the agent on first invalid result, removes passing sessions.

### Sessions.SessionsRepository

Filesystem-backed CRUD for sessions. Reads/writes Session structs as JSON via Environments. Handles directory creation, listing, deletion, and bulk clear under `.code_my_spec/internal/sessions/`.

### Sessions.Session

Embedded schema representing an agent task session. Provides changeset validation and JSON serialization (to_json/from_json) for filesystem storage. Fields: id, type, priority, status, component_module_name, external_conversation_id, state.

### Sessions.SessionType

Maps agent task module atoms to string names and back. Used by Session for type validation and by SessionStack to resolve which module to call for evaluation.
