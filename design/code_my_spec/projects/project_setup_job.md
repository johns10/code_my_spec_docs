# ProjectSetupJob

## Purpose
Oban worker that handles project setup as a background job, delegating business logic to ProjectSetup module while managing job-specific concerns.

## Job Configuration
```elixir
defmodule CodeMySpec.Projects.ProjectSetupJob do
  use Oban.Worker, 
    queue: :project_setup,
    max_attempts: 3,
    priority: 1,
    unique: [period: 300, states: [:available, :scheduled, :executing]]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"project_id" => project_id}}) do
    # Implementation delegates to ProjectSetup module
  end
end
```

## Job Arguments
The job accepts a single argument map containing:
- **project_id**: UUID string identifying the project to set up

## Job Execution Flow
1. **Load Project**: Retrieve project record from database using the provided project_id
2. **Validate Project**: Ensure project exists and is in appropriate state for setup
3. **Setup Callback**: Define callback function to handle Oban-specific status updates
4. **Delegate to Business Logic**: Call `ProjectSetup.setup_project/2` with project and callback
5. **Handle Results**: Process success or failure responses from setup module

## Job-Specific Concerns

### Retry Logic
The job is configured with `max_attempts: 3` to automatically retry failed setups. Oban handles the retry scheduling with exponential backoff, so transient failures like network issues or temporary resource constraints are handled gracefully.

### Uniqueness
The job uses Oban's uniqueness feature to prevent duplicate setup jobs for the same project. The 5-minute uniqueness window ensures that if a job fails and is retried, it won't conflict with manual retry attempts.

### Queue Management
Project setup jobs run in a dedicated `:project_setup` queue, allowing for separate worker scaling and priority management. This isolates long-running setup operations from other background jobs.

### Status Callback
The job provides a callback function to `ProjectSetup.setup_project/2` that handles job-specific status updates. This callback can:
- Update job metadata with current status
- Handle job cancellation requests
- Log job progress for monitoring
- Manage job-specific error states

## Error Handling
The job handles different types of errors appropriately:

### Business Logic Errors
When `ProjectSetup.setup_project/2` returns an error tuple, the job marks itself as failed and records the error details. These errors typically don't benefit from retries since they represent setup failures that require manual intervention.

### Infrastructure Errors
Database connection failures, network issues, or other infrastructure problems are allowed to bubble up and trigger Oban's retry logic. These transient errors often resolve on subsequent attempts.

### Job-Specific Errors
If the project doesn't exist or is in an invalid state for setup, the job marks itself as permanently failed to avoid unnecessary retries.

## Job Lifecycle
1. **Enqueue**: Job is created and queued when `Projects.setup_project/1` is called
2. **Execute**: Oban worker picks up the job and calls `perform/1`
3. **Delegate**: Job loads project and delegates to `ProjectSetup.setup_project/2`
4. **Monitor**: Callback function handles status updates during setup
5. **Complete**: Job marks itself as successful or failed based on setup results
6. **Retry**: If failed due to transient issues, Oban automatically retries

## Usage Patterns
The job is primarily enqueued by the Projects context when `setup_project/1` is called. It can also be manually enqueued for retry operations or administrative tasks.

```elixir
# Enqueue job for project setup
%{project_id: project.id}
|> ProjectSetupJob.new()
|> Oban.insert()

# Job is automatically executed by Oban workers
```

## Monitoring and Observability
The job integrates with Oban's built-in monitoring and provides:
- Job execution metrics
- Progress tracking through status callbacks
- Error logging and reporting
- Retry attempt tracking
- Queue performance monitoring

This allows administrators to monitor project setup health and identify issues that may require intervention.