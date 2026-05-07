# ClientUtils.DiagnosticsFormat

Serializes `Mix.Task.Compiler.Diagnostic` structs to JSON-compatible maps.

## to_jsonl(diagnostics)

Encodes a list of diagnostics as JSONL (one JSON object per line).

## to_map(diagnostic)

Converts a diagnostic struct to a plain map suitable for JSON encoding.