# MDEx.DeltaConverter



## convert(document, options)

Convert an MDEx document to Quill Delta format.

## Examples

    iex> doc = %MDEx.Document{nodes: [%MDEx.Text{literal: "Hello"}]}
    iex> MDEx.DeltaConverter.convert(doc, %{})
    {:ok, [%{"insert" => "Hello"}]}

## delta_op/0

Delta operation map

## delta/0

Complete Delta document

## options/0

Conversion options