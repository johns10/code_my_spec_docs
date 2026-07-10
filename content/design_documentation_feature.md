---
# Metadata for design_documentation_feature.md
# This file defines metadata for content that will be synced to the database

# Required fields
slug: design-documentation-feature
type: page  # Options: blog, page, landing
title: Design Docs - Validated Specs Before Code

# Publishing control
protected: false  # Set to true to require authentication (routes to /private/*)
publish_at: "2025-11-13T00:00:00Z"
expires_at: null  # ISO 8601 datetime or null for never expires

# SEO Metadata
meta_title: Validated Design Documents for AI Code Generation
meta_description: Write specs first, validate automatically, then let AI implement what you specified. 17 document types with type-specific validation.
og_title: Design Docs - Validated Specs Before Code
og_description: Stop letting AI invent structure. Write validated design documents that control exactly what gets implemented. Type-specific validation catches problems before code.
og_image: null  # URL to Open Graph image

metadata:

# Tags (optional, list of tag names)
tags:
  - design-sessions
  - design-documents
  - specifications
  - orchestration
  - validation
  - phoenix-contexts
  - component-design
  - ai-workflows
  - claude
  - structured-data
  - git-integration
  - test-driven-development
---

# Design Docs: Validated Specs Before Code

Write specs first. Validate them automatically. Then let AI implement what you specified — not what it invents.

## The Problem

You tell AI "implement the Stories context." It invents structure on the fly. Some decisions are good. Others violate your patterns. By the time you notice, other code depends on the violations.

I watched this happen on my own project. Handed a feature to an LLM with architectural guidelines. Came back to find it had invented a nested architecture inside my infrastructure layer. Compiled fine. Tests passed. Worked. Completely wrong. Took days to untangle.

The core issue: **AI makes architectural decisions at code generation time.** Every function signature, every error handling pattern, every dependency choice — decided on the fly by a model that doesn't understand your design intent. Manual design docs don't solve this either. They drift. Nobody validates them. They become aspirational fiction within a week.

## How It Works

CodeMySpec treats design docs as structured data with type-specific validation. Not documentation you write after — specifications the system enforces before.

**1. Create components with types** during architecture design. Each type (context, schema, liveview, etc.) determines which document rules apply.

**2. Generate specs** using agent tasks. A context_spec needs functions, dependencies, and a components section. A liveview spec needs route, interactions, design, and dependencies. The type enforces the right structure.

**3. Validate automatically.** Missing required sections? Invalid function specs? Malformed fields? Caught before any code is generated. The agent revises until the document passes.

**4. Implement from specs.** Validated specs are parsed into structured data — function signatures, field definitions, dependency lists. Implementation reads the spec. Tests read the assertions. No improvisation.

The key difference from writing docs in a wiki: validation is automatic and mandatory. You can't generate code from a malformed spec. You can't skip sections the component type requires. The system enforces consistency that humans can't maintain manually.

## 17 Document Types

**Component Specs:** spec, context_spec, schema, json

**LiveView Specs:** liveview, liveview_component, live_context_spec

**Architecture:** architecture_proposal, design_review, adr, dynamic_document

**QA:** qa_plan, qa_story_brief, qa_result, qa_issue, qa_journey_plan, qa_journey_result

Each type defines required sections. A context_spec needs Functions + Dependencies + Components. A liveview needs Route + User Interactions + Design + Dependencies. A schema needs a Fields table with types and constraints.

## The Validation Pipeline

Once specs and code exist, everything runs through:

1. Compiler
2. Tests (ExUnit)
3. Credo (code quality)
4. Sobelow (security)
5. Spex (BDD specs)
6. Spec validation (document structure)

22 requirement checkers track progress per component. The system knows what's done and what remains.

## Agent-Driven Workflow

The ProjectCoordinator walks a requirement dependency graph to find the next actionable task. 41 agent tasks handle the work:

- **Specs:** ContextSpec, ComponentSpec, LiveViewSpec
- **Design:** ArchitectureDesign, ContextDesignReview
- **Implementation:** DevelopContext, DevelopComponent, DevelopLiveView
- **Testing:** WriteBddSpecs, FixBddSpecs
- **QA:** QaStory, QaJourneyPlan, QaJourneyExecute

Stop-and-validate pattern: write one artifact, validate, get feedback, continue. Dirty tracking identifies which components need re-analysis when specs change.

## Where It Fits

```
Stories → Architecture → Design (you are here) → Implementation → QA
```

---

**Previous:** [Architecture →](/pages/architect-mcp-feature)
