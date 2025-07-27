# Projects Context - Foundation
mix phx.gen.live Projects Project projects \
  name:string \
  description:text \
  status:string

# Agents Context
mix phx.gen.embedded Agents Agent agents \
  name:string \
  type:enum:claude_code:custom \
  capabilities:array:string \
  status:enum:available:offline:error \
  config:map

# LLMs Context  
mix phx.gen.live LLMs LLM llms \
  name:string \
  provider:enum:anthropic:openai:google:local \
  model:string \
  capabilities:array:string \
  status:enum:available:offline:error \
  config:map

# Conversations Context - References Projects
mix phx.gen.live Conversations Conversation conversations \
  title:string \
  status:enum:active:paused:completed:archived \
  context:map \
  metadata:map \
  external_id:string \
  project_id:references:projects

# Stories Context - References Projects
mix phx.gen.live Stories Story stories \
  title:string \
  description:text \
  acceptance_criteria:array:string \
  status:enum:draft:approved:in_progress:completed:archived \
  priority:integer \
  project_id:references:projects

# Environments Context
mix phx.gen.live Environments Environment environments \
  name:string \
  branch_name:string \
  status:enum:creating:active:merging:archived:failed \
  project_id:references:projects

# Demos Context
mix phx.gen.live Demos Demo demos \
  name:string \
  description:text \
  seed_data:map \
  status:enum:generating:ready:validating:approved:deprecated \
  project_id:references:projects

# Metrics Context
mix phx.gen.live Metrics Metric metrics \
  name:string \
  value:decimal \
  type:enum:story_completion:spec_completion:task_completion:test_coverage \
  project_id:references:projects

# Components Context (Meta)
mix phx.gen.live Components Component components \
  name:string \
  type:enum:context:schema:live_view:controller:genserver:task:test:repository \
  description:text \
  project_id:references:projects 

# Dependencies Context
mix phx.gen.live Dependencies Dependency dependencies \
  component_id:references:components \
  depends_on_id:references:components 

# Messages Context - References Conversations
mix phx.gen.live Messages Message messages \
  provider:string \
  raw_json:map \
  metadata:map \
  conversation_id:references:conversations

# Documents Context - References Contexts
mix phx.gen.live Documents Document documents \
  title:string \
  content:text \
  type:enum:executive_summary:user_story:bdd_spec:context_design:api_contract \
  status:enum:draft:approved:modified:dirty:archived \
  context_id:references:contexts \
  approved_at:datetime

# Specs Context - References Stories
mix phx.gen.live Specs Spec specs \
  title:string \
  given_clause:text \
  when_clause:text \
  then_clause:text \
  status:enum:draft:approved:in_progress:passing:failing:archived \
  story_id:references:stories

# Tasks Context - References Specs + Environments
mix phx.gen.live Tasks Task tasks \
  title:string \
  description:text \
  assignee:enum:agent:human \
  status:enum:pending:in_progress:completed:failed:blocked \
  branch_name:string \
  retry_count:integer \
  spec_id:references:specs \
  environment_id:references:environments

# Task Dependencies (Many-to-Many)
mix phx.gen.schema Tasks.TaskDependency task_dependencies \
  source_task_id:references:tasks \
  dependent_task_id:references:tasks \
  dependency_type:enum:blocks:enables:triggers

# Coordination Contexts
mix phx.gen.context CodeSessions WorkflowState workflow_states \
  session_id:string \
  current_step:string \
  metadata:map \
  status:string

mix phx.gen.context DesignSessions DesignState design_states \
  session_id:string \
  phase:string \
  artifacts:array:string \
  status:string

mix phx.gen.context DemoReview ReviewState review_states \
  demo_id:references:demos \
  feedback:text \
  status:string \
  reviewer:string

mix phx.gen.context UserConversation ConversationFlow conversation_flows \
  conversation_id:references:conversations \
  current_turn:integer \
  flow_state:map

mix phx.gen.context Tools ToolRegistry tool_registries \
  name:string \
  type:string \
  endpoint:string \
  capabilities:map

# Tests Context - Embedded Schema (No Persistence)
mix phx.gen.context Tests TestResult test_results \
  name:string \
  status:enum:passing:failing:skipped:error \
  output:text \
  duration:integer