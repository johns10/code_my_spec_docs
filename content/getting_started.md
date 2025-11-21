# Getting started with Code My Spec

This guide walks you through setting up a new project to work with CodeMySpec.

## Prerequisites

- Elixir ~> 1.18
- PostgreSQL
- Git
- Visual Studio Code

## Create Your Phoenix Project

```bash
# Create a new Phoenix project
mix phx.new your_project_name --database postgres

cd your_project_name
```

## Install CodeMySpec VS Code Extension

Install the CodeMySpec extension for Visual Studio Code:

1. Open VS Code
2. Go to Extensions (Cmd+Shift+X or Ctrl+Shift+X)
3. Search for "CodeMySpec"
4. Click Install

Or install directly from the marketplace: [CodeMySpec Extension](https://marketplace.visualstudio.com/items?itemName=CodeMySpec.code-my-spec)

Alternatively, install via command line:
```bash
code --install-extension CodeMySpec.code-my-spec
```

### Configure MCP Servers

After installing the extension, you'll need to configure the MCP servers to connect to your CodeMySpec instance.

The extension provides access to two MCP servers:
- **Stories Server** (`https://codemyspec.com/mcp/stories`) - For managing user stories and requirements
- **Components Server** (`https://codemyspec.com/mcp/components`) - For managing component designs and architecture

To configure the servers:

1. Open VS Code Settings (Cmd+, or Ctrl+,)
2. Search for "CodeMySpec"
3. Set the following configuration:
   - **Server URL**: Your local development server (e.g., `http://localhost:4000`)
   - **OAuth Client ID**: Your OAuth application client ID
   - **OAuth Client Secret**: Your OAuth application client secret

Or add to your VS Code `settings.json`:
```json
{
  "codeMySpec.serverUrl": "http://localhost:4000",
  "codeMySpec.oauth.clientId": "your-client-id",
  "codeMySpec.oauth.clientSecret": "your-client-secret"
}
```

The MCP servers will be available at:
- Stories: `http://localhost:4000/mcp/stories`
- Components: `http://localhost:4000/mcp/components`

## Install Phoenix Authentication

Install the Phoenix authentication system using `phx.gen.auth`:

```bash
mix phx.gen.auth Users User users
```

This will generate:
- User schema and authentication context
- Registration, login, and password reset functionality
- Email confirmation and session management
- Authentication-related LiveViews and templates

Run the database migrations:

```bash
mix ecto.migrate
```

Run the tests:

```bash
mix test
```

## Add CodeMySpec Dependencies

Update your `mix.exs` file to include the CodeMySpec-specific dependencies:

```elixir
defp deps do
  [
    # ... your existing Phoenix dependencies ...

    # CodeMySpec-specific dependencies
    {:file_system, "~> 1.0"},
    {:ngrok, git: "https://github.com/johns10/ex_ngrok", branch: "main", only: [:dev]},
    {:exunit_json_formatter, git: "https://github.com/johns10/exunit_json_formatter", branch: "master"}
  ]
end
```

Then install the dependencies:

```bash
mix deps.get
```

## Set Up Documentation Repository

CodeMySpec uses a separate Git repository for documentation, managed as a submodule.

### Create a GitHub Repository for Docs

1. Create a new GitHub repository (e.g., `your_project_name_docs`)
2. Initialize it with a README.md

### Add as Submodule

```bash
# Add the docs repository as a submodule
git submodule add https://github.com/your_username/your_project_name_docs.git docs

# Initialize and update the submodule
git submodule init
git submodule update
```

### Docs Directory Structure

Your docs repository should contain files for rules and design documentation:

```
docs/
├── .gitignore
├── rules/
├── local/
└── design/
```

You can use this bash script:

```bash
PROJECT_NAME="my_project"
mkdir -p design
mkdir -p local
mkdir -p rules
mkdir -p "design/${PROJECT_NAME}"
mkdir -p "design/${PROJECT_NAME}_web"
```

Gitignore content:

```bash
.DS_Store
local/
```

### Content Directory Structure

The content directory must follow this specific structure:

```
lib/your_project_name_web/content/
├── .git/
├── content/           # Markdown files with corresponding YAML metadata
│   ├── page_slug.md
│   ├── page_slug.yaml
│   ├── another_page.md
│   └── another_page.yaml
└── resources/         # Additional markdown resources
    └── resource_file.md
```

You can use this bash script:

```bash
PROJECT_NAME="my_project"
mkdir -p content
mkdir -p resources
```

### Content File Format

Each piece of content requires two files:

1. **Markdown, HTML, or heex file** (e.g., `my_page.md`) - Contains the actual content
2. **YAML metadata file** (e.g., `my_page.yaml`) - Contains metadata about the content

#### Example YAML Metadata File

```yaml
# Required fields
slug: my-page-slug
type: page  # Options: blog, page, landing
title: My Page Title

# Publishing control
protected: false  # Set to true to require authentication
publish_at: null  # ISO 8601 datetime or null for immediate publish
expires_at: null  # ISO 8601 datetime or null for never expires

# SEO Metadata
meta_title: My Page Title - Your Project
meta_description: Description for search engines
og_title: My Page Title
og_description: Description for social media
og_image: null  # URL to Open Graph image

# Additional metadata (custom key-value pairs)
metadata:
  template: default  # Options: default, article, tutorial
  author: Your Name
  category: Documentation
  featured: false

# Tags (optional, list of tag names)
tags:
  - documentation
  - getting-started
```

## Configure .gitmodules

Your `.gitmodules` file should look like this:

```ini
[submodule "docs"]
	path = docs
	url = https://github.com/your_username/your_project_name_docs.git
[submodule "content"]
	path = lib/your_project_name_web/content
	url = https://github.com/your_username/your_project_name_content.git
```

## Working with Submodules

### Cloning a Project with Submodules

When cloning a project that uses submodules:

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/your_username/your_project_name.git

# Or if you already cloned without submodules:
git submodule init
git submodule update
``` 

## Development Configuration

Update your `config/dev.exs` to include any CodeMySpec-specific configuration (ngrok, file system watchers, etc.).

```
config :your_application,
  watch_content: true,
  content_watch_directory:
    "/content_dir/content",
  content_watch_scope: %{
    account_id: your_account_id,
    project_id: your_project_id
  }
```

## Verify Setup

```bash
# Run tests to verify everything is working
mix test

# Start the server
mix phx.server
```
