## Component Design Template

### File Structure
- Place in `docs/design/my_app_web/{context}_live/components/`
- Name files by component: `account_card.md`, `members_list.md`

### Required Sections

1. **Purpose** - Single sentence describing what this component does
2. **Usage** - Code example showing how to use the component
3. **Props** - List of all props with types and descriptions
4. **Template** - UI structure and styling approach
5. **Events** - User interactions handled by this component (if any)
6. **Additional Sections** - As needed:
   - **Validation** - Form validation rules
   - **States** - Different visual states
   - **Examples** - Multiple usage examples
   - **Logic** - Complex behavior explanations

## Style Guidelines

- **Be concise** - Each section should be brief but complete
- **Use bullets** - Structure information as bullet points
- **Include context calls** - Show exactly which context functions are used
- **Show code examples** - Provide HEEx usage examples for components
- **Focus on behavior** - Describe what happens, not how it's implemented
- **Consider security** - Always include permission and authorization concerns
- **Plan for real-time** - Consider PubSub integration for live updates
