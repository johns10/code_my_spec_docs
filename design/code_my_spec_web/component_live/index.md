# ComponentLive.Index Design

A plain text component listing following the same pattern as StoryLive.Index.

## Layout Structure

```
Listing Components                                    [Architecture] [+ New Component]


UserService                                                            [Edit] [Delete] 
genserver " CodeMySpec.Services.UserService                                           
Priority: 1 " Dependencies: 2 " Stories: 3                                           
                                                                                      
Handles user authentication, registration, and session management.                    
Coordinates with UserRepository and EmailService for complete user workflows.       
                                                                                    
Stories: User Login, User Registration, Password Reset                               
Dependencies: UserRepository, EmailService                                          

UserRepository                                                         [Edit] [Delete] 
repository " CodeMySpec.Data.UserRepository                                          
Priority: 2 " Dependencies: 0 " Stories: 1                                           
                                                                                      
Data access layer for user operations with Ecto queries and validations.             
                                                                                      
Stories: User Profile Management                                                      
Dependencies: None                                                                    
```

## Key Features

### Header Actions
- **Architecture** button - navigates to ArchitectureLive.Index  
- **+ New Component** button - navigates to ComponentLive.New

### Component Card Layout
Each component displays in a card with:

1. **Title Row**: Component name + action buttons (Edit/Delete)
2. **Metadata Row**: Type badge " Module name  
3. **Stats Row**: Priority " Dependency count " Story count
4. **Description**: Component description (if present)
5. **Relationships**: 
   - Stories: Linked story titles (clickable)
   - Dependencies: Component names (clickable)

### Component Type Badges
Following Elixir architecture patterns:
- `genserver` - Process/service components
- `context` - Business logic contexts  
- `coordination_context` - Cross-boundary contexts
- `schema` - Data schemas
- `repository` - Data access
- `task` - Background tasks
- `registry` - Process registries
- `other` - Miscellaneous

### Sorting & Ordering
Components ordered by:
1. Priority (ascending, nulls last)
2. Name (alphabetical)

### Interactive Elements
- **Component name**: Click to view/edit
- **Story names**: Click to navigate to story
- **Dependency names**: Click to navigate to component
- **Edit button**: Navigate to ComponentLive.Edit
- **Delete button**: Confirm and delete with optimistic UI
- **Architecture button**: Navigate to ArchitectureLive.Index

## LiveView Implementation

### Mount
- Subscribe to component changes via `Components.subscribe_components/1`
- Stream components ordered by priority then name
- Set page title

### Events
- `delete` - Delete component with confirmation
- Navigation handled via `~p` paths

### Real-time Updates
- Listen for `{:created, component}`, `{:updated, component}`, `{:deleted, component}`
- Update streams accordingly

## Data Loading
Uses `Components.list_components_with_dependencies/1` to preload:
- Stories association
- Dependencies/dependents counts
- Outgoing/incoming dependency relationships

## UI Consistency
Matches StoryLive.Index patterns:
- Same card layout and spacing
- Same button styles and positioning  
- Same action patterns (edit/delete)
- Same header structure
- Same responsive design