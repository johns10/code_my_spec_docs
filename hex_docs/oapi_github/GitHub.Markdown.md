# GitHub.Markdown

Provides API endpoints related to markdown

## render(body, opts \\ [])

Render a Markdown document

## Resources

  * [API method documentation](https://docs.github.com/rest/markdown/markdown#render-a-markdown-document)

## render_raw(body, opts \\ [])

Render a Markdown document in raw mode

You must send Markdown as plain text (using a `Content-Type` header of `text/plain` or `text/x-markdown`) to this endpoint, rather than using JSON format. In raw mode, [GitHub Flavored Markdown](https://github.github.com/gfm/) is not supported and Markdown will be rendered in plain format like a README.md file. Markdown content must be 400 KB or less.

## Resources

  * [API method documentation](https://docs.github.com/rest/markdown/markdown#render-a-markdown-document-in-raw-mode)