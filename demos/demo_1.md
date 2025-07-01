# Phoenix Demo Application Generation Commands

# Domain Contexts (Entity Owners)

# Projects - Project workspace and configuration management
mix phx.gen.live Projects Project projects name:string description:text status:string workspace_path:string created_at:datetime updated_at:datetime

# Conversations - LLM conversation state and metadata
mix phx.gen.context Conversations Conversation conversations project_id:references:projects title:string status:string metadata:map started_at:datetime completed_at:datetime

# Messages - Individual conversation messages
mix phx.gen.context Messages Message messages conversation_id:references:conversations role:string content:text timestamp:datetime message_type:string

# Stories - User story management with change tracking
mix phx.gen.live Stories Story stories project_id:references:projects title:string description:text acceptance_criteria:text priority:integer status:string is_dirty:boolean created_at:datetime updated_at:datetime

# Documents - Design document storage and versioning
mix phx.gen.live Documents Document documents project_id:references:projects title:string content:text doc_type:string file_path:string status:string is_dirty:boolean version:integer created_at:datetime updated_at:datetime

# Environments - Git branch and workspace management
mix phx.gen.context Environments Environment environments project_id:references:projects name:string branch_name:string workspace_path:string status:string created_at:datetime

# Demos - Phoenix application scaffolding and seed data
mix phx.gen.live Demos Demo demos project_id:references:projects name:string description:text phx_commands:array:string seed_data:text status:string generated_at:datetime

# Specs - BDD specifications with traceability
mix phx.gen.live Specs Spec specs story_id:references:stories title:string given_text:text when_text:text then_text:text status:string is_passing:boolean created_at:datetime

# Tasks - Implementation todos with dependency management
mix phx.gen.live Tasks Task tasks spec_id:references:specs environment_id:references:environments title:string description:text assignee:string status:string branch_name:string priority:integer dependencies:array:string created_at:datetime completed_at:datetime

# Agents - External coding agent management
mix phx.gen.context Agents Agent agents name:string agent_type:string capabilities:array:string status:string configuration:map

# LLMs - Internal LLM model management
mix phx.gen.context LLMs LLM llms name:string model_type:string capabilities:array:string status:string configuration:map

# Tests - Test execution results and coverage
mix phx.gen.context Tests TestResult test_results task_id:references:tasks test_type:string test_name:string status:string output:text coverage_percentage:decimal executed_at:datetime

# Metrics - Project dashboard and progress tracking
mix phx.gen.live Metrics Metric metrics project_id:references:projects metric_type:string metric_name:string metric_value:decimal calculated_at:datetime metadata:map

# Contexts - Phoenix context definitions and metadata
mix phx.gen.live Contexts Context contexts project_id:references:projects name:string context_type:string description:text entity_name:string file_count:integer status:string

# Dependencies - Inter-context dependency tracking
mix phx.gen.context Dependencies Dependency dependencies source_context_id:references:contexts target_context_id:references:contexts dependency_type:string description:text status:string