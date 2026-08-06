# CodeMySpec.Intake

Pre-signup plans. Holds the visitor's description, their answers about sign-in and separate copies, and the names the plan proposes, as a row keyed to an anonymous session cookie that never expires. Generates the plan from the description, and converts a confirmed plan into an account and project at signup — under the confirmed names, with no collision ever surfaced to the visitor.

## Type

context

## Dependencies

- CodeMySpec.Accounts
- CodeMySpec.Projects
