# CmsHarness.AppInstance

One working copy's own instance of the app it holds — story 1108. Each copy runs its own instance on its own port and its own database, so QA can test a story's branch before it is promoted instead of finding out a copy's own address silently served main's pre-fix code (issue 2d612ae8: metric_flow's story 1103 fix landed on the feature copy, but the only running app was main's, and the copy's own address answered with main's code anyway).

A GenServer per working copy, one per root, a sibling of `Project.Supervisor`/`AgentSupervisor` in `CmsHarness.Supervisor` rather than nested in `Project.Supervisor`'s `rest_for_one` chain — that chain restarts everything together because each child answers to one channel join, and an app instance must survive a reconnect, a channel blip, a `mix test` run in the same copy, none of which the app it started should notice. Found by `root` in the same `CmsHarness.Registry` everything else here uses (`{:app_instance, root}`), under a new top-level `CmsHarness.AppInstanceSupervisor` (`DynamicSupervisor`).

Launch/track/kill strategy is `CodeMySpec.Workspaces.Runner.Local`'s, written for the customer-facing Workspaces demo feature and reused here for a working copy that already exists rather than one built from nothing: a bash one-liner that backgrounds the process and echoes its pid (`setsid` where it exists, `disown` on macOS where it does not), state persisted to a JSON file under `~/.codemyspec/app-instances/<hash of root>/` rather than held only in this process's memory (so a harness restart can still find and kill an orphaned process — `stop_app/1` goes through the same find-or-start path as `ensure_running/1`/`restart/1` for exactly this reason), `kill -0` for liveness, `pkill -TERM -P` then `kill -TERM` to take the whole process tree with it (needed because `mix phx.server` forks a BEAM which forks workers).

Port and database are allocated once (via the same bind-then-close free-port trick `Runner.Local` uses) and persisted, not re-derived on every start — a stable address is worth more than a fresh one, and QA bookmarking a link should not have it move under them on a restart. Two ports, not one: an app with an HTTPS endpoint needs its own, and skipping it is what cost this on its very first real run — `HTTPS_PORT` unset fell back to config's hardcoded default, which collided with a real listener already holding it.

First start clones main's dev database by `pg_dump | psql` rather than `CREATE DATABASE ... TEMPLATE`, which Postgres refuses against a database that has any open connections — and main's own running app always holds some. Main's database name is read out of its own `config/dev.exs` as plain text (the same reasoning `config/test.exs`'s own recorded-partition logic gives: config runs before deps load, so there is nothing to call yet), resolved to main's checkout via `git rev-parse --path-format=absolute --git-common-dir` from inside this copy — the same trick this project's own root `justfile` uses for the same reason. Every identifier that reaches a shell string is validated first (`safe_identifier?/1`) before it is interpolated.

An app declares how it starts with a `serve` recipe in its `justfile` — no positional parameters, since one app might need only `PORT`/`DATABASE_NAME` and another (this project itself) also needs `HTTPS_PORT`; the harness sets whatever it has as environment and the recipe reads what it needs. The recipe runs in the foreground and does not self-daemonize — this process supplies the backgrounding and pid tracking, so only one thing ever decides when the app dies. A copy whose `justfile` has no `serve` recipe is reported as such (`{:error, :no_start_recipe}`), never silently left down.

Idle timeout follows `CodeMySpec.Intake.Conversation`'s shape: every reply re-arms a 30-minute timeout via the fourth element of the reply tuple, `restart: :temporary` because an idle stop is a normal exit, not a crash to recover from. Requests count as activity by way of the app's own log file's mtime, checked on a periodic self-tick, rather than a request-counting reverse proxy — simpler and protocol-agnostic (a proxy would need explicit handling for a LiveView's websocket upgrade; a log file's mtime needs none), at the cost of also counting non-request activity such as a migration or a boot, which only ever delays a stop nobody needed yet and never causes a wrong one.

Verified live against this project's own working copy before being trusted further: a real `just serve` came up on an allocated port and served this commit's actual homepage, then `stop_app/1` took it down and the port stopped answering.

## Type

module

## Dependencies

- CodeMySpec.Environments
