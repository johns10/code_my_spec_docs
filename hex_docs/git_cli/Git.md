# Git



## clone/1

Clones the repository. The first argument can be `url` or `[url, path]`.
Returns `{:ok, repository}` on success and `{:error, reason}` on failure.

## clone!/1

Same as clone/1 but raise an exception on failure.

## init!/1

Run `git init` in the given directory
Returns `{:ok, repository}` on success and `{:error, reason}` on failure.

## new/1

Return a Git.Repository struct with the specified or defaulted path.
For use with an existing repo (when Git.init and Git.clone would not be appropriate).

## execute_command/4

Execute the git command in the given repository.