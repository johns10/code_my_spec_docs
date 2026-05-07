# Oban.Engine

Defines an Engine for job orchestration.

Engines are responsible for all non-plugin database interaction, from inserting through
executing jobs.

Oban ships with three Engine implementations:

1. `Basic` — The default engine for development, production, and manual testing mode.
2. `Inline` — Designed specifically for testing, it executes jobs immediately, in-memory, as
   they are inserted.
3. `Lite` - The engine for running Oban using SQLite3.

> #### 🌟 SmartEngine {: .info}
>
> The Basic engine lacks advanced functionality such as global limits, rate limits, and
> unique bulk insert. For those features and more, see the [`Smart` engine in Oban
> Pro](https://oban.pro/docs/pro/Oban.Pro.Engines.Smart.html).

## cancel_all_jobs/2

Mark many `executing`, `available`, `scheduled` or `retryable` job as `cancelled` to prevent them
from running.

## cancel_job/2

Mark an `executing`, `available`, `scheduled` or `retryable` job as `cancelled` to prevent it
from running.

## check_available/1

Check for a list of queues with available jobs.

## check_meta/3

Format engine meta in a digestible format for queue inspection.

## complete_job/2

Record that a job completed successfully.

## delete_all_jobs/2

Delete many jobs that aren't currently `executing`.

## delete_job/2

Delete a job that isn't currently `executing`.

## discard_job/2

Transition a job to `discarded` and record an optional reason that it shouldn't be ran again.

## error_job/3

Record an executing job's errors and either retry or discard it, depending on whether it has
exhausted its available attempts.

## fetch_jobs/3

Fetch available jobs for the given queue, up to configured limits.

## init/2

Initialize metadata for a queue engine.

Queue metadata is used to identify and track subsequent actions such as fetching or staging
jobs.

## insert_all_jobs/3

Insert multiple jobs into the database.

## insert_job/3

Insert a job into the database.

## prune_jobs/3

Delete completed, cancelled and discarded jobs.

## put_meta/4

Store the given key/value pair in the engine meta.

## refresh/2

Refresh a queue to indicate that it is still alive.

## rescue_jobs/3

Transition stuck jobs to `available` or `discarded` state based on attempts.

## retry_all_jobs/2

Mark many jobs as `available`, adding attempts if already maxed out. Any jobs currently
`available`, `executing` or `scheduled` should be ignored.

## retry_job/2

Mark a job as `available`, adding attempts if already maxed out. If the job is currently
`available`, `executing` or `scheduled` it should be ignored.

## shutdown/2

Prepare a queue engine for shutdown.

The queue process is expected to stop processing new jobs after shutdown starts, though it may
continue executing jobs that are already running.

## snooze_job/3

Reschedule an executing job to run some number of seconds in the future.

## stage_jobs/3

Transition scheduled or retryable jobs to available prior to execution.