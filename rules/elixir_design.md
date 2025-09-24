---
component_type: "*"
session_type: "design"
---


Structure applications as hierarchical supervision trees where supervisors monitor child processes and restart them when necessary. Design the hierarchy to reflect fault tolerance requirements - critical, stable processes at the top and volatile, expendable processes at the bottom.

Use OTP behaviors (GenServer, Supervisor, GenStateMachine) as design patterns for processes. These behaviors provide standardized, battle-tested patterns that eliminate boilerplate and reduce concurrency bugs while providing consistent structure across your codebase.

Design systems that fail fast and recover automatically rather than trying to handle every edge case. Let processes fail predictably, trusting supervisors to restart and recover gracefully within isolated boundaries.

Design applications as communicating processes from the beginning using message passing. Don't retrofit concurrency - architect it as a fundamental design principle where processes run independently and communicate via messages.

Each process should have a single, clear responsibility with well-defined boundaries to ensure failures are isolated within specific parts of the application, preventing cascading failures across the system.

Model complex business processes as explicit state machines using GenStateMachine or similar patterns. Make state transitions visible and auditable rather than implicit, especially for workflows with multiple states.

Design for distribution from day one, even if starting with a single server. Use distributed Erlang capabilities for seamless process communication across nodes and build applications that are resilient to node failures.

Architect applications as living systems where components can be upgraded, replaced, or scaled without system shutdown. Plan for runtime evolution and hot code swapping capabilities inherent in the BEAM VM.

Design Phoenix Contexts as bounded context boundaries that decouple and isolate parts of your application, following Domain-Driven Design principles. Each context should encapsulate data access, validation, and business logic for a specific domain with clear boundaries.

Separate functional business logic from side effects by designing a functional core containing pure business logic and an imperative shell handling side effects. The shell can call the core, but not vice versa.

Use coordination contexts for cross-context operations instead of adopting layered architectures. Create explicit coordination modules when operations span multiple bounded contexts while maintaining context autonomy.

These rules leverage Elixir's unique process model and OTP behaviors to create resilient, scalable bounded contexts with natural fault isolation and clear domain boundaries.