# CodeMySpecWeb.InboxLive

Operator's unified inbox surface in the CodeMySpec dashboard. Lists conversations across all of the account's projects, shows a selected thread, lets any CMS user in the account read and reply in real time, and displays per-user online presence. Depends on CodeMySpec.Conversations.

Renders its thread through `CodeMySpecWeb.ChatComponents`, shared with the story interview and the agent conversation view. It is the one surface where the reader is a person rather than a watcher, so it passes `own_role={:operator}` and puts attachments in the bubble's `:extra` slot.

## Type

liveview

## Dependencies

- CodeMySpec.Conversations
- CodeMySpecWeb.ChatComponents
