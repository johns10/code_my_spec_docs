# DirWalker



## next/2

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

## stop/1

Stops the DirWalker

## stream/2

Implement a stream interface that will return a lazy enumerable.

## Example

  iex> first_file = DirWalker.stream("/") |> Enum.take(1)