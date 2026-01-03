# CodeMySpec.Quality.Compile

**Type**: other

Validates compilation results from mix compile.machine output. Parses JSON compiler diagnostics and checks for errors and warnings, providing quality scores based on compilation success.

## Functions

### quality_score/1

Calculates quality score for warnings using linear decay with a floor.

```elixir
@spec quality_score(non_neg_integer()) :: float()
```

**Process**:
1. Calculate base score: `1.0 - (warning_count * 0.1)`
2. Apply floor using `max/2` to ensure minimum score of 0.0

**Test Assertions**:
- returns 1.0 for 0 warnings
- returns 0.9 for 1 warning
- returns 0.8 for 2 warnings
- returns 0.1 for 9 warnings
- returns 0.0 for 10 warnings
- returns 0.0 for 15 warnings (floor applied)
- returns 0.0 for 100 warnings (floor applied)

### check_compilation/1

Checks compilation state from a command result by parsing compiler JSON output and validating compilation succeeded.

```elixir
@spec check_compilation(%{data: %{compiler: String.t() | map()}}) :: Result.t()
```

**Scoring**:
- 0.0 if any compilation errors present
- Linear decay for warnings: `score = max(1.0 - (warning_count * 0.1), 0.0)`
  - 0 warnings = 1.0
  - 1 warning = 0.9
  - 2 warnings = 0.8
  - 10+ warnings = 0.0 (floor)

Warnings are included in the errors list for visibility and reduce quality score through linear decay.

**Process**:
1. Extract compiler data from result map
2. Parse JSON compiler output if in string format, or use map directly
3. Extract diagnostics list from parsed data
4. Categorize diagnostics into errors and warnings by severity
5. Evaluate diagnostics:
   - If errors exist: return score 0.0 with formatted error and warning messages
   - If only warnings exist: calculate quality score using `max(1.0 - (warning_count * 0.1), 0.0)` and return with formatted warning messages
   - If clean compile: return score 1.0 with empty errors list
6. Format diagnostic messages as "Type (file:line): message"

**Test Assertions**:
- returns Result with score 1.0 and empty errors for clean compilation (no diagnostics)
- returns Result with score 0.9 and formatted warnings when 1 warning present
- returns Result with score 0.8 and formatted warnings when 2 warnings present
- returns Result with score 0.5 and formatted warnings when 5 warnings present
- returns Result with score 0.0 and formatted warnings when 10 warnings present
- returns Result with score 0.0 and formatted warnings when more than 10 warnings present (floor enforced)
- returns Result with score 0.0 and formatted errors when compilation errors exist
- returns Result with score 0.0 and both errors and warnings when both are present
- handles compiler output as JSON string and decodes successfully
- handles compiler output as already-parsed map
- returns error Result when compiler data is missing from result map
- returns error Result when JSON decoding fails
- returns error Result when diagnostics key is missing from compiler output
- formats error messages with file path, line number, and message content
- formats warning messages with "Compilation Warning" prefix
- formats error messages with "Compilation Error" prefix
- categorizes diagnostics correctly by severity field (error vs warning)
- ignores diagnostics with unknown severity values

## Dependencies

- CodeMySpec.Quality.Result
- Jason
