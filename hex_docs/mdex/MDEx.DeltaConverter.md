# MDEx.DeltaConverter



## convert/2

Convert an MDEx document to Quill Delta format.

## Examples

    iex> doc = %MDEx.Document{nodes: [%MDEx.Text{literal: "Hello"}]}
    iex> MDEx.DeltaConverter.convert(doc, %{})
    {:ok, [%{"insert" => "Hello"}]}