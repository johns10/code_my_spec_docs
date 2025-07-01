# AI-Driven SDLC Automation Platform - Technical Context

## Core Mission
Automate the entire Software Development Life Cycle (SDLC) through structured, prescriptive processes that guide AI agents to build and maintain complex applications reliably. The platform addresses the fundamental gap in current AI coding tools: they lack the disciplined processes necessary to handle real-world application complexity.

## Foundational Principle
The bottleneck in AI-assisted development isn't better models or smarter agents—it's the absence of structured processes that can reliably guide AI through complex software development. We solve this with systematic requirements management, architectural discipline, and prescriptive workflows.

## Development Process Flow
1. **Requirements Engineering**: LLM-driven interviews → User stories → Executive summary approval
2. **Demo Validation**: Phoenix context mapping → PHX.Gen scaffolding → Working demo with seed data
3. **BDD Decomposition**: User stories → Testable Given/When/Then specifications → Human approval
4. **Design Documentation**: Context-by-context technical specs → 1:1 file mapping → Architecture approval
5. **Implementation**: Discrete todos → External AI agents (Claude Code) → Branch-based development
6. **Integration**: Multi-branch testing → BDD validation → Production deployment
7. **Change Management**: Requirement changes → Impact analysis → Systematic regeneration

## Key Constraints & Principles
- **Process-First**: Never skip requirements, design, or approval phases
- **Human-in-the-Loop**: Strategic approval gates prevent AI architectural mistakes
- **Traceability**: User story → BDD spec → test → implementation linkage must be maintained
- **Fail-Fast Recovery**: Failed tasks restart clean (no partial work preservation)
- **Context Boundaries**: Respect Phoenix context ownership and prevent architectural leakage
- **Documentation Parity**: 1:1 mapping between design docs and code files

## Change Philosophy
Code is a projection of design. When requirements change, we evolve the design first, then regenerate code to match. This enables systematic handling of complexity and maintains architectural integrity throughout the application lifecycle.