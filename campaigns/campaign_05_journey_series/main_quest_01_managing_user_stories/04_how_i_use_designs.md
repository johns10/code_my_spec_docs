
### Main Quest Post 4: "How I Actually Use Design Documents to Guide AI Code Generation"

**Target audience:** Developers ready for complete walkthrough
**Length:** 2500-3000 words
**Channel:** r/elixir, dev.to, your blog

#### Content Outline

**Hook:**
- "Let me walk you through my complete workflow"
- "From user story to passing tests"
- "Using only markdown files and Claude/ChatGPT"

**Complete Example:**

**Starting Point:**
```markdown
# User Story 2.2: User Story Management
As a PM, I want to edit generated user stories so I can refine them.

**Acceptance Criteria:**
- Stories are fully editable (title, description, criteria)
- Users can add, modify, or remove stories
- System tracks changes
- Changes trigger regeneration workflow
```

**Step 1: Context Mapping**
```markdown
## Stories Context
**Type**: Domain Context
**Entity**: Story
**Responsibilities**: Story CRUD, editing, change tracking
**Dependencies**: None
```

**Step 2: Component Design**
```markdown
# Stories Context

## Purpose
Manages user story lifecycle including CRUD operations and change tracking

## Public API
```elixir
def create_story(attrs)
def update_story(story, attrs)
def delete_story(story)
def list_stories(project_id)
```

## Schema
```elixir
schema "stories" do
  field :title, :string
  field :description, :text
  field :acceptance_criteria, :string
  field :dirty, :boolean, default: false
  belongs_to :project, Project
end
```

## Change Tracking
When story updated:
- Set dirty: true
- Broadcast :story_updated event
- Downstream artifacts marked for regeneration
```

**Step 3: Prompt AI**
```
I'm building a Phoenix application. Here's the design for the Stories context: [paste design]

Generate:
1. lib/my_app/stories.ex (context module)
2. lib/my_app/stories/story.ex (schema)
3. test/my_app/stories_test.exs (tests)

Follow Phoenix conventions. Ensure all public API functions in design are implemented.
```

**Step 4: Review Generated Code**
- Does implementation match design?
- Are all public API functions present?
- Does schema match design?
- Are dependencies correct?

**Step 5: Run Tests**
```bash
mix test test/my_app/stories_test.exs
```

**Step 6: Fix Issues**
If tests fail, prompt with failure context:
```
The test failed with this error: [paste]

Here's the design document: [paste]

The implementation doesn't match the design because [explain issue].
Fix the implementation to match the design.
```

**Step 7: Integration**
After tests pass:
```bash
git add .
git commit -m "Add Stories context per design"
```

**The Complete Workflow:**
```
1. Start with user story (from stories.md)
2. Identify context (from context_mapping.md)
3. Write component design document
4. Prompt AI with design
5. Review generated code against design
6. Run tests
7. Fix failures with design as reference
8. Commit when tests pass
```

**Key Prompting Patterns:**

For context generation:
```
Here's the context design: [paste]
Generate the context module following Phoenix conventions.
Include all public API functions from the design.
```

For schema generation:
```
Here's the schema design: [paste]
Generate the schema with all fields, relationships, and validations.
```

For tests:
```
Here's the component design: [paste]
Generate comprehensive tests covering:
- All public API functions
- Happy paths and error cases
- Edge cases mentioned in design
```

For fixes:
```
Test failure: [paste failure]
Component design: [paste design]
Fix the implementation to match the design.
```

**What I Learned:**

**Good Prompts:**
- Include complete design document
- Specify Phoenix conventions
- Be explicit about dependencies
- Reference design when fixing

**Bad Prompts:**
- "Build a stories feature" (too vague)
- "Fix the test" (no design reference)
- "Make it work" (no architectural guidance)

**Design Quality Matters:**
- Vague design → vague code
- Explicit design → explicit code
- Design gaps become code gaps
- Update design if requirements change

**When This Breaks Down:**
- Design is too vague (add detail)
- Dependencies not clear (update design)
- AI doesn't understand Elixir patterns (provide examples)
- Tests fail repeatedly (review design, might be wrong)

**Transition to Automation:**
- "After doing this 50+ times, I automated it"
- "The manual process taught me what matters"
- "Automation preserves the principles"

**Call to Action:**
- Try complete workflow for one feature
- Create all three artifacts (story, mapping, design)
- Generate code from design
- Share your results
- "What worked? What was hard?"

**Product Reveal Teaser:**
> After months of this process, I built CodeMySpec to automate the tedious parts while preserving human control at decision points. Read about it here: [link to Side Quest 4A]

#### Source Material
- Your actual user_stories.md
- Your actual context_mapping.md
- Real examples from your codebase
- Your actual prompts and workflows

#### Success Metrics
- "I tried this, here's what happened" comments
- Readers sharing their workflows
- Questions about specific steps
- GitHub repos showing the approach
- Conference talk interest
