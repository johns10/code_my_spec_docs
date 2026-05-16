# CodeMySpec.ContentSync.Sync

Agnostic content synchronization pipeline that processes filesystem content into attribute maps.

Accepts a directory path, discovers content files (non-recursive), processes them through
appropriate parsers and processors, and returns a list of attribute maps. These maps can be
consumed by either Content or ContentAdmin changesets - the caller handles database operations.

Sync is the foundational layer that reads files from filesystem, parses metadata (YAML sidecar
files), processes content (Markdown, HTML), and returns generic attribute maps. It does NOT
create database records, handle multi-tenant scoping, manage transactions, or broadcast events.

## Dependencies

- CodeMySpec.ContentSync.MetaDataParser
- CodeMySpec.ContentSync.MarkdownProcessor
- CodeMySpec.ContentSync.HtmlProcessor
- CodeMySpec.ContentSync.ProcessorResult
