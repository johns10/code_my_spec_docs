# CodeMySpec.Specs.Spec

Embedded schema representing a parsed spec file.

**Fields**:

| Field        | Type       | Required | Description                          |
| ------------ | ---------- | -------- | ------------------------------------ |
| module_name  | string     | Yes      | Fully qualified module name from H1  |
| type         | string     | No       | Component type from **Type** field   |
| description  | string     | No       | Brief description from body text     |
| delegates    | [string]   | No       | List of delegated functions          |
| functions    | [Function] | No       | List of public functions             |
| dependencies | [string]   | No       | List of dependencies                 |
| fields       | [Field]    | No       | Schema fields (schemas/structs only) |
