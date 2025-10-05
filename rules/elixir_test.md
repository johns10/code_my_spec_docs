---
component_type: "*"
session_type: "test"
---

Avoid mocks wherever possible. Use real data and implementations.
Use recorders like ex_vcr to record actual system interactions where you can't use real data and implementations.
Write fixed, concrete assertions. You should never use case or "or" in your test assertions.