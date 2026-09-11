# CodeMySpec.MainAgent

The agent that owns a project at the top level: it sees what every agent in its working copies is doing, answers what it can from what the project records, starts and stops the agents it is responsible for, and decides what is worth a non-technical user's attention. Distinct from CodeMySpec.Agents, which owns an individual agent's lifecycle - this owns the view across them and the judgement about them.

## Type

context
