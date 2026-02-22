# Testing Knowledge Base

This project tests an application that acts on *other* applications (Elixir/Phoenix projects). That creates two fundamental challenges:

1. **External commands** - We run `mix compile`, `mix test`, `mix credo`, etc. in target projects
2. **Target project needed** - Tests need a real, compilable Phoenix project to operate on

Our solution: **record external boundaries** and **pool pre-built fixture repos**.

## Quick Reference

| What you need | Where to look |
|---|---|
| How to set up a test that needs a project | [Test Patterns](test_patterns.md#standard-setup) |
| How CLI recording/replay works | [Recording System](recording_system.md) |
| How fixture repos are managed | [Test Adapter & Pool](test_adapter_pool.md) |
| What fixtures exist and their formats | [Fixtures Reference](fixtures.md) |
| How scope and environment work in tests | [Test Patterns](test_patterns.md#scope-and-environment) |

## Architecture Overview

```
Test Suite
    |
    ├── ExCliVcr (CLI recording)     ── records/replays System.cmd calls
    ├── ExVCR (HTTP recording)       ── records/replays HTTP requests
    ├── TestAdapter.Pool             ── pools pre-built Phoenix project copies
    ├── RecordingEnvironment         ── test environment impl (filesystem ops)
    └── Fixture Files                ── cassettes, transcripts, source files
```

### Recording Layer

Two VCR libraries capture the boundary between CodeMySpec and the outside world:

- **ExCliVcr** - Intercepts `System.cmd/3` calls. Records command, args, opts, output, and exit code to JSON cassettes. Used for `mix compile`, `mix credo`, `mix test`, etc.
- **ExVCR** - Standard HTTP recording. Used for GitHub API calls.

See [Recording System](recording_system.md) for details.

### Fixture Repository Layer

Tests need a real Phoenix project. Rather than cloning from GitHub every test:

1. `test_helper.exs` clones once and caches build artifacts
2. `TestAdapter.Pool` (GenServer) manages a pool of rsync'd copies
3. Tests check out a copy, use it, check it back in
4. Git reset between uses keeps copies clean

See [Test Adapter & Pool](test_adapter_pool.md) for details.

### Fixture Files

Static test data lives in `test/fixtures/`:

| Directory | Format | Purpose |
|---|---|---|
| `cassettes/` | JSON | CLI command recordings (ExCliVcr) |
| `vcr_cassettes/` | JSON | HTTP API recordings (ExVCR) |
| `transcripts/` | JSONL | Claude Code session recordings |
| `compiler/` | `.ex` | Elixir source files that produce specific compiler output |
| `component_coding/` | `.ex` | Implementation fixture source files |
| `component_test/` | `.ex` | Test fixture source files |
| `proposals/` | `.md` | Architecture proposal fixtures |

See [Fixtures Reference](fixtures.md) for details.
