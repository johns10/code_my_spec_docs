defmodule CodeMySpec.Check.Readability.NoHistoryInComments do
  use Credo.Check,
    id: "CODEMY0002",
    base_priority: :low,
    category: :readability,
    param_defaults: [
      files: [
        "lib/code_my_spec/requirements.ex",
        "lib/code_my_spec/requirements/graph_store.ex",
        "lib/code_my_spec/requirements/handlers.ex",
        "lib/code_my_spec/requirements/incremental_graph.ex",
        "lib/code_my_spec/requirements/requirement_graph.ex"
      ]
    ],
    explanations: [
      check: """
      A commit hash or a date in a comment or docstring is history, and git
      already keeps history. In code it goes stale silently: the comment keeps
      describing a mechanism after the code that had it is gone.

      Keep the current contract and a short "why" in the code. Put design
      rationale and the lessons from incidents in the project knowledge base
      (`.code_my_spec/knowledge/`), and leave a pointer to it here if the spot
      needs one.

      A ratchet: `files` lists the files whose comments have been curated
      into the knowledge base, so history stays out of them; it widens as each
      file is done. Advisory (low priority) while its noise is measured.
      """
    ]

  @hash ~r/\b(?=[0-9a-f]*[0-9])(?=[0-9a-f]*[a-f])[0-9a-f]{7,12}\b/
  @date ~r/\b20\d\d-\d\d-\d\d\b/
  @doc_open ~r/@(moduledoc|doc|typedoc)\s+(~[sS])?"""/

  @impl true
  def run(%SourceFile{} = source_file, params) do
    if checked?(source_file.filename, Params.get(params, :files, __MODULE__)) do
      issue_meta = IssueMeta.for(source_file, params)

      source_file
      |> SourceFile.lines()
      |> Enum.reduce({false, []}, &scan(&1, &2, issue_meta))
      |> elem(1)
      |> Enum.reverse()
    else
      []
    end
  end

  defp checked?(filename, prefixes), do: Enum.any?(prefixes, &String.starts_with?(filename, &1))

  defp scan({line_no, line}, {in_doc?, issues}, issue_meta) do
    trimmed = String.trim_leading(line)

    cond do
      in_doc? and String.starts_with?(trimmed, ~s(""")) -> {false, issues}
      in_doc? -> {true, flag(line, line_no, issues, issue_meta)}
      Regex.match?(@doc_open, line) -> {true, issues}
      String.starts_with?(trimmed, "#") -> {false, flag(line, line_no, issues, issue_meta)}
      true -> {false, issues}
    end
  end

  defp flag(line, line_no, issues, issue_meta) do
    case Regex.run(@hash, line) || Regex.run(@date, line) do
      [found | _] ->
        [
          format_issue(issue_meta,
            message: "History in a comment (#{found}): git keeps it; move any lesson to the knowledge base.",
            trigger: found,
            line_no: line_no
          )
          | issues
        ]

      nil ->
        issues
    end
  end
end
