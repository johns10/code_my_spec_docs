# Earmark.Cli.Implementation

Functional (with the exception of reading input files with `Earmark.File`) interface to the CLI
returning the device and the string to be output.

## run(argv)

allows functional access to the CLI API, does everything `Earmark.Cli.main` does without outputting the result

Returns a tuple of the device to write to (`:stdio|:stderr`) and the content to be written

Example: Bad file

iex(0)> run(["no-such--file--ayK7k"])
{:stderr, "Cannot open no-such--file--ayK7k, reason: enoent"}

Example: Good file

iex(1)> {:stdio, html} = run(["test/fixtures/short1.md"])
...(1)> html
"<h1>\nHeadline1</h1>\n<hr class=\"thin\">\n<h2>\nHeadline2</h2>\n"

Example: Using EEx

iex(2)> {:stdio, html} = run(["--eex", "--gfm", "--code-class-prefix", "alpha", "--timeout", "12000", "test/fixtures/short2.md.eex"])
...(2)> html
"<h1>\nShort2</h1>\n<p>\n<em>Short3</em></p>\n<!-- SPDX-License-Identifier: Apache-2.0 -->\n"


Example: Using an EEx template first

iex(3)> run(["--template", "test/fixtures/eex_first.html.eex"])
{:stdio, "<html>\n  <h1>\nShort2</h1>\n<p>\n<em>Short3</em></p>\n<!-- SPDX-License-Identifier: Apache-2.0 -->\n\n</html>\n"}