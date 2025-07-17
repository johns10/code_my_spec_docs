## AccountForm
**Purpose**: Create/edit account forms

**Usage**: `<.account_form changeset={@changeset} action={@action} />`

**Props**:
- `changeset` - Account changeset
- `action` - Form action URL
- `title` - Form title ("Create" or "Edit")

**Template**:
- Account name input
- Account description textarea
- Submit/cancel buttons
- Error display from changeset
