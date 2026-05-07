# Credo.Execution.Task

A Task is a step in a pipeline, which is given an `Credo.Execution` struct and must return one as well.

Tasks in a pipeline are only called if they are not "halted" (see `Credo.Execution.halt/2`).

It implements a `call/1` or `call/2` callback, which is called with the `Credo.Execution` struct
as first parameter (and the Task's options as the second in case of `call/2`).

## call/1

Is called by the pipeline and contains the Task's actual code.

    defmodule FooTask do
      use Credo.Execution.Task

      def call(exec) do
        IO.inspect(exec)
      end
    end

The `call/1` functions receives an `exec` struct and must return a (modified) `Credo.Execution`.

## call/2

Works like `call/1`, but receives the options, which are optional when registering the Task, as second argument.

    defmodule FooTask do
      use Credo.Execution.Task

      def call(exec, opts) do
        IO.inspect(opts)

        exec
      end
    end

## error/1

Gets called if `call` holds the execution via `Credo.Execution.halt/1` or `Credo.Execution.halt/2`.

## error/2

Works like `error/1`, but receives the options, which were given during pipeline registration, as second argument.