# Mix.Ecto

Conveniences for writing Ecto related Mix tasks.

## ensure_implements(module, behaviour, message)

Returns `true` if module implements behaviour.

## ensure_repo(repo, args)

Ensures the given module is an Ecto.Repo.

## no_umbrella!(task)

Gets a path relative to the application path.

Raises on umbrella application.

## open?(file, line \\ 1)

Asks if the user wants to open a file based on ECTO_EDITOR.

By default, it attempts to open the file and line using the
`file:line` notation. For example, if your editor is called
`subl`, it will open the file as:

    subl path/to/file:line

It is important that you choose an editor command that does
not block nor that attempts to run an editor directly in the
terminal. Command-line based editors likely need extra
configuration so they open up the given file and line in a
separate window.

Custom editors are supported by using the `__FILE__` and
`__LINE__` notations, for example:

    ECTO_EDITOR="my_editor +__LINE__ __FILE__"

and Elixir will properly interpolate values.

## parse_repo(args)

Parses the repository option from the given command line args list.

If no repo option is given, it is retrieved from the application environment.