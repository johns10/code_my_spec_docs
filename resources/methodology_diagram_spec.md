# Interactive Methodology Diagram - Technical Specification

## Overview
This document specifies the interactive component diagram for the CodeMySpec Method landing page. The diagram serves as both a visual navigation tool and an educational resource showing the complete methodology flow.

## Component Architecture

### Technology Stack
- **Framework:** React (for LiveView integration via hooks)
- **Styling:** Tailwind CSS (matches Phoenix/CodeMySpec design system)
- **Animations:** Framer Motion or CSS transitions
- **SVG:** Inline SVG for diagram elements
- **State Management:** React hooks (useState, useEffect)
- **Persistence:** localStorage for user progress tracking

### Integration with Phoenix LiveView
```elixir
# lib/code_my_spec_web/live/content_live/methodology.ex
defmodule CodeMySpecWeb.ContentLive.Methodology do
  use CodeMySpecWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "The CodeMySpec Method")}
  end

  def render(assigns) do
    ~H"""
    <div class="methodology-page">
      <div id="methodology-diagram" phx-hook="MethodologyDiagram">
        <!-- React component mounts here -->
      </div>
    </div>
    """
  end
end
```

---

## Visual Design Specification

### Color Palette
```css
/* Primary Colors (Phoenix/Elixir inspired) */
--purple-primary: #4B275F;    /* Elixir purple */
--purple-light: #6E4C7E;
--purple-dark: #2D1741;

--orange-accent: #FD4F00;     /* Phoenix orange */
--orange-light: #FF7A3D;
--orange-dark: #D93F00;

/* Neutrals */
--gray-900: #1A202C;
--gray-700: #2D3748;
--gray-500: #718096;
--gray-300: #CBD5E0;
--gray-100: #F7FAFC;

/* States */
--success: #48BB78;
--info: #4299E1;
--warning: #ED8936;
```

### Typography
```css
/* Font Stack */
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-mono: 'Fira Code', 'Source Code Pro', monospace;

/* Type Scale */
--text-xs: 0.75rem;     /* 12px */
--text-sm: 0.875rem;    /* 14px */
--text-base: 1rem;      /* 16px */
--text-lg: 1.125rem;    /* 18px */
--text-xl: 1.25rem;     /* 20px */
--text-2xl: 1.5rem;     /* 24px */
--text-3xl: 1.875rem;   /* 30px */
```

### Spacing System
```css
/* Based on 4px base unit */
--space-1: 0.25rem;   /* 4px */
--space-2: 0.5rem;    /* 8px */
--space-3: 0.75rem;   /* 12px */
--space-4: 1rem;      /* 16px */
--space-6: 1.5rem;    /* 24px */
--space-8: 2rem;      /* 32px */
--space-12: 3rem;     /* 48px */
```

---

## Phase Card Design

### Card States

#### Default State
```
┌─────────────────────────────────────────────┐
│  Phase 1                    [Manual] [Auto] │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                             │
│  User Stories                               │
│  "Define requirements in plain English"    │
│                                             │
│  [Read Guide →] [See Automation →]          │
└─────────────────────────────────────────────┘
```

**Visual Properties:**
- Background: white with subtle shadow
- Border: 1px solid gray-300
- Border-radius: 12px
- Padding: space-6
- Hover: Lift with increased shadow

#### Hover State
```
┌─────────────────────────────────────────────┐ ↑ lifts
│  Phase 1                    [Manual] [Auto] │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                             │
│  User Stories                        ←───── Subtle glow
│  "Define requirements in plain English"    │
│                                             │
│  [Read Guide →] [See Automation →]          │
└─────────────────────────────────────────────┘
  Cursor: pointer
```

**Visual Changes:**
- Shadow: 0 8px 24px rgba(0,0,0,0.12)
- Border: purple-primary
- Transform: translateY(-4px)
- Transition: all 0.2s ease

#### Expanded State
```
┌─────────────────────────────────────────────────────────┐
│  Phase 1                            [Manual] [Auto]  [×]│
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                         │
│  User Stories                                           │
│  "Define requirements in plain English"                │
│                                                         │
│  What You Create:                                       │
│  • user_stories.md file with structured stories        │
│  • Acceptance criteria for each story                  │
│  • Edge cases and error scenarios                      │
│                                                         │
│  Why It Matters:                                        │
│  Stories are the foundation for everything else.       │
│  Without clear stories, AI makes up requirements...    │
│                                                         │
│  Example from CodeMySpec:                               │
│  ┌────────────────────────────────────────────┐       │
│  │ ## User Story: Component Design Sessions   │       │
│  │ As an architect, I want to generate...     │       │
│  └────────────────────────────────────────────┘       │
│                                                         │
│  [Read Full Guide →]  [See Automation →]               │
│  [View Code Example →]                                  │
└─────────────────────────────────────────────────────────┘
```

**Visual Changes:**
- Background: gradient from white to purple-100
- Width: Expands to full container width
- Height: Animates to fit content
- Close button appears (×)
- Additional content fades in

---

## Connection Arrows

### Arrow Design
```
Phase 1 Card
     │
     ├─→ Manual Path (dashed, gray-500)
     │
     └─→ Automated Path (solid, purple-primary)
     │
     ↓ Main Flow (solid, orange-accent, thick)
     │
Phase 2 Card
```

**Visual Properties:**
- Main flow: 4px solid orange-accent with arrowhead
- Manual path: 2px dashed gray-500
- Automated path: 2px solid purple-primary
- Animated flow: Subtle dash-offset animation on hover

### Arrow States
- **Default:** Static
- **Hover (phase card):** Animated dash-offset showing flow direction
- **Expanded:** Highlighted to show active phase position

---

## Layout Specifications

### Desktop Layout (≥1024px)
```
┌────────────────────────────────────────────────┐
│  Hero Section                                  │
│  ┌──────────────────────────────────────────┐ │
│  │  Headline                                 │ │
│  │  Subheadline                              │ │
│  │                                           │ │
│  │  [CTA Manual] [CTA Automation]            │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  Diagram Container (max-width: 800px, centered)│
│  ┌──────────────────────────────────────────┐ │
│  │  ┌────────────────┐                      │ │
│  │  │  Phase 1 Card  │                      │ │
│  │  └────────────────┘                      │ │
│  │         ↓                                 │ │
│  │  ┌────────────────┐                      │ │
│  │  │  Phase 2 Card  │                      │ │
│  │  └────────────────┘                      │ │
│  │         ↓                                 │ │
│  │      (etc.)                               │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

### Mobile Layout (≤768px)
```
┌──────────────────┐
│  Hero (stacked)  │
│  ┌────────────┐  │
│  │  Headline  │  │
│  │  Sub       │  │
│  │  [CTA 1]   │  │
│  │  [CTA 2]   │  │
│  └────────────┘  │
│                  │
│  Diagram         │
│  ┌────────────┐  │
│  │ Phase 1    │  │
│  │ (compact)  │  │
│  └────────────┘  │
│       ↓          │
│  ┌────────────┐  │
│  │ Phase 2    │  │
│  └────────────┘  │
└──────────────────┘
```

**Mobile Adaptations:**
- Cards stack vertically (full width)
- Arrows simplified (straight down)
- Expanded state becomes full-screen overlay
- Buttons stack vertically
- Font sizes scale down 10-15%

---

## Interactive Behaviors

### 1. Mode Toggle (Manual vs. Automated)

**Location:** Top-right of each phase card

**Visual:**
```
[Manual] [Auto]
   ↑       ↑
  active  inactive

Color:
- Active: purple-primary background, white text
- Inactive: gray-300 background, gray-700 text
```

**Behavior:**
- Click toggles mode for all phases
- State persists via localStorage
- Content updates to show manual or automated workflow
- Smooth transition between states (0.3s ease)

**Content Changes:**
- Manual mode: Shows copy-paste workflow, emphasis on learning
- Automated mode: Shows MCP/CodeMySpec workflow, emphasis on speed

### 2. Card Expansion

**Trigger:** Click anywhere on card (except buttons)

**Animation Sequence:**
1. Other cards collapse (if any expanded)
2. Clicked card lifts and expands (0.3s ease-out)
3. Additional content fades in (0.2s delay)
4. Close button appears
5. Scroll to keep card in view

**Content Shown on Expansion:**
- Full phase description
- What you create (bulleted list)
- Why it matters (2-3 sentences)
- Real example from CodeMySpec (code block)
- Links to guides and automation

### 3. Scroll-Spy Progress

**Location:** Fixed sidebar on desktop, top bar on mobile

**Visual:**
```
Desktop Sidebar:
┌─────────┐
│ Phase 1 │ ← Currently viewing
│ Phase 2 │
│ Phase 3 │
│ Phase 4 │
│ Phase 5 │
└─────────┘

Mobile Top Bar:
━━●━━━━━━━━
  Phase 2/5
```

**Behavior:**
- Highlights current phase based on scroll position
- Click to jump to phase
- Smooth scroll animation
- Updates URL hash for sharing (#phase-2)

### 4. Link Interactions

**Guide Links:**
- Icon: Book emoji or icon
- Text: "Read Full Guide"
- Opens in new tab
- Tracks click event

**Automation Links:**
- Icon: Lightning bolt or robot
- Text: "See Automation"
- Opens in new tab or scrolls to automation section
- Tracks click event

**Code Example Links:**
- Icon: GitHub logo
- Text: "View in CodeMySpec Repo"
- Opens GitHub file at specific line
- Tracks click event

---

## Data Structure

### Phase Configuration
```javascript
const phases = [
  {
    id: 1,
    title: "User Stories",
    tagline: "Define requirements in plain English",
    icon: "📝",
    color: "purple",

    whatYouCreate: [
      "user_stories.md file with structured stories",
      "Acceptance criteria for each story",
      "Edge cases and error scenarios"
    ],

    whyItMatters: "Stories are the foundation for everything else. Without clear stories, AI makes up requirements. Stories let you validate with stakeholders before coding.",

    example: {
      title: "User Story: Component Design Sessions",
      code: `## User Story: Component Design Sessions
As an architect, I want to generate design documents for components
so that AI has clear specifications for implementation.

Acceptance Criteria:
- System generates component design from context design
- Component design includes schema, repository, service specs
- Design follows Phoenix conventions
- Human reviews and approves design before proceeding`,
      language: "markdown"
    },

    manualWorkflow: {
      steps: [
        "Create user_stories.md in your repo",
        "Interview yourself about requirements",
        "Write stories in 'As a... I want... So that...' format",
        "Add specific, testable acceptance criteria",
        "Review for completeness and conflicts"
      ],
      guideUrl: "/blog/managing-user-stories",
      guideTitle: "How to Manage User Stories to Control AI"
    },

    automatedWorkflow: {
      steps: [
        "Use Stories MCP tools",
        "AI interviews you about requirements",
        "System generates structured stories",
        "Review and refine via chat",
        "Approve and proceed to design"
      ],
      guideUrl: "/blog/stories-mcp-server",
      guideTitle: "Building a Stories MCP Server",
      codeUrl: "https://github.com/user/code_my_spec/blob/main/lib/code_my_spec/mcp_servers/stories_server.ex"
    }
  },

  // Phase 2-5 follow same structure...
];
```

---

## Accessibility Requirements

### Keyboard Navigation
- **Tab:** Move between interactive elements
- **Enter/Space:** Activate buttons and expand cards
- **Escape:** Close expanded card
- **Arrow keys:** Navigate between phases in scroll-spy

### Screen Reader Support
```html
<div role="region" aria-label="Methodology Phases">
  <article
    role="button"
    aria-expanded="false"
    aria-label="Phase 1: User Stories - Click to expand"
    tabindex="0"
  >
    <!-- Phase content -->
  </article>
</div>
```

### Focus Management
- Visible focus indicators (2px purple outline)
- Focus moves to expanded card content
- Focus returns to trigger on close
- Skip links for keyboard users

### Color Contrast
- All text meets WCAG AA (4.5:1 for normal text)
- Interactive elements meet enhanced contrast (7:1)
- Icons have text alternatives
- Don't rely on color alone for information

---

## Performance Optimization

### Code Splitting
```javascript
// Lazy load diagram component
const MethodologyDiagram = React.lazy(() =>
  import('./components/MethodologyDiagram')
);

// Show loading state
<Suspense fallback={<DiagramSkeleton />}>
  <MethodologyDiagram />
</Suspense>
```

### Asset Optimization
- SVG icons inline (< 2KB each)
- Animations use CSS transforms (GPU accelerated)
- Images lazy loaded below fold
- Code examples syntax highlighted at build time

### Bundle Size Targets
- Initial JS: < 50KB gzipped
- Total JS: < 150KB gzipped
- CSS: < 20KB gzipped
- Lighthouse score: > 90

---

## Analytics & Tracking

### Events to Track
```javascript
// Phase interactions
analytics.track('Phase Card Clicked', {
  phase_id: 1,
  phase_title: 'User Stories',
  mode: 'manual' // or 'automated'
});

// Mode toggle
analytics.track('Mode Toggled', {
  from: 'manual',
  to: 'automated'
});

// Guide clicks
analytics.track('Guide Link Clicked', {
  phase_id: 1,
  guide_type: 'manual', // or 'automated'
  destination: '/blog/managing-user-stories'
});

// Expansion time
analytics.track('Phase Expanded', {
  phase_id: 1,
  time_on_page_before_expand: 15000 // ms
});

// Scroll depth
analytics.track('Scroll Depth', {
  depth_percent: 75,
  phases_viewed: [1, 2, 3]
});
```

---

## Component Code Structure

### File Organization
```
lib/code_my_spec_web/
└── assets/
    └── js/
        └── methodology_diagram/
            ├── index.jsx              # Main export
            ├── MethodologyDiagram.jsx # Container
            ├── PhaseCard.jsx          # Individual phase
            ├── PhaseArrow.jsx         # Connection arrows
            ├── ModeToggle.jsx         # Manual/Auto toggle
            ├── CodeExample.jsx        # Syntax highlighted code
            ├── ScrollSpy.jsx          # Navigation sidebar
            ├── hooks/
            │   ├── usePhaseExpansion.js
            │   ├── useScrollSpy.js
            │   └── useLocalStorage.js
            ├── styles/
            │   └── diagram.css
            └── data/
                └── phases.js          # Phase configuration
```

### React Hook Integration
```javascript
// lib/code_my_spec_web/assets/js/hooks/methodology_diagram.js
export const MethodologyDiagram = {
  mounted() {
    this.el.addEventListener('phx:mounted', () => {
      // Initialize React component
      const root = ReactDOM.createRoot(this.el);
      root.render(<MethodologyDiagramComponent />);
    });
  },

  destroyed() {
    // Cleanup React component
    const root = ReactDOM.createRoot(this.el);
    root.unmount();
  }
};
```

---

## Testing Strategy

### Unit Tests
- Phase card rendering
- Mode toggle state changes
- Expansion/collapse logic
- Link click handlers

### Integration Tests
- Full diagram render
- Phase navigation
- Scroll-spy updates
- localStorage persistence

### Visual Regression Tests
- Phase card states (default, hover, expanded)
- Mode toggle transitions
- Mobile responsive layouts
- Dark mode (if applicable)

### Accessibility Tests
- Keyboard navigation
- Screen reader announcements
- Focus management
- Color contrast

---

## Implementation Phases

### Phase 1: MVP (Week 1)
- [ ] Static diagram layout
- [ ] Phase cards with basic styling
- [ ] Card expansion on click
- [ ] Manual/automated mode toggle
- [ ] Responsive layout

### Phase 2: Enhanced (Week 2)
- [ ] Smooth animations
- [ ] Scroll-spy navigation
- [ ] Code syntax highlighting
- [ ] Analytics tracking
- [ ] Accessibility improvements

### Phase 3: Polish (Week 3)
- [ ] Advanced animations
- [ ] Loading states
- [ ] Error boundaries
- [ ] Performance optimization
- [ ] Cross-browser testing

---

## Browser Support

### Supported Browsers
- Chrome/Edge: Last 2 versions
- Firefox: Last 2 versions
- Safari: Last 2 versions
- Mobile Safari: iOS 14+
- Chrome Mobile: Last 2 versions

### Fallbacks
- CSS Grid with flexbox fallback
- CSS custom properties with PostCSS fallback
- IntersectionObserver with polyfill
- Smooth scrolling with polyfill

---

## Open Questions / Future Enhancements

1. **Animation complexity:** How much animation is too much? Need user testing.
2. **Print styles:** Should diagram be printable as a reference guide?
3. **Dark mode:** Should we support dark mode initially or defer?
4. **Offline support:** PWA features for offline diagram access?
5. **Customization:** Allow users to hide phases they've completed?
6. **Gamification:** Add badges/achievements for completing phases?
7. **Sharing:** Generate shareable cards for social media?
8. **Localization:** Plan for i18n from the start?

---

## Success Criteria

### User Engagement
- [ ] >50% of visitors interact with diagram
- [ ] >30% expand at least one phase
- [ ] >20% toggle between manual/automated modes
- [ ] Average time on diagram: >2 minutes

### Technical Performance
- [ ] Lighthouse score: >90
- [ ] First Contentful Paint: <1.5s
- [ ] Time to Interactive: <3s
- [ ] No layout shifts (CLS = 0)

### Accessibility
- [ ] WCAG AA compliance verified
- [ ] Keyboard navigation 100% functional
- [ ] Screen reader tested on NVDA/JAWS
- [ ] No color contrast violations
