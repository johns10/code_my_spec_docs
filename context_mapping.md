# Requirements Generator - Final Context Mapping

## Context Architecture Overview

This document defines the Phoenix context mapping for the Requirements Generator application. Each user story maps to **exactly one context** responsible for satisfying that requirement.

## Domain Contexts (Entity Owners)

### Projects Context
**Type**: Domain Context  
**Entity**: `Project`  
**Responsibilities**: Project creation, configuration, and workspace management  
**Dependencies**: None  

### Conversations Context
**Type**: Domain Context  
**Entity**: `Conversation`  
**Responsibilities**: Conversation state persistence, metadata management, and message threading  
**Dependencies**: Messages  

### Messages Context
**Type**: Domain Context  
**Entity**: `Message`  
**Responsibilities**: Message CRUD operations and content management  
**Dependencies**: None  

### Stories Context
**Type**: Domain Context  
**Entity**: `Story`  
**Responsibilities**: User story CRUD, editing, change tracking, and impact analysis  
**Dependencies**: None  

### Documents Context
**Type**: Domain Context  
**Entity**: `Document`  
**Responsibilities**: Design document storage, manual editing, approval tracking, and version history  
**Dependencies**: None  

### Environments Context
**Type**: Domain Context  
**Entity**: `Environment`  
**Responsibilities**: Isolated workspace creation, Git branch management, and environment lifecycle  
**Dependencies**: None  

### Demos Context
**Type**: Domain Context  
**Entity**: `Demo`  
**Responsibilities**: Demo application generation, PHX.Gen command execution, and seed data management  
**Dependencies**: None  

### Specs Context
**Type**: Domain Context  
**Entity**: `Spec`  
**Responsibilities**: BDD specification storage, traceability linking, and requirements mapping  
**Dependencies**: Stories  

### Tasks Context
**Type**: Domain Context  
**Entity**: `Task`  
**Responsibilities**: Implementation todo management, dependency ordering, human/agent assignment, and completion tracking  
**Dependencies**: Specs, Environments  

### Agents Context
**Type**: Domain Context  
**Entity**: `Agent`  
**Responsibilities**: External agent management (Claude Code, OpenHands, etc.) and capability tracking  
**Dependencies**: None  

### LLMs Context
**Type**: Domain Context  
**Entity**: `LLM`  
**Responsibilities**: Internal LLM management (Claude, GPT-4, etc.) and model capability tracking  
**Dependencies**: None  

### Tests Context
**Type**: Domain Context  
**Entity**: `TestResult`  
**Responsibilities**: Test result storage and test execution data management  
**Dependencies**: None  

### Metrics Context
**Type**: Domain Context  
**Entity**: `Metric`  
**Responsibilities**: Project dashboard data, progress tracking, and reporting metrics  
**Dependencies**: Stories, Specs, Tasks  

### Contexts Context
**Type**: Domain Context  
**Entity**: `Context`  
**Responsibilities**: Context definition, metadata, and type management (domain vs coordination)  
**Dependencies**: None  

### Dependencies Context
**Type**: Domain Context  
**Entity**: `Dependency`  
**Responsibilities**: Inter-context dependency tracking, resolution ordering, and validation  
**Dependencies**: Contexts  

---

## Coordination Contexts (Workflow Orchestrators)

### CodeSessions Context
**Type**: Coordination Context  
**Responsibilities**: Code work orchestration, integration workflows, retry management, and agent coordination for all code-related activities  
**Dependencies**: Environments, Agents, Tasks, Tests  

### DesignSessions Context
**Type**: Coordination Context  
**Responsibilities**: Design workflow orchestration, LLM conversations, document generation, and all design-phase activities from executive summary to detailed documentation  
**Dependencies**: Documents, Stories, Specs, LLMs, UserConversation  

### DemoReview Context
**Type**: Coordination Context  
**Responsibilities**: Demo validation workflow orchestration, feedback collection, and documentation updates based on demo validation  
**Dependencies**: Demos, Documents, UserConversation  

### UserConversation Context
**Type**: Coordination Context  
**Responsibilities**: User conversation flow management, turn coordination, LLM response orchestration, and tool calling during conversations  
**Dependencies**: Conversations, Messages, LLMs, Tools  

### Tools Context
**Type**: Coordination Context  
**Responsibilities**: Internet access coordination, current information retrieval, MCP tool management, and cross-context tool capabilities  
**Dependencies**: None  

## Design Change Manager
**Type**: Coordination Context
**Responsibilities**: Manages dirtying downstream artifacts when designs change

---

## Requirements to Context Mapping

| Requirement                                  | Context               |
| -------------------------------------------- | --------------------- |
| 1.1 New Project Creation                     | Projects              |
| 1.2 Project Configuration                    | Projects              |
| 1.3 Executive Summary Generation             | DesignSessions        |
| 2.1 LLM-Driven Interview Process             | DesignSessions        |
| 2.2 User Story Management                    | Stories               |
| 2.3 User Story Completeness Review           | DesignSessions        |
| 3.1 Initial Context Mapping                  | DesignSessions        |
| 3.2 Phoenix Application Scaffolding          | Demos                 |
| 3.3 Guided Demo Validation                   | DemoReview            |
| 4.1 BDD Specification Decomposition          | DesignSessions        |
| 4.2 Requirements Traceability                | Specs                 |
| 5.1 BDD Specification to Context Refinement  | DesignSessions        |
| 5.2 Context Design Documentation             | DesignSessions        |
| 5.3 Context Type Management                  | Contexts              |
| 5.4 Documentation Review Process             | DesignSessions        |
| 5.5 Manual Documentation Modification        | Documents             |
| 5.6 Current Information Access               | Tools                 |
| 6.1 Todo Generation                          | Tasks                 |
| 6.2 Dependency-Ordered Task Management       | Tasks                 |
| 6.3 External Coding Agent Integration        | CodeSessions          |
| 6.4 Test Failure Handling                    | CodeSessions          |
| 6.5 Task Failure Recovery                    | CodeSessions          |
| 6.6 Todo Administration and Human Assignment | Tasks                 |
| 6.7 Human Task Completion                    | Tasks                 |
| 7.1 Multi-Branch Integration                 | CodeSessions          |
| 7.2 Component Integration Testing            | CodeSessions          |
| 7.3 Context Integration Testing              | CodeSessions          |
| 7.4 BDD Validation Testing                   | CodeSessions          |
| 7.5 Integration Failure Handling             | CodeSessions          |
| 8.1 Postmortem Analysis                      | DesignSessions        |
| 8.2 Retry Management                         | CodeSessions          |
| 9.1 User Story Change Impact                 | Design Change Manager |
| 9.2 Design Evolution                         | DesignSessions        |
| 10.1 Multi-User Coordination                 | DesignSessions        |
| 10.2 Approval Workflows                      | DesignSessions        |
| 11.1 BDD Specification Status Tracking       | Metrics               |
| 11.2 Project Dashboard                       | Metrics               |

---

## Design Principles

1. **Single Responsibility**: Each requirement maps to exactly one context
2. **One Entity Per Domain Context**: Each domain context owns exactly one entity type
3. **Minimal Boundary Object**: This mapping is the lightweight bridge between database design and code implementation
4. **Clear Testing Ownership**: Each requirement has one context responsible for satisfying it
5. **Dependency Clarity**: Context dependencies are explicitly defined and tracked