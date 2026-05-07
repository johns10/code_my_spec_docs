# GitHub.Gitignore

Provides API endpoints related to gitignore

## get_all_templates(opts \\ [])

Get all gitignore templates

List all templates available to pass as an option when [creating a repository](https://docs.github.com/rest/repos/repos#create-a-repository-for-the-authenticated-user).

## Resources

  * [API method documentation](https://docs.github.com/rest/gitignore/gitignore#get-all-gitignore-templates)

## get_template(name, opts \\ [])

Get a gitignore template

Get the content of a gitignore template.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw .gitignore contents.

## Resources

  * [API method documentation](https://docs.github.com/rest/gitignore/gitignore#get-a-gitignore-template)