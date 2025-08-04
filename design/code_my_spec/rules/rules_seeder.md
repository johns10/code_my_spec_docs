# Rules Seeder

## Purpose
Loads base rules from markdown files in the rules directory and creates database records for new accounts, parsing frontmatter to extract matching criteria.

## Core Operations/Public API

### Seeding Functions
```elixir
@spec seed_account_rules(Scope.t(), account_id :: integer()) :: {:ok, [Rule.t()]} | {:error, term()}
@spec load_rules_from_directory(path :: String.t()) :: [rule_data()]
@spec parse_rule_file(file_path :: String.t()) :: {:ok, rule_data()} | {:error, term()}
```

### Types
```elixir
@type rule_data :: %{
  name: String.t(),
  content: String.t(),
  component_type: String.t(),
  session_type: String.t()
}
```

## Function Descriptions

### seed_account_rules/2
Main seeding function called during account creation. Loads all rule files from `docs/rules/` directory, parses their frontmatter and content, then creates Rule records associated with the account.

### load_rules_from_directory/1
Scans the rules directory for markdown files and processes each one through parse_rule_file/1. Returns a list of rule_data structs ready for database insertion.

### parse_rule_file/1
Parses a single markdown file, extracting:
- YAML frontmatter for component_type, session_type
- Markdown content as the rule text
- Filename as the default rule name

## Frontmatter Format

Rules files use YAML frontmatter to specify matching criteria:

```yaml
---
component_type: "repository"
session_type: "*"
---
```

Files without explicit component_type/session_type default to "*" wildcards for maximum applicability.

## Usage Patterns

### Account Creation Hook
The seeder runs automatically when new accounts are created, populating them with the complete set of base rules from the markdown files.