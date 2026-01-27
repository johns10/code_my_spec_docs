# CodeMySpec.McpServers.ArchitectureServer.DeleteSpec

Deletes a component spec file and removes component from database. Removes spec file from filesystem and cascades delete to component entry and all associated dependencies. Safe operation that succeeds even if spec file doesn't exist.
