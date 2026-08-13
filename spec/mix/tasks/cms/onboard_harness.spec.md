# Mix.Tasks.Cms.OnboardHarness

The CodeMySpec-side entry point for onboarding a working copy onto the harness. Delegates the portable work to `client_utils`, which is where the implementation lives so that a generated target application — which depends on client_utils and not on CodeMySpec — can onboard itself with the same command.

Exists so this repo has a surface the story can be specced and spexed against. The division: client_utils writes the values (Anthropic base URL into `.claude/settings.local.json`, the assigned test partition name), and this task adds whatever is CodeMySpec-specific, then reports what it did not do.

Never creates, migrates or drops a database. It names the databases the working copy needs and prints the exact commands, leaving the agent to run them — which keeps intact the rule written after a background process with `MIX_ENV` scrubbed out emptied the shared development database three times on 2026-08-13.

Runs from inside a worktree that already exists; it does not create worktrees.

## Type

module
