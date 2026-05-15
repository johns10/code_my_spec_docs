defmodule CodeMySpec.Check.Warning.CodeMySpecSpexDenies do
  use Credo.Check,
    id: "CODEMY0001",
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Project-specific whole-module denies for BDD spec files
      (`_spex.exs`). Complements the framework-level function denies
      in `CodeMySpec.Check.Warning.SpexDeniedCalls`.

      The `CodeMySpecSpex` boundary only deps on `CodeMySpec.Environments`,
      `CodeMySpec.McpServers`, `CodeMySpecSpex.Fixtures`, `CodeMySpecWeb`,
      and `CodeMySpecLocalWeb`. The Boundary compiler catches alias-form
      violations; this Credo check is a second net for fully-qualified
      calls like `CodeMySpec.Repo.all(...)` that slip through when an
      agent writes the call inline without an alias.

      Stdlib whole-module denies:

      - `File`, `:file` — the spec suite runs against an in-memory filesystem.
        Real file I/O reaches past the `CodeMySpec.Environments` abstraction
        and lets a scenario "succeed" for the wrong reason.
      - `Port` — ports are for talking to external programs; use cassettes
        for CLI-driven pipeline steps instead.

      Project context denies (from `.code_my_spec/architecture/proposal.md`):

      - `CodeMySpec.Repo` — direct DB reads bypass the public surface.
      - All `CodeMySpec` contexts that the spec boundary does NOT dep on.

      Legal surfaces for a spec:

      - Drive via `CodeMySpecWeb` / `CodeMySpecLocalWeb` (Phoenix.ConnTest,
        Phoenix.LiveViewTest) or `CodeMySpec.McpServers.<Server>.Tools.*`.
      - Set up via `CodeMySpecSpex.Fixtures` (the curated bridge) or by
        driving the UI / hook surface that produces the state.
      - Observe via rendered HTML, HTTP response bodies, MCP tool
        responses, or `CodeMySpec.Environments.read_file/2`.

      If a spec needs state that none of the above can produce, add a
      narrow function to `CodeMySpecSpex.Fixtures` — don't reach for the
      context directly.
      """
    ]

  @denied_whole_modules [
    File,
    Port,
    CodeMySpec.Repo,
    CodeMySpec.Accounts,
    CodeMySpec.AgentTasks,
    CodeMySpec.Configurations,
    CodeMySpec.Content,
    CodeMySpec.ContentAdmin,
    CodeMySpec.Documents,
    CodeMySpec.Files,
    CodeMySpec.Git,
    CodeMySpec.Issues,
    CodeMySpec.Personas,
    CodeMySpec.Projects,
    CodeMySpec.Quality,
    CodeMySpec.Requirements,
    CodeMySpec.Sessions,
    CodeMySpec.StaticAnalysis,
    CodeMySpec.Stories,
    CodeMySpec.Tags,
    CodeMySpec.Tests,
    CodeMySpec.Users,
    CodeMySpec.Validation
  ]

  @denied_whole_erlang_modules [:file]

  @doc false
  @impl true
  def run(%SourceFile{filename: filename} = source_file, params) do
    if String.ends_with?(filename, "_spex.exs") do
      ctx = %{issue_meta: Context.build(source_file, params, __MODULE__), issues: []}
      Credo.Code.prewalk(source_file, &traverse/2, ctx).issues
    else
      []
    end
  end

  # Aliased Elixir modules — File.*, Port.*, CodeMySpec.<Context>.*,
  # CodeMySpec.<Context>.<Submodule>.* (deep paths still resolve to the
  # context root via the first two segments).
  defp traverse(
         {{:., _, [{:__aliases__, meta, module_parts}, _fun]}, _, _args} = ast,
         ctx
       )
       when is_list(module_parts) do
    full = Module.concat(module_parts)

    cond do
      full in @denied_whole_modules ->
        {ast, add_issue(ctx, meta, inspect(full))}

      length(module_parts) > 2 and
          Module.concat(Enum.take(module_parts, 2)) in @denied_whole_modules ->
        {ast, add_issue(ctx, meta, inspect(full))}

      true ->
        {ast, ctx}
    end
  end

  # Erlang modules — :file.*, etc.
  defp traverse({{:., _, [erl_mod, fun]}, meta, _args} = ast, ctx)
       when is_atom(erl_mod) do
    if erl_mod in @denied_whole_erlang_modules do
      {ast, add_issue(ctx, meta, "#{inspect(erl_mod)}.#{fun}")}
    else
      {ast, ctx}
    end
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp add_issue(ctx, meta, trigger) do
    issue =
      format_issue(
        ctx.issue_meta,
        message:
          "Call into `#{trigger}` is denied in _spex.exs files. Specs drive the " <>
            "public LiveView / hook / MCP surface and observe through rendered output. " <>
            "If you need state setup the surface can't produce, extend " <>
            "`CodeMySpecSpex.Fixtures`. See .code_my_spec/knowledge/bdd/spex/boundaries.md.",
        trigger: trigger,
        line_no: meta[:line],
        column: meta[:column]
      )

    %{ctx | issues: [issue | ctx.issues]}
  end
end
