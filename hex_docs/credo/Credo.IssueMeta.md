# Credo.IssueMeta

IssueMeta provides helper functions for meta information which a check wants
to pass to the `issue_for(...)` function, i.e. the current SourceFile and check
params (by default).

## for(source_file, check_params)

Returns an issue meta tuple for the given `source_file` and `check_params`.

## params(issue_meta)

Returns the check params for the given `issue_meta`.

## source_file(issue_meta)

Returns the source file for the given `issue_meta`.