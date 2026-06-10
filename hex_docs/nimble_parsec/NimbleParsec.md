# NimbleParsec



## defparsec/3

Defines a parser (and a combinator) with the given `name` and `opts`.

The parser is a function that receives two arguments, the binary
to be parsed and a set of options. You can consult the documentation
of the generated parser function for more information.

This function will also define a combinator that can be used as
`parsec(name)` when building other parsers. See `parsec/2` for
more information on invoking compiled combinators.

## Beware!

`defparsec/3` is executed during compilation. This means you can't
invoke a function defined in the same module. The following will error
because the `date` function has not yet been defined:

    defmodule MyParser do
      import NimbleParsec

      def date do
        integer(4)
        |> ignore(string("-"))
        |> integer(2)
        |> ignore(string("-"))
        |> integer(2)
      end

      defparsec :date, date()
    end

This can be solved in different ways. You may simply
compose a long parser using variables. For example:

    defmodule MyParser do
      import NimbleParsec

      date =
        integer(4)
        |> ignore(string("-"))
        |> integer(2)
        |> ignore(string("-"))
        |> integer(2)

      defparsec :date, date
    end

Alternatively, you may define a `Helpers` module with many
convenience combinators, and then invoke them in your parser
module:

    defmodule MyParser.Helpers do
      import NimbleParsec

      def date do
        integer(4)
        |> ignore(string("-"))
        |> integer(2)
        |> ignore(string("-"))
        |> integer(2)
      end
    end

    defmodule MyParser do
      import NimbleParsec
      import MyParser.Helpers

      defparsec :date, date()
    end

The approach of using helper modules is the favorite way
of composing parsers in `NimbleParsec`.

## Options

  * `:inline` - when true, inlines clauses that work as redirection for
    other clauses. Settings this may improve runtime performance at the
    cost of increased compilation time and bytecode size

  * `:debug` - when true, writes generated clauses to `:stderr` for debugging

  * `:export_combinator` - make the underlying combinator function public
    so it can be used as part of `parsec/1` from other modules

  * `:export_metadata` - export metadata necessary to use this parser
    combinator to generate inputs

## defparsecp/3

Defines a private parser (and a combinator) with the given `name` and `opts`.

The same as `defparsec/3` but the parsing function is private.

## defcombinator/3

Defines a combinator with the given `name` and `opts`.

It is similar to `defparsec/3` except it does not define
an entry-point parsing function, just the combinator function
to be used with `parsec/2`.

## defcombinatorp/3

Defines a combinator with the given `name` and `opts`.

It is similar to `defparsecp/3` except it does not define
an entry-point parsing function, just the combinator function
to be used with `parsec/2`.

## parsec/2

Invokes an already compiled combinator with name `name` in the
same module.

Every parser defined via `defparsec/3` or `defparsecp/3` can be
used as combinator. However, the `defparsec/3` and `defparsecp/3`
functions also define an entry-point parsing function, as implied
by their names. If you want to define a combinator with the sole
purpose of using it in combinator, use `defcombinatorp/3` instead.

## Use cases

`parsec/2` is useful to implement recursive definitions.

Note, while `parsec/2` can be used to compose smaller combinators,
the preferred mechanism for doing composition is via regular functions
and not via `parsec/2`. Let's see a practical example. Imagine
that you have this module:

    defmodule MyParser do
      import NimbleParsec

      date =
        integer(4)
        |> ignore(string("-"))
        |> integer(2)
        |> ignore(string("-"))
        |> integer(2)

      time =
        integer(2)
        |> ignore(string(":"))
        |> integer(2)
        |> ignore(string(":"))
        |> integer(2)
        |> optional(string("Z"))

      defparsec :datetime, date |> ignore(string("T")) |> concat(time), debug: true
    end

Now imagine that you want to break `date` and `time` apart
into helper functions, as you use them in other occasions.
Generally speaking, you should **NOT** do this:

    defmodule MyParser do
      import NimbleParsec

      defcombinatorp :date,
                     integer(4)
                     |> ignore(string("-"))
                     |> integer(2)
                     |> ignore(string("-"))
                     |> integer(2)

      defcombinatorp :time,
                     integer(2)
                     |> ignore(string(":"))
                     |> integer(2)
                     |> ignore(string(":"))
                     |> integer(2)
                     |> optional(string("Z"))

      defparsec :datetime,
                parsec(:date) |> ignore(string("T")) |> concat(parsec(:time))
    end

The reason why the above is not recommended is because each
`parsec/2` combinator ends-up adding a stacktrace entry during
parsing, which affects the ability of `NimbleParsec` to optimize
code. If the goal is to compose combinators, you can do so
with modules and functions:

    defmodule MyParser.Helpers do
      import NimbleParsec

      def date do
        integer(4)
        |> ignore(string("-"))
        |> integer(2)
        |> ignore(string("-"))
        |> integer(2)
      end

      def time do
        integer(2)
        |> ignore(string(":"))
        |> integer(2)
        |> ignore(string(":"))
        |> integer(2)
        |> optional(string("Z"))
      end
    end

    defmodule MyParser do
      import NimbleParsec
      import MyParser.Helpers

      defparsec :datetime,
                date() |> ignore(string("T")) |> concat(time())
    end

The implementation above will be able to compile to the most
efficient format as possible without forcing new stacktrace
entries.

The only situation where you should use `parsec/2` for composition
is when a large parser is used over and over again in a way
compilation times are high. In this sense, you can use `parsec/2`
to improve compilation time at the cost of runtime performance.
By using `parsec/2`, the tree size built at compile time will be
reduced although runtime performance is degraded as `parsec`
introduces a stacktrace entry.

## Remote combinators

You can also reference combinators in other modules by passing
a tuple with the module name and a function to `parsec/2` as follows:

    defmodule RemoteCombinatorModule do
      defcombinator :upcase_unicode, utf8_char([...long, list, of, unicode, chars...])
    end

    defmodule LocalModule do
      # Parsec that depends on `:upcase_A`
      defparsec :parsec_name,
                ...
                |> ascii_char([?a..?Z])
                |> parsec({RemoteCombinatorModule, :upcase_unicode})
    end

Remote combinators are useful when breaking the compilation of
large modules apart in order to use Elixir's ability to compile
modules in parallel.

## Examples

A good example of using `parsec` is with recursive parsers.
A limited but recursive XML parser could be written as follows:

    defmodule SimpleXML do
      import NimbleParsec

      tag = ascii_string([?a..?z, ?A..?Z], min: 1)
      text = ascii_string([not: ?<], min: 1)

      opening_tag =
        ignore(string("<"))
        |> concat(tag)
        |> ignore(string(">"))

      closing_tag =
        ignore(string("</"))
        |> concat(tag)
        |> ignore(string(">"))

      defparsec :xml,
                opening_tag
                |> repeat(lookahead_not(string("</")) |> choice([parsec(:xml), text]))
                |> concat(closing_tag)
                |> wrap()
    end

    SimpleXML.xml("<foo>bar</foo>")
    #=> {:ok, [["foo", "bar", "foo"]], "", %{}, {1, 0}, 14}

In the example above, `defparsec/3` has defined the entry-point
parsing function as well as a combinator which we have invoked
with `parsec(:xml)`.

In many cases, however, you want to define recursive combinators
without the entry-point parsing function. We can do this by
replacing `defparsec/3` by `defcombinatorp`:

    defcombinatorp :xml,
                   opening_tag
                   |> repeat(lookahead_not(string("</")) |> choice([parsec(:xml), text]))
                   |> concat(closing_tag)
                   |> wrap()

When using `defcombinatorp`, you can no longer invoke
`SimpleXML.xml(xml)` as there is no associated parsing function.
You can only access the combinator above via `parsec/2`.

## duplicate/3

Duplicates the combinator `to_duplicate` `n` times.

## byte_offset/2

Puts the result of the given combinator as the first element
of a tuple with the `byte_offset` as second element.

`byte_offset` is a non-negative integer.

## line/2

Puts the result of the given combinator as the first element
of a tuple with the `line` as second element.

`line` is a tuple where the first element is the current line
and the second element is the byte offset immediately after
the newline.

## pre_traverse/3

The same as `post_traverse/3` but receives the line and offset
from before the wrapped combinators.

`post_traverse/3` should be preferred as it keeps less stack
information. Use `pre_traverse/3` only if you have to access
the line and offset from before the given combinators.

## quoted_post_traverse/3

Invokes `call` to emit the AST that post traverses the `to_post_traverse`
combinator results.

This is similar to `post_traverse/3`. In `post_traverse/3`, `call` is
invoked to process the combinator results. In here, it is invoked to
emit AST that in its turn will process the combinator results.
The invoked function must return the same types as `post_traverse/3`.

`call` is a `{module, function, args}` and it will receive 5
additional arguments. The AST representation of the rest of the
parsed binary, the parser results, context, line and offset will
be prepended to `args`. `call` is invoked at compile time and is
useful in combinators that avoid injecting runtime dependencies.

The line and offset will represent the location after the combinators.
To retrieve the position before the combinators, use `quoted_pre_traverse/3`.

This function must be used only when you want to emit code that
has no runtime dependencies in other modules. In most cases,
using `post_traverse/3` is better, since it doesn't work on ASTs
and instead works at runtime.

## quoted_pre_traverse/3

The same as `quoted_post_traverse/3` but receives the line and offset
from before the wrapped combinators.

`quoted_post_traverse/3` should be preferred as it keeps less stack
information. Use `quoted_pre_traverse/3` only if you have to access
the line and offset from before the given combinators.

## wrap/2

Wraps the results of the given combinator in `to_wrap` in a list.

## tag/3

Tags the result of the given combinator in `to_tag` in a tuple with
`tag` as first element.

## Examples

    defmodule MyParser do
      import NimbleParsec

      defparsec :integer, integer(min: 1) |> tag(:integer)
    end

    MyParser.integer("1234")
    #=> {:ok, [integer: [1234]], "", %{}, {1, 0}, 4}

Notice, however, that the integer result is wrapped in a list, because
the parser is expected to emit multiple tokens. When you are sure that
only a single token is emitted, you should use `unwrap_and_tag/3`.

## unwrap_and_tag/3

Unwraps and tags the result of the given combinator in `to_tag` in a tuple with
`tag` as first element.

## Examples

    defmodule MyParser do
      import NimbleParsec

      defparsec :integer, integer(min: 1) |> unwrap_and_tag(:integer)
    end

    MyParser.integer("1234")
    #=> {:ok, [integer: 1234], "", %{}, {1, 0}, 4}


In case the combinator emits greater than one token, an error will be raised.
See `tag/3` for more information.

## debug/2

Inspects the combinator state given to `to_debug` with the given `opts`.

## ignore/2

Ignores the output of combinator given in `to_ignore`.

## Examples

    defmodule MyParser do
      import NimbleParsec

      defparsec :ignorable, string("T") |> ignore() |> integer(2)
    end

    MyParser.ignorable("T12")
    #=> {:ok, [12], "", %{}, {1, 0}, 2}

## replace/3

Replaces the output of combinator given in `to_replace` by a single value.

The `value` will be injected at the compile site
and therefore must be escapable via `Macro.escape/1`.

## Examples

    defmodule MyParser do
      import NimbleParsec

      defparsec :replaceable, string("T") |> replace("OTHER") |> integer(2, 2)
    end

    MyParser.replaceable("T12")
    #=> {:ok, ["OTHER", 12], "", %{}, {1, 0}, 2}

## repeat/3

Allows the combinator given on `to_repeat` to appear zero or more times.

Beware! Since `repeat/2` allows zero entries, it cannot be used inside
`choice/2`, because it will always succeed and may lead to unused function
warnings since any further choice won't ever be attempted. For example,
because `repeat/2` always succeeds, the `string/2` combinator below it
won't ever run:

    choice([
      repeat(ascii_char([?a..?z])),
      string("OK")
    ])

Instead of `repeat/2`, you may want to use `times/3` with the flags `:min`
and `:max`.

Also beware! If you attempt to repeat a combinator that can match nothing,
like `optional/2`, `repeat/2` will not terminate. For example, consider
this combinator:

     repeat(optional(utf8_char([?a])))

This combinator will never terminate because `repeat/2` chooses the empty
option of `optional/2` every time. Since the goal of the parser above is
to parse 0 or more `?a` characters, it can be represented by
`repeat(utf8_char([?a]))`, because `repeat/2` allows 0 or more matches.

## Examples

    defmodule MyParser do
      import NimbleParsec

      defparsec :repeat_lower, repeat(ascii_char([?a..?z]))
    end

    MyParser.repeat_lower("abcd")
    #=> {:ok, [?a, ?b, ?c, ?d], "", %{}, {1, 0}, 4}

    MyParser.repeat_lower("1234")
    #=> {:ok, [], "1234", %{}, {1, 0}, 0}

## eventually/2

Marks the given combinator should appear eventually.

Any other data before the combinator appears is discarded.
If the combinator never appears, then it is an error.

**Note:** this can be potentially a very expensive operation
as it executes the given combinator byte by byte until finding
an eventual match or ultimately failing. For example, if you
are looking for an integer, it is preferable to discard
everything that is not an integer

    ignore(ascii_string([not: ?0..?9]))

rather than eventually look for an integer

    eventually(ascii_string([?0..?9]))

## Examples

    defmodule MyParser do
      import NimbleParsec

      hour = integer(min: 1, max: 2)
      defparsec :extract_hour, eventually(hour)
    end

    MyParser.extract_hour("let's meet at 12?")
    #=> {:ok, [12], "?", %{}, {1, 0}, 16}

## quoted_repeat_while/4

Invokes `while` to emit the AST that will repeat `to_repeat`
while the AST code returns `{:cont, context}`.

In case repetition should stop, `while` must return `{:halt, context}`.

`while` is a `{module, function, args}` and it will receive 4
additional arguments. The AST representations of the binary to be
parsed, context, line and offset will be prepended to `args`. `while`
is invoked at compile time and is useful in combinators that avoid
injecting runtime dependencies.

## times/3

Allow the combinator given on `to_repeat` to appear at least, at most
or exactly a given amount of times.

## Examples

    defmodule MyParser do
      import NimbleParsec

      defparsec :minimum_lower, times(ascii_char([?a..?z]), min: 2)
    end

    MyParser.minimum_lower("abcd")
    #=> {:ok, [?a, ?b, ?c, ?d], "", %{}, {1, 0}, 4}

    MyParser.minimum_lower("ab12")
    #=> {:ok, [?a, ?b], "12", %{}, {1, 0}, 2}

    MyParser.minimum_lower("a123")
    #=> {:ok, [], "a123", %{}, {1, 0}, 0}

## choice/3

Chooses one of the given combinators.

Expects at least two choices.

## Beware! Char combinators

Note both `utf8_char/2` and `ascii_char/2` allow multiple ranges to
be given. Therefore, instead this:

    choice([
      ascii_char([?a..?z]),
      ascii_char([?A..?Z]),
    ])

One should simply prefer:

    ascii_char([?a..?z, ?A..?Z])

As the latter is compiled more efficiently by `NimbleParsec`.

## Beware! Always successful combinators

If a combinator that always succeeds is given as a choice, that choice
will always succeed which may lead to unused function warnings since
any further choice won't ever be attempted. For example, because `repeat/2`
always succeeds, the `string/2` combinator below it won't ever run:

    choice([
      repeat(ascii_char([?0..?9])),
      string("OK")
    ])

Instead of `repeat/2`, you may want to use `times/3` with the flags `:min`
and `:max`.

## Beware! Overlapping choices

In case choices overlap, there is no guarantee which error will be the one
effectively returned. For example, imagine this choice:

    choice([
      string("<abc>foo</abc>"),
      string("<abc>")
    ]

Since both choices can be activated for an input starting with "abc",
NimbleParsec guarantees it will return the error from one of them, but
not which.

## optional/2

Marks the given combinator as `optional`.

It is equivalent to `choice([combinator, empty()])`.

## bytes/2

Defines a combinator to consume the next `n` bytes from the input.

## Examples

      defmodule MyParser do
        import NimbleParsec

        defparsec :three_bytes, bytes(3)
      end

      MyParser.three_bytes("abc")
      #=> {:ok, ["abc"], "", %{}, {1, 0}, 3}

      MyParser.three_bytes("ab")
      #=> {:error, "expected 3 bytes", "ab", %{}, {1, 0}, 0}