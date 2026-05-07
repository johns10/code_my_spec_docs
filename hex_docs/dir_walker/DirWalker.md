# DirWalker

DirWalker
=========

DirWalker lazily traverses one or more directory trees, depth first,
returning successive file names.

Initialize the walker using

    {:ok, walker} = DirWalker.start_link(path, [, options ]) # or [path, path...]

Then return the next `n` path names using

    paths = DirWalker.next(walker [, n \\ 1])

Successive calls to `next` will return successive file names, until
all file names have been returned.

These methods have also been wrapped into a Stream resource.

    paths = DirWalker.stream(path [, options]) # or [path,path...]

By default DirWalker will follow any symlinks found. With the `include_stat`
option, it will instead simply return the `File.Stat` of the symlink
and it is up to the calling code to handle symlinks.

`options` is a map containing zero or more of:

* `include_stat: true`

  Return tuples containing both the file name and the `File.Stat`
  structure for each file. This does not incur a performance penalty
  but obviously can use more memory. When this option is specified,
  DirWalker will not follow symlinks.

* `include_dir_names: true`

  Include the names of directories that are traversed (normally just the names
  of regular files are returned). Note that the order is such that directory names
  will typically be returned after the names of files in those directories.

* `matching:` _regex_

  Only file names matching the regex will be returned. Does not affect
  directory traversals.

## child_spec(init_arg)

Returns a specification to start this module under a supervisor.

See `Supervisor`.

## next(iterator, n \\ 1)

Return the next _n_ files from the lists of files, recursing into
directories if necessary. Return `nil` when there are no files
to return. (If there are fewer than _n_ files remaining, just those
files are returned, and `nil` will be returned on the next call.

## Example

      iex> {:ok,d} = DirWalker.start_link "."
      {:ok, #PID<0.83.0>}
      iex> DirWalker.next(d)
      ["./.gitignore"]
      iex> DirWalker.next(d)
      ["./_build/dev/lib/dir_walter/.compile.elixir"]
      iex> DirWalker.next(d, 3)
      ["./_build/dev/lib/dir_walter/ebin/Elixir.DirWalker.beam",
       "./_build/dev/lib/dir_walter/ebin/dir_walter.app",
       "./_build/dev/lib/dir_walter/.compile.lock"]
      iex>

## stop(server)

Stops the DirWalker

## stream(path_list, opts \\ %{})

Implement a stream interface that will return a lazy enumerable.

## Example

  iex> first_file = DirWalker.stream("/") |> Enum.take(1)