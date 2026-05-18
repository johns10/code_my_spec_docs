# CodeMySpec.Qa.Scenario

Embedded schema for a single tested scenario within a QaAttempt. Fields: name (string), status (:pass | :partial | :fail), observation (string). Stored as embeds_many on QaAttempt so each scenario is queryable individually per story 726 R6.

## Type

schema
