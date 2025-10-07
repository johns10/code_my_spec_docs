---
component_type: "*"
session_type: "test"
---

Avoid mocks wherever possible. Use real data and implementations.
Use recorders like ex_vcr to record actual system interactions where you can't use real data and implementations.
Mocks are appropriate to use at the boundary of the application, especially when they will heavily impact the performance of the test suite.
Identify application boundaries that need mocks, and write them if necessary.
Tests should be relatively fast. We don't want to slow the test suite down.
Write fixed, concrete assertions. You should never use case or "or" in your test assertions.
Do not use try catch statements in tests.