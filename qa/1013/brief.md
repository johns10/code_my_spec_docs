# Qa Story Brief

## Tool

`curl` is not applicable — this story's surface is a mix task, not an HTTP route or
a LiveView. Test by running `mix cms.harness.onboard` from a shell against a
throwaway working copy and inspecting what it wrote.

## Auth

None. The task takes no credentials. It reaches the network in exactly one case —
minting a harness id for a copy that has none — and that path is deliberately not
exercised here (see Setup Notes).

## Seeds

No database seeds. The working copy is the fixture, and it is built in the
scratchpad so nothing touches this checkout:

    Q=<scratchpad>/qa891
    mkdir -p "$Q" && git -C "$Q" init --quiet

Write `$Q/.cms_harness.json` with an id so the task reads one instead of minting:

    {"harness_id": "qa891-throwaway", "project_id": "qa891", "root": "$Q"}

A second copy for the never-onboarded case:

    F=<scratchpad>/qa891-fresh
    mkdir -p "$F" && git -C "$F" init --quiet

And a **generated application** — depends on client_utils, not on CodeMySpec —
which is what criterion 2351 actually claims:

    T=<scratchpad>/target_app
    mix.exs: deps: [{:client_utils, "~> 0.1.24"}]
    mix deps.get && git -C "$T" init --quiet

## What To Test

- **One command configures a fresh copy** (2350). Run `mix cms.harness.onboard "$Q"`.
  Expect `.claude/settings.local.json` to appear carrying both `ANTHROPIC_BASE_URL`
  and `MIX_TEST_PARTITION`, and the outstanding databases printed.
- **The address lands untracked, and carries this copy's id** (2352, 2353). The URL
  must contain `qa891-throwaway`. `.claude/settings.json` must not be created.
- **One partition, and it is in the file** (2354). The `MIX_TEST_PARTITION` value in
  the settings must equal the partition named in the printed database names.
- **Two databases, each named in its own commands** (2355, 2358, 2360). Expect
  `code_my_spec_test_<p>` and `code_my_spec_test_<p>s`, each with a create and a
  migrate carrying its own `MIX_TEST_PARTITION=`.
- **Nothing is created** (2359). No database should exist afterwards; the commands
  are printed only.
- **Submodules recurse** (2361). `git -C "$Q" config --get submodule.recurse` → `true`.
- **Running twice changes nothing** (2356). Hand-edit the settings (add `EDITOR` to
  `env`, add a `permissions` block), re-run, and confirm both survive and the id and
  partition are unchanged.
- **Not-onboarded reports itself** (2357). Run `--check` against `$F` and against
  `$Q` and compare what an operator sees.
- **The printed name is the database the command creates** (2355). Run the guard
  under the same partition and compare:

      MIX_TEST_PARTITION=<p> MIX_ENV=test mix cms.check_test_migrations

  The name it refuses on must be the name onboarding printed, character for
  character. This is the check that was missing through two rounds of QA, and
  both times a real defect passed because onboarding's output was only ever
  compared to onboarding's output.
- **A generated application gets its own name** (2351). In `$T`, the databases
  must be `target_app_test<p>`, not `code_my_spec_*`.

## Result Path

Recorded via `submit_qa_result` on task `210246e7-14b7-48ac-bbf0-48324883b66c`;
findings filed as issues.

## Setup Notes

**The minting path is deliberately not exercised.** A copy with no
`.cms_harness.json` asks the server for an id, which creates a real harness record
against a throwaway directory. That is a side effect QA should not leave behind, so
every scenario here starts from a copy that already has an id — which is also the
common case, and the one where "changes nothing" has to hold. The mint path is
covered by `cms_harness` unit tests, not here, and that gap is stated rather than
hidden.

**Hooks are expected to be skipped.** `cms-mcp-relay` on this machine prints nothing
for `capabilities`, so `check_relay/0` refuses and the plugin directory is not
written. That is the intended behaviour after this story: the relay gates the hooks,
not the whole command. Absence of `.claude/plugin-dev` is a pass, not a failure.
