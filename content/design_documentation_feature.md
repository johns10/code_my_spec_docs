# Design Sessions: AI-Generated Component Specifications

> **Stop writing code without specs. Start generating validated design documents that control exactly what AI implements.** Design Sessions orchestrate AI agents through structured workflows that turn architecture into concrete, reviewable design documents.

## The Problem

Most developers jump from architecture directly to code generation. You tell the AI "implement the Stories context" and it invents structure on the fly. Some good, some violating your patterns. By the time you notice the violations, other code depends on them. Refactoring becomes expensive.

Even when you write design docs manually, keeping them consistent across contexts is hard. Does every context follow the same error handling patterns? Do all schemas document their validation rules the same way? Manual design is slow and inconsistent.

## What Design Sessions Do

Design Sessions transforms software design from ad-hoc prompting into an automated, validated workflow. CodeMySpec generate design documents following your templates and rules, validate them against schemas, revise based on errors, and commit the results to git. All orchestrated through discrete, repeatable steps.

Your design documents aren't just text files you paste into conversations. They're structured data validated against schemas, with automatic parsing of sections like Purpose, Public API, Dependencies, and Test Assertions. This enables automatic traceability from architecture through design to code generation.

## How It Works

### Context Design Sessions

**1. Initialize the session**
The system sets up a git working directory for your docs and loads the context definition from your architecture.

**2. AI generates context design**
An AI agent reads your architecture definition, relevant user stories, and design rules. It generates a comprehensive context design document following your template: Purpose, Entity Ownership, Public API, State Management, Dependencies, Components list, and Test Assertions.

**3. Validate the design**
The parser extracts structured data from the markdown: component definitions, dependencies, required sections. If validation fails (missing sections, invalid module names, etc.), the system captures specific errors.

**4. AI revises if needed**
If validation found errors, another AI agent reads the failed design and error messages, then generates a revised version addressing the specific issues. This loops back to validation until the design passes.

**5. Finalize and commit**
Once validated, the system commits the design document to git with a clear message. The context and all its components are now created in the database, ready for component-level design.

### Component Design Sessions

After context design, the system spawns parallel sessions for each component:

**1. Initialize**
Load the parent context design and component metadata (type, module name, description).

**2. Generate component design**
AI agent reads the context design for architectural context, then generates a focused component design: Purpose, Public API (with @specs), Execution Flow, Dependencies, and Test Assertions.

**3. Validate**
Parser ensures all required sections exist, function signatures are valid, dependencies are properly scoped, and the design matches the component type (schema gets Fields section, GenServers get State Management, etc.).

**4. Revise if needed**
Validation errors trigger a revision cycle with the AI addressing specific issues.

**5. Finalize**
Validated design commits to git at `docs/design/{module_path}.md`.

### Design Review Sessions

After all components are designed, an optional review session analyzes the complete context:

- Are dependencies consistent across components?
- Do public APIs align with schemas?
- Are error handling patterns consistent?
- Are all acceptance criteria from user stories addressed?

The review produces a summary document identifying gaps or inconsistencies before any code is generated.

## Key Capabilities

- **Structured orchestration** - Multi-step workflows with validation loops ensure quality
- **Automatic validation** - Designs parsed and validated against schemas, errors caught before code generation
- **Parallel component design** - All components in a context designed concurrently for speed
- **Git integration** - Every design committed with clear messages, full version history
- **Template enforcement** - Your design rules and templates automatically applied
- **Revision loops** - AI automatically fixes validation errors until design passes
- **Traceability** - Each design links to user stories, architecture definitions, and future code
- **Type-specific templates** - Different component types (context, schema, GenServer, LiveView) get appropriate sections

## Integration with Your Workflow

Design Sessions is the **third step** in the CodeMySpec process:

```
1. Stories � Define requirements (AI interviews you)
2. Architect � Design architecture (maps stories to contexts)
3. Design Sessions � Generate component specs (validated designs for each file)
4. Test Sessions � Create tests (from design assertions)
5. Coding Sessions � Implement (code matches design, tests validate)
```

Once designs are generated, Test Sessions read them to create comprehensive tests. Coding Sessions read both design and tests to generate implementations that satisfy both. When something fails, you know exactly which design specification wasn't met.

## Design Document Structure

### Context Design Includes:
- **Purpose** - What business domain this context handles
- **Entity Ownership** - Primary entities managed by this context
- **Access Patterns** - Scoping rules (account/project/user level)
- **Public API** - Function signatures with @specs
- **State Management Strategy** - How data persists
- **Execution Flow** - Step-by-step operation descriptions
- **Dependencies** - Other contexts this depends on
- **Components** - Table of all components with types and descriptions
- **Test Strategies** - Fixture and mock approaches
- **Test Assertions** - What tests should verify

### Component Design Includes:
- **Purpose** - What this specific module does
- **Public API** - Function signatures for this component
- **Execution Flow** - How operations work in this module
- **Dependencies** - What this component depends on
- **Test Assertions** - Specific tests for this component

Additional sections vary by type (schemas get Fields and Validations, GenServers get State Management, etc.).

## Getting Started

**Prerequisites:**
- CodeMySpec account with active project
- Architecture defined with contexts (use Architect MCP)
- Claude Code or Claude Desktop
- Design Sessions orchestration enabled

## Quality Guarantees

**Validation ensures:**
- All required sections present
- Module names follow PascalCase conventions
- Dependencies reference real modules in your project
- Function specs use valid Elixir types
- Component descriptions under length limits
- Test assertions follow ExUnit patterns

**Revision loops guarantee:**
- Designs eventually pass validation or session fails with clear error
- Each revision addresses specific validation failures
- AI doesn't generate the same invalid design repeatedly

**Git history provides:**
- Complete audit trail of design evolution
- Ability to diff designs across time
- Rollback if designs need adjustment
- Clear commit messages explaining what was generated

## Advanced Features

**Custom design rules:** Add project-specific rules that AI agents follow during generation. Rules can enforce naming conventions, required patterns, or architectural constraints specific to your team.

**Similar component analysis:** During generation, AI agents can analyze similar components in your codebase to maintain consistency with existing patterns.

**Incremental updates:** Regenerate individual component designs when requirements change, maintaining consistency with the broader context.

**Dependency graph validation:** System ensures no circular dependencies before allowing design sessions to proceed.

## What Happens Next

After design sessions complete, you have:
- Validated design documents for every component in your context
- Structured data in database linking designs to stories and architecture
- Git-tracked files ready to reference in future sessions
- Clear specifications ready for test generation

Next step: **Test Sessions** read your designs and generate comprehensive tests validating the Public API and Test Assertions sections. After tests exist, Coding Sessions implement components that make tests pass.

The complete chain: Story � Context � Design � Tests � Code, with traceability at every step.

---

**Previous:** [Architect MCP Server](/pages/architect-mcp-feature) - Design Phoenix contexts from stories

**Next:** [Test Sessions](/pages/test-sessions) - Generate tests from design documents

**Manual approach:** [How to Write Design Documents](/content/writing-design-documents) - Learn the process for doing this manually

**Documentation:** [Design Sessions Reference](/docs/design-sessions) - Complete orchestration details and session lifecycle