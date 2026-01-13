# CodeMySpecCli.Hooks.ValidateEdits

A stop hook that validates written and edited files when a Claude Code session ends. The hook uses `Transcripts.extract_edited_files/1` to retrieve all files written or edited during the session, filters for spec files (`.spec.md`), and validates each against its corresponding document schema using `Documents.create_dynamic_document/2`. For now, the hook only validates spec files, returning validation errors for any specs that don't conform to their schema so Claude can revise them before the session fully terminates.
