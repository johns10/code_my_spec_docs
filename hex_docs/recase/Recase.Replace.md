# Recase.Replace

Helper module to pipe and replace values easily.

## replace(value, regex, new_value)

Replaces `value` if it matches `regex` with `new_value`.

Standard `Regex.replace/3` accepts `value` to replace
as the second argument. Which is not quite convenient to
use in pipes.

This function accepts `value` as the first argument and
then passes it to `Regex.replace/3` as the second one.