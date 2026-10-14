defmodule CodeMySpec.Check.Readability.NoHistoryInComments do
  use Credo.Check,
    id: "CODEMY0002",
    base_priority: :low,
    category: :readability,
    param_defaults: [files_list: ".code_my_spec/credo_checks/local/curated_comments.txt"],
    explanations: [
      check: """
      A commit hash or a date in a comment or docstring is history, and git
      already keeps history. In code it goes stale silently: the comment keeps
      describing a mechanism after the code that had it is gone.

      Keep the current contract and a short "why" in the code. Put design
      rationale and the lessons from incidents in the project knowledge base
      (`.code_my_spec/knowledge/`), and leave a pointer to it here if the spot
      needs one.

      A ratchet: `files_list` names a file listing the files whose comments have
      been curated into the knowledge base, so history stays out of them; it
      widens as each area is done. Advisory (low priority) while its noise is measured.
      """
    ]

  @hash ~r/\b(?=[0-9a-f]*[0-9])(?=[0-9a-f]*[a-f])[0-9a-f]{7,12}\b/
  @date ~r/\b20\d\d-\d\d-\d\d\b/
  @doc_open ~r/@(moduledoc|doc|typedoc)\s+(~[sS])?"""/

  @impl true
  def run(%SourceFile{} = source_file, params) do
    if source_file.filename in curated(Params.get(params, :files_list, __MODULE__)) do
      issue_meta = IssueMeta.for(source_file, params)

      source_file
      |> SourceFile.lines()
      |> Enum.reduce({:code, []}, &scan(&1, &2, issue_meta))
      |> elem(1)
      |> Enum.reverse()
    else
      []
    end
  end

  defp curated(list_path) do
    case File.read(list_path) do
      {:ok, content} ->
        content |> String.split("\n", trim: true) |> Enum.reject(&String.starts_with?(&1, "#"))

      {:error, _} ->
        []
    end
  end

  # State: `:code`, `:doc` (inside a docstring, scanned) or `:string` (inside
  # any other heredoc — a script's `#` lines are not comments, so skipped).
  defp scan({line_no, line}, {state, issues}, issue_meta) do
    trimmed = String.trim(line)
    closes? = trimmed == ~s(""") or String.starts_with?(trimmed, ~s(""") <> ")")

    cond do
      state != :code and closes? -> {:code, issues}
      state == :doc -> {:doc, flag(line, line_no, issues, issue_meta)}
      state == :string -> {:string, issues}
      Regex.match?(@doc_open, line) -> {:doc, issues}
      String.ends_with?(trimmed, ~s(""")) -> {:string, issues}
      String.starts_with?(trimmed, "#") -> {:code, flag(line, line_no, issues, issue_meta)}
      true -> {:code, issues}
    end
  end

  defp flag(line, line_no, issues, issue_meta) do
    if example?(line), do: issues, else: flag_history(line, line_no, issues, issue_meta)
  end

  # Doctest lines and date sigils are code; `ed25519` is a key type, not a hash.
  defp example?(line) do
    trimmed = String.trim(line)

    String.starts_with?(trimmed, ["iex>", "...>"]) or line =~ ~r/~[UDN]\[/ or
      (line =~ ~r/ed25519/ and is_nil(Regex.run(@hash, String.replace(line, "ed25519", ""))) and
         is_nil(Regex.run(@date, line)))
  end

  defp flag_history(line, line_no, issues, issue_meta) do
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
