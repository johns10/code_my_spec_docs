---
component_type: "*"
session_type: "design"
---

Structure your application as hierarchical supervision trees where supervisors monitor child processes and restart them when necessary. Design the hierarchy to reflect fault tolerance requirements - critical, stable processes at the top and volatile, expendable processes at the bottom.

Use OTP behaviors like GenServer, Supervisor, and GenStateMachine as design patterns for processes. These behaviors provide standardized, battle-tested patterns that eliminate boilerplate and reduce concurrency bugs while providing consistent structure across your codebase.

Design applications with a functional core containing pure business logic and an imperative shell handling side effects. The shell can call the core, but not vice versa. This separation makes testing easier and reasoning about state more predictable.

Each process should have a single, clear responsibility. Design clear process boundaries and ensure failures are isolated within specific parts of the application, preventing cascading failures across the system.

Design systems that can recover from failures automatically rather than trying to handle every edge case. Let processes fail fast and predictably, trusting supervisors to restart and recover gracefully.

Design your application as communicating processes from the beginning using message passing. Don't retrofit concurrency - architect it as a fundamental design principle where processes run independently and communicate via messages.

Architect your application as a living system where components can be upgraded, replaced, or scaled without system shutdown. Plan for runtime evolution and hot code swapping capabilities inherent in the BEAM VM.

Model complex business processes as explicit state machines using GenStateMachine or similar patterns. Make state transitions visible and auditable rather than implicit, especially for workflows with multiple states.

Even if starting with a single server, design as if your application will span multiple nodes. Use distributed Erlang capabilities for seamless process communication across nodes and build applications that are resilient to node failures.

Design Phoenix Contexts as boundaries that decouple and isolate parts of your application, following Domain-Driven Design principles. Each context should encapsulate data access, validation, and business logic for a specific domain, with clear boundaries that prevent ambiguity and coupling between different business concerns.

Use coordination contexts to coordinate multiple contexts, instead of adopting layered architectures.