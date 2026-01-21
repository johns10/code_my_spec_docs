# CodeMySpec.Sessions.AgentTasks.ContextSpec

**Type**: module

Consolidated context spec session for Claude Code slash commands. Generates comprehensive prompts for creating Phoenix bounded context specifications with design rules, user stories, and similar component examples. Validates generated specs against context_spec document schema and creates child component spec files from parsed sections.

## Functions

### command/3

Generate the command/prompt for Claude to create a context specification.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract component from session
2. Retrieve design rules using Rules.find_matching_rules/2 for "context" and "design" types
3. Fetch similar components using Components.list_similar_components/2
4. Load user stories for the context using Stories.list_component_stories/2
5. Build comprehensive prompt with build_spec_prompt/4 including:
   - Project name and description
   - Context name, description, and type
   - Formatted user stories with acceptance criteria
   - Similar component references with design/implementation/test file paths
   - Document specification from DocumentSpecProjector
   - Design rules text
   - Target spec file path
6. Return {:ok, prompt_text}

**Test Assertions**:
- generates prompt with all required sections (project, context, stories, similar components, document spec, design rules)
- includes design rules matching "context" and "design" types
- formats user stories with acceptance criteria
- formats similar components with file paths
- includes target spec file path from Utils.component_files/2
- returns {:ok, prompt} on success

### evaluate/3

Evaluate Claude's output and provide feedback if needed.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Read generated spec file using read_spec_file/1
2. Validate document against context_spec schema using Documents.create_dynamic_document/2
3. Create child spec files from parsed components section using create_child_spec_files/2
4. Return {:ok, :valid} if spec passes validation and child files created successfully
5. Return {:ok, :invalid, feedback} with validation errors for Claude to fix if document invalid
6. Return {:error, reason} if file reading or other operations fail

**Test Assertions**:
- returns {:ok, :valid} when spec file exists and passes validation
- returns {:ok, :invalid, feedback} when spec file is invalid with validation errors
- creates child spec files for components listed in Components section
- returns {:error, reason} when spec file not found
- returns {:error, reason} when spec file is empty
- builds revision feedback with validation errors for Claude

## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Utils
- CodeMySpec.Environments
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Stories
- CodeMySpec.Components
