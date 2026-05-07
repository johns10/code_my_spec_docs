# Tesla.Multipart

Multipart functionality.

## Examples

```
mp =
  Multipart.new()
  |> Multipart.add_content_type_param("charset=utf-8")
  |> Multipart.add_field("field1", "foo")
  |> Multipart.add_field("field2", "bar",
    headers: [{"content-id", "1"}, {"content-type", "text/plain"}]
  )
  |> Multipart.add_file("test/tesla/multipart_test_file.sh")
  |> Multipart.add_file("test/tesla/multipart_test_file.sh", name: "foobar")
  |> Multipart.add_file_content("sample file content", "sample.txt")

response = client.post(url, mp)
```

## add_content_type_param(mp, param)

Add a parameter to the multipart content-type.

## add_field(mp, name, value, opts \\ [])

Add a field part.

## add_file(mp, path, opts \\ [])

Add a file part. The file will be streamed.

## Options

- `:name` - name of form param
- `:filename` - filename (defaults to path basename)
- `:headers` - additional headers
- `:detect_content_type` - auto-detect file content-type (defaults to false)

## add_file_content(mp, data, filename, opts \\ [])

Add a file part with value.

Same as `add_file/3` but the file content is read from `data` input argument.

## Options

- `:name` - name of form param
- `:headers` - additional headers

## new()

Create a new Multipart struct to be used for a request body.