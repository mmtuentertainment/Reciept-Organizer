# shadcn/ui Enhanced Knowledgebase Usage Guide

## 🚀 Quick Start

This enhanced knowledgebase provides comprehensive, interconnected documentation for shadcn/ui with embedded contextual relationships. Use it to navigate seamlessly between concepts, discover alternatives, and follow optimal workflows.

## 📖 How to Use the Knowledgebase

### Understanding Relationship Annotations

The knowledgebase uses 12 relationship types to connect information:

| Annotation | Purpose | Example |
|------------|---------|---------|
| `@depends_on` | Shows dependencies | Button depends on `@radix-ui/react-slot` |
| `@used_by` | What uses this component | Button used by Dialog, Form, Card |
| `@alternatives` | Similar options | Dialog alternatives: Sheet, Drawer |
| `@see_also` | Related concepts | Form see also: Validation, Input_OTP |
| `@workflow_next` | Next step | After init, next is add components |
| `@workflow_prev` | Previous step | Before Form, previous is Dialog |
| `@cli_command` | CLI command | `npx shadcn@latest add button` |
| `@mcp_tool` | MCP equivalent | `mcp__shadcn__add_component` |
| `@implements` | What it implements | Card implements Composition_Pattern |
| `@extends` | What it extends | Alert_Dialog extends Dialog |
| `@requires` | Prerequisites | Form requires react-hook-form, zod |
| `@category` | Component category | Category: forms, overlays, navigation |

## 🎯 Common Use Cases

### Use Case 1: Starting a New Project

```poml
Path: Overview → Installation → Framework_Selection → [Your Framework] → Quick_Start

Example for Next.js:
1. Overview {@workflow_next: Installation}
2. Installation → Quick_Start {@command: "npx shadcn@latest init"}
3. Framework_Selection → Next_js
4. Configuration {@modifies: ["components.json", "tailwind.config.js"]}
5. Component_Addition {@cli_command: "npx shadcn@latest add button"}
```

### Use Case 2: Finding the Right Component

```poml
Need: "I need a modal"

Navigate to: Overlay_Components
Find: Dialog {@alternatives: [Sheet, Alert_Dialog, Drawer, Popover]}

Decision Tree:
- Standard modal → Dialog
- Slide-out panel → Sheet
- Confirmation → Alert_Dialog
- Mobile menu → Drawer
- Small overlay → Popover
```

### Use Case 3: Building a Form

```poml
Path: Form_Components → Form → Implementation

Components Needed (auto-discovered via @uses_components):
- Form {@depends_on: ["react-hook-form", "zod"]}
- Input {@used_by: Form}
- Select {@alternatives: [Combobox, RadioGroup]}
- Checkbox {@alternatives: [Switch]}
- Button {@variants: [default, destructive, outline]}

Workflow:
1. Install Form: npx shadcn@latest add form
2. Define Zod schema
3. Setup React Hook Form
4. Add form fields
5. Handle submission
6. Show feedback {@workflow_next: Toast}
```

### Use Case 4: Using MCP Server Tools

```poml
Concurrent MCP + CLI Workflow:

1. Discovery Phase (MCP):
   mcp__shadcn__get_project_registries()
   → Returns: ["@shadcn"]

2. Search Phase (MCP):
   mcp__shadcn__search_items_in_registries("data table")
   → Returns: matching components

3. View Details (MCP):
   mcp__shadcn__view_items_in_registries(["@shadcn/table"])
   → Returns: full component details

4. Get Command (MCP):
   mcp__shadcn__get_add_command_for_items(["@shadcn/table"])
   → Returns: "npx shadcn@latest add table"

5. Execute (CLI):
   npx shadcn@latest add table

6. Verify (MCP):
   mcp__shadcn__get_audit_checklist()
   → Returns: validation checklist
```

## 🔄 Navigation Patterns

### Pattern 1: Linear Workflow Navigation

Follow `@workflow_next` and `@workflow_prev` for step-by-step processes:

```
Installation {@workflow_next} → 
Framework_Selection {@workflow_next} → 
Project_Setup {@workflow_next} → 
Component_Addition {@workflow_next} → 
Customization
```

### Pattern 2: Alternative Exploration

Use `@alternatives` to compare options:

```
Dialog {@alternatives: [Sheet, Alert_Dialog, Drawer]}
  ↓
Compare each alternative:
- Sheet: Slide-out panel from edge
- Alert_Dialog: Confirmation with focus trap
- Drawer: Mobile-friendly slide panel
```

### Pattern 3: Dependency Tree Navigation

Follow `@depends_on` to understand requirements:

```
Table {@depends_on: ["@tanstack/react-table"]}
  ↓
@tanstack/react-table requires:
- React 18+
- TypeScript (optional)
  ↓
Features enabled:
- Sorting, Filtering, Pagination
```

### Pattern 4: Usage Discovery

Use `@used_by` to find implementation examples:

```
Button {@used_by: [Dialog, Form, Card, Dashboard_01]}
  ↓
Check Dashboard_01 for real usage
Check Form for form submission pattern
Check Dialog for action buttons
```

## 📚 Advanced Navigation Techniques

### Technique 1: Cross-Reference Jumping

The knowledgebase has cross-reference sections that map entire ecosystems:

```poml
Cross_References.Form_Ecosystem:
  Form → [Input, Select, Checkbox, Switch, RadioGroup]
  Input → [Form, Search, Command, Filters]
  Select → [Form, Combobox, Dropdown_Menu]
```

### Technique 2: Category-Based Discovery

Use `@category` to find all related components:

```poml
Find all form components:
@category: forms → [Form, Input, Select, Checkbox, Switch, RadioGroup, Input_OTP]

Find all overlays:
@category: overlays → [Dialog, Sheet, Popover, Dropdown_Menu, Context_Menu, Alert_Dialog, Tooltip]
```

### Technique 3: Complexity-Based Learning

Components are marked with `@complexity` levels:

```poml
Beginner Path:
@complexity: beginner → [Button, Card, Input, Badge, Alert]

Intermediate Path:
@complexity: intermediate → [Form, Dialog, Table, Tabs]

Advanced Path:
@complexity: advanced → [Dashboard_01, Chart_Integration, Custom_Registries]
```

## 🛠️ Practical Workflows

### Workflow 1: Complete Feature Implementation

```poml
Feature: User Profile Page

1. Layout {@category: layout}
   → Card {@cli_command: "npx shadcn@latest add card"}

2. User Display {@category: data}
   → Avatar {@cli_command: "npx shadcn@latest add avatar"}
   → Badge {@cli_command: "npx shadcn@latest add badge"}

3. Actions {@category: ui}
   → Button {@cli_command: "npx shadcn@latest add button"}
   → Dropdown_Menu {@cli_command: "npx shadcn@latest add dropdown-menu"}

4. Edit Mode {@category: forms}
   → Form {@cli_command: "npx shadcn@latest add form"}
   → Input {@cli_command: "npx shadcn@latest add input"}

5. Feedback {@category: feedback}
   → Toast {@cli_command: "npx shadcn@latest add toast"}
```

### Workflow 2: Migration from Another Library

```poml
From Material-UI:

1. Check Migration_Guides.From_Material_UI
2. Map components:
   - MUI Button → shadcn Button {@variants: match MUI}
   - MUI TextField → shadcn Input + Label
   - MUI Snackbar → shadcn Toast
3. Follow installation for each mapped component
4. Update imports and props
5. Test functionality
```

## 🔍 Search Strategies

### Strategy 1: Fuzzy Search with MCP

```javascript
// Search for anything calendar-related
mcp__shadcn__search_items_in_registries({
  query: "calendar",
  registries: ["@shadcn"]
})
// Returns: Calendar, Date_Picker, calendar-demos
```

### Strategy 2: Example Discovery

```javascript
// Find all examples for a component
mcp__shadcn__get_item_examples_from_registries({
  query: "button-demo",
  registries: ["@shadcn"]
})
// Returns: Complete demo implementations
```

### Strategy 3: Pattern-Based Search

Look for patterns in the knowledgebase:
- `*-demo` for demonstrations
- `example-*` for example implementations
- `*_Pattern` for design patterns
- `*_Integration` for integration guides

## 💡 Tips and Tricks

### Tip 1: Use Bidirectional Relations
Every relationship has a reverse connection. If A depends on B, then B is used by A.

### Tip 2: Follow the Workflow Chain
Each workflow step knows its position. You can always go forward or backward.

### Tip 3: Explore Alternatives
When stuck, check `@alternatives` for different approaches to the same problem.

### Tip 4: Check Examples
Most components have `@example` references pointing to demo implementations.

### Tip 5: Leverage Categories
Use `@category` to find all components of a similar type quickly.

## 🚦 Quick Reference Commands

### CLI Commands
```bash
# Initialize
npx shadcn@latest init

# Add component
npx shadcn@latest add [component]

# Check updates
npx shadcn@latest diff [component]

# Update component
npx shadcn@latest update [component]
```

### MCP Tools
```javascript
// Get registries
mcp__shadcn__get_project_registries()

// List all items
mcp__shadcn__list_items_in_registries(["@shadcn"])

// Search items
mcp__shadcn__search_items_in_registries("form", ["@shadcn"])

// View details
mcp__shadcn__view_items_in_registries(["@shadcn/form"])

// Get examples
mcp__shadcn__get_item_examples_from_registries("form-demo", ["@shadcn"])

// Get add command
mcp__shadcn__get_add_command_for_items(["@shadcn/form"])

// Audit checklist
mcp__shadcn__get_audit_checklist()
```

## 📊 Knowledgebase Statistics

- **Total Sections**: 25 major sections
- **UI Components**: 48 fully documented
- **Blocks**: 140+ pre-built sections
- **Relationships**: 500+ contextual connections
- **Workflows**: 12 complete workflows
- **Examples**: 100+ implementation examples
- **Patterns**: 8 design patterns

## 🎓 Learning Paths

### Path 1: Beginner
1. Overview → Core_Concepts
2. Installation → Quick_Start
3. Button → Card → Badge
4. Alert → Separator
5. Basic layouts

### Path 2: Intermediate
1. Form → Validation
2. Dialog → Sheet
3. Table → Pagination
4. Navigation_Menu → Tabs
5. Dark mode setup

### Path 3: Advanced
1. Custom registries
2. Dashboard blocks
3. Chart integration
4. Performance optimization
5. Complex workflows

## 🔄 Continuous Learning

The knowledgebase is designed for continuous exploration:

1. **Start anywhere**: Each section is self-contained with relations
2. **Follow connections**: Use relationships to discover related concepts
3. **Build incrementally**: Workflows guide step-by-step implementation
4. **Explore alternatives**: Always check for different approaches
5. **Learn by example**: Every component has implementation examples

---

*This knowledgebase is your comprehensive guide to mastering shadcn/ui development with full contextual awareness.*