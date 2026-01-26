# AnalyticsAdminServer

MCP server that exposes Google Analytics Admin API tools to AI agents via the Hermes protocol. This server provides comprehensive management capabilities for custom dimensions, custom metrics, and key events in Google Analytics 4 properties.

## Dependencies

- Hermes.Server
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.ListCustomDimensions
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.GetCustomDimension
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.CreateCustomDimension
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.UpdateCustomDimension
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.ArchiveCustomDimension
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.ListCustomMetrics
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.CreateCustomMetric
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.GetCustomMetric
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.UpdateCustomMetric
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.ArchiveCustomMetric
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.ListKeyEvents
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.CreateKeyEvent
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.UpdateKeyEvent
- CodeMySpec.McpServers.AnalyticsAdmin.Tools.DeleteKeyEvent

## Functions

This module uses the Hermes.Server behavior and does not define public functions directly. Instead, it registers tool components that are exposed to AI agents via the MCP protocol.

The server is configured with:
- **Name**: "analytics-admin-server"
- **Version**: "1.0.0"
- **Capabilities**: [:tools]

### Registered Tool Components

**Custom Dimensions Tools**:
- ListCustomDimensions - Lists all custom dimensions for a property
- GetCustomDimension - Retrieves a specific custom dimension
- CreateCustomDimension - Creates a new custom dimension
- UpdateCustomDimension - Updates an existing custom dimension
- ArchiveCustomDimension - Archives a custom dimension

**Custom Metrics Tools**:
- ListCustomMetrics - Lists all custom metrics for a property
- CreateCustomMetric - Creates a new custom metric
- GetCustomMetric - Retrieves a specific custom metric
- UpdateCustomMetric - Updates an existing custom metric
- ArchiveCustomMetric - Archives a custom metric

**Key Events Tools**:
- ListKeyEvents - Lists all key events for a property
- CreateKeyEvent - Creates a new key event
- UpdateKeyEvent - Updates an existing key event
- DeleteKeyEvent - Deletes a key event

**Process**:
1. Server starts with Hermes.Server behavior
2. Registers all tool components via component/1 macro
3. Exposes tools to AI agents via MCP protocol
4. Routes tool invocations to appropriate component handlers

**Test Assertions**:
- server starts successfully with correct name and version
- server advertises tools capability
- all custom dimension tools are registered and accessible
- all custom metric tools are registered and accessible
- all key event tools are registered and accessible
- server handles tool invocations correctly
- server returns proper error responses for invalid requests
