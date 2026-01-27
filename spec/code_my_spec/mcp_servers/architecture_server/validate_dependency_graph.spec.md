# CodeMySpec.McpServers.ArchitectureServer.ValidateDependencyGraph

Validates the component dependency graph for circular dependencies. Returns validation result indicating success or list of detected cycles. Uses topological sort to detect cycles and provides clear error messages about which components are involved in circular dependencies.
