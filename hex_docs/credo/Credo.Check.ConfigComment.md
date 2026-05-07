# Credo.Check.ConfigComment

`ConfigComment` structs represent comments which control Credo's behaviour.

The following comments are supported:

    # credo:disable-for-this-file
    # credo:disable-for-next-line
    # credo:disable-for-previous-line
    # credo:disable-for-lines:<number>

## ignores_issue?(config_comment, issue)

Returns `true` if the given `issue` should be ignored based on the given `config_comment`

## new(instruction, param_string, line_no)

Returns a `ConfigComment` struct based on the given parameters.