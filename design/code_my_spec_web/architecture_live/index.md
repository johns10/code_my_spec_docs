# ArchitectureLive.Index Design

Visual architecture overview showing story-driven component dependencies using hierarchical tree view.

## Layout Structure

```
Architecture Overview                                            [Components] [Stories]
┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
 UNSATISFIED STORIES (need components assigned)
┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

┌─────────────────────────────────────────────────────────────────────────────────────┐
│ ❓ Story: Password Reset                                                [Edit Story] │
│    └── ⚠️ No component assigned - needs architecture design                         │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│ ❓ Story: User Profile Settings                                         [Edit Story] │
│    └── ⚠️ No component assigned - needs architecture design                         │
└─────────────────────────────────────────────────────────────────────────────────────┘

┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈
 SATISFIED STORIES (have components assigned)
┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈

┌─────────────────────────────────────────────────────────────────────────────────────┐
│ 📖 Story: User Login                                                    [Edit Story] │
│ ├── UserService (genserver)                                           [Edit] │
│ │   ├── UserRepository (repository)                                    │
│ │   └── EmailService (task)                                            │
│ │       └── MailgunAdapter (other)                                     │
│ └── AuthContext (context)                                              │
│     └── TokenService (genserver)                                       │
│         └── RedisStore (repository)                                    │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│ 📖 Story: User Registration                                             [Edit Story] │
│ ├── UserService (genserver)                                           [Edit] │
│ │   ├── UserRepository (repository)                                    │
│ │   └── EmailService (task)                                            │
│ └── ValidationContext (context)                                        │
│     └── PasswordValidator (other)                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Implementation Approach

### Data Structure
Combines two data sources:

1. **Satisfied Stories**: `Components.show_architecture/1` returns:
```elixir
[
  %{component: %Component{...}, depth: 0},  # Root components with stories
  %{component: %Component{...}, depth: 1},  # First-level dependencies  
  %{component: %Component{...}, depth: 2},  # Second-level dependencies
  # ... up to depth 10
]
```

2. **Unsatisfied Stories**: `Stories.list_unsatisfied_stories/1` returns:
```elixir
[
  %Story{title: "Password Reset", component_id: nil, ...},
  %Story{title: "User Profile Settings", component_id: nil, ...}
]
```

### Tree Rendering Strategy
1. **Group by Stories**: Components at depth 0 have stories - these become root nodes
2. **Build Dependency Chains**: Use depth to create indented hierarchy
3. **Visual Indicators**: 
   - `├──` for intermediate nodes
   - `└──` for last nodes at each level
   - `│` for continuation lines

### Component Display Format
Each component shows:
- **Name** (clickable - navigates to ComponentLive.Edit)
- **Type badge** in parentheses
- **Hover tooltip** with description

### Interactive Features
- **Component names**: Click to edit component
- **Story titles**: Click to edit story (both satisfied and unsatisfied)
- **Collapsible sections**: Click story title to collapse/expand dependency tree
- **Navigation**: Components and Stories buttons in header
- **Unsatisfied stories**: Click "Edit Story" to assign component via story edit form

## LiveView Implementation

### Mount
- Load satisfied stories via `Components.show_architecture/1`
- Load unsatisfied stories via `Stories.list_unsatisfied_stories/1`
- Process and combine both datasets
- Subscribe to component/story changes for real-time updates

### Data Processing
```elixir
def process_architecture_data(scope) do
  satisfied_architecture = Components.show_architecture(scope)
  unsatisfied_stories = Stories.list_unsatisfied_stories(scope)
  
  %{
    satisfied: process_satisfied_stories(satisfied_architecture),
    unsatisfied: unsatisfied_stories
  }
end

defp process_satisfied_stories(architecture_data) do
  architecture_data
  |> group_by_story()
  |> build_dependency_trees()
  |> add_tree_formatting()
end

defp group_by_story(components) do
  # Group root components (depth 0) by their stories
  # Attach their dependency chains
end

defp build_dependency_trees(grouped_data) do
  # Create hierarchical structure for each story's components
end

defp add_tree_formatting(trees) do
  # Add ├── └── │ formatting based on position in tree
end
```

### Real-time Updates
- Listen for component/story changes
- Reload architecture data
- Update display with new dependency relationships

### Header Actions
- **Components** button - navigate to ComponentLive.Index
- **Stories** button - navigate to StoryLive.Index

## Empty States

### No Stories with Components
```
Architecture Overview                                            [Components] [Stories]

┌─────────────────────────────────────────────────────────────────────────────────────┐
│ No architecture to display                                                           │
│                                                                                       │
│ Components need to be associated with stories to appear in the architecture view.    │
│                                                                                       │
│ [Create Components] [View Stories]                                                    │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Components Without Dependencies
```
Architecture Overview                                            [Components] [Stories]

┌─────────────────────────────────────────────────────────────────────────────────────┐
│ Story: Simple Feature                                                                 │
│ └── SimpleComponent (other)                                                          │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Technical Notes

### Performance Considerations
- Architecture data loaded once on mount
- Real-time updates only reload when components/dependencies change
- Tree formatting done in assigns, not in template

### Responsive Design
- Tree indentation scales with screen size
- Component type badges wrap on narrow screens
- Touch-friendly click targets for mobile

### Accessibility
- Proper ARIA labels for tree structure
- Keyboard navigation support
- Screen reader friendly hierarchy

## Future Enhancements
- Dependency cycle detection and highlighting
- Component usage metrics
- Export architecture as diagram
- Filter by component type or story status