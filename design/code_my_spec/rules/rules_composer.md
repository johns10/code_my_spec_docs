# Rules Composer

## Purpose
Takes a list of rules and combines their content into a single formatted string for use in AI prompts and context generation.

## Core Operations/Public API

### Composition Functions
```elixir
@spec compose_rules([Rule.t()]) :: String.t()
@spec compose_rules_with_separator([Rule.t()], separator :: String.t()) :: String.t()
```

## Function Descriptions

### compose_rules/1
Takes a list of Rule structs and concatenates their content fields into a single string. Uses double newlines as the default separator between rules to ensure proper formatting in prompts.

### compose_rules/2
Same as compose_rules/1 but allows specifying a custom separator string between rule contents.

## Usage Patterns

### Basic Composition
```elixir
rules = RulesRepository.find_matching_rules(scope, "context", "coding")
composed_string = RulesComposer.compose_rules(rules)
```

### Custom Separator
```elixir
rules = RulesRepository.find_matching_rules(scope, "*", "design")
composed_string = RulesComposer.compose_rules(rules, "\n---\n")
```

The composer handles empty rule lists gracefully by returning an empty string, and filters out any rules with blank or nil content.