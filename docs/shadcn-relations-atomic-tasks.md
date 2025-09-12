# Atomic Tasks for Contextual Relations Implementation

## IMMEDIATE EXECUTION TASKS (Phase 1: Analysis)

### Task Group A: Section Inventory (30 minutes)
```
A1. Read POML and list all top-level sections
A2. Count total components (48 UI components)
A3. Count total blocks (Dashboard, Sidebar x16, Login x5, Calendar x38, Chart x79)
A4. Count total frameworks (7 installation guides)
A5. List all utility functions and hooks
A6. List all patterns and examples
```

### Task Group B: Dependency Mapping (45 minutes)
```
B1. Map Radix UI dependencies for each component
B2. Map component-to-component dependencies (e.g., Dialog uses Button)
B3. Map block-to-component dependencies (e.g., Dashboard uses Card, Chart, Table)
B4. Map utility usage (cn() function used by all components)
B5. Map form component relationships (Form → Input, Select, Checkbox)
B6. Map layout component relationships (Sheet ↔ Dialog alternatives)
```

### Task Group C: Workflow Mapping (30 minutes)
```
C1. Map installation workflow: Framework → Init → Add → Customize
C2. Map development workflow: Plan → Install → Implement → Test → Deploy
C3. Map CLI workflow: init → add → diff → update
C4. Map MCP workflow: list → search → view → add
C5. Map theming workflow: colors → components.json → dark mode
C6. Map registry workflow: create → authenticate → deploy → consume
```

---

## IMPLEMENTATION TASKS (Phase 2: Adding Relations)

### Task Group D: Component Relations Template
For EACH of the 48 components, add:
```poml
@depends_on: [list_of_dependencies]
@used_by: [blocks_and_examples]
@alternatives: [similar_components]
@see_also: [related_components]
@cli_command: "npx shadcn@latest add [component]"
@mcp_tool: "add_component"
@category: "ui|form|data|layout|navigation|feedback|utility"
@complexity: "beginner|intermediate|advanced"
@example: "[component]-demo"
```

### Task Group E: Specific Component Relations (Atomic)

#### E1. Button Component
```poml
Button {
  @depends_on: ["@radix-ui/react-slot"]
  @used_by: ["Dialog", "Card", "Form", "Alert-Dialog", "Dashboard-01"]
  @alternatives: ["Link", "Toggle"]
  @see_also: ["Button-Group", "Icon-Button"]
  @cli_command: "npx shadcn@latest add button"
  @mcp_tool: "mcp__shadcn__add_component"
  @variants: ["default", "destructive", "outline", "secondary", "ghost", "link"]
  @sizes: ["default", "sm", "lg", "icon"]
}
```

#### E2. Dialog Component
```poml
Dialog {
  @depends_on: ["@radix-ui/react-dialog", "Button"]
  @used_by: ["Dashboard-01", "Form-Examples"]
  @alternatives: ["Sheet", "Alert-Dialog", "Drawer"]
  @see_also: ["Popover", "Modal-Patterns"]
  @workflow_next: "Form"
  @accessibility: ["Focus-Trap", "ESC-Close", "Click-Outside"]
}
```

#### E3. Form Component
```poml
Form {
  @depends_on: ["react-hook-form", "zod", "@hookform/resolvers"]
  @uses_components: ["Input", "Select", "Checkbox", "Switch", "Button"]
  @used_by: ["Login-Forms", "Dashboard-01", "Settings"]
  @validation: "Zod"
  @see_also: ["Input-OTP", "Date-Picker"]
  @workflow_prev: "Dialog"
  @workflow_next: "Toast"
}
```

#### E4. Table Component
```poml
Table {
  @depends_on: ["@tanstack/react-table"]
  @features: ["Sorting", "Filtering", "Pagination", "Selection"]
  @used_by: ["Dashboard-01", "Data-Display-Examples"]
  @alternatives: ["Data-Grid", "List"]
  @see_also: ["Chart", "CSV-Export"]
  @workflow_prev: "Data-Fetching"
  @workflow_next: "Export"
}
```

#### E5. Card Component
```poml
Card {
  @depends_on: []
  @composition: ["CardHeader", "CardTitle", "CardDescription", "CardContent", "CardFooter"]
  @used_by: ["Dashboard-01", "Login-Forms", "Pricing-Tables"]
  @alternatives: ["Paper", "Surface"]
  @see_also: ["Dialog", "Sheet"]
  @pattern: "Container"
}
```

### Task Group F: Workflow Relations

#### F1. Installation Workflow
```poml
Installation_Flow {
  @start: "Choose_Framework"
  
  Choose_Framework {
    @options: ["Next.js", "Vite", "Remix", "Astro", "Laravel", "TanStack"]
    @next: "Run_Init"
  }
  
  Run_Init {
    @command: "npx shadcn@latest init"
    @generates: "components.json"
    @next: "Configure_Project"
  }
  
  Configure_Project {
    @modifies: "components.json"
    @options: ["style", "rsc", "tsx", "tailwind", "aliases"]
    @next: "Add_Components"
  }
  
  Add_Components {
    @command: "npx shadcn@latest add [component]"
    @mcp_alternative: "mcp__shadcn__add_component"
    @next: "Customize_Components"
  }
}
```

#### F2. Development Workflow
```poml
Development_Flow {
  @start: "Select_Components"
  
  Select_Components {
    @tools: ["CLI_Search", "MCP_List", "Documentation"]
    @next: "Install_Components"
  }
  
  Install_Components {
    @methods: ["CLI", "MCP", "Manual_Copy"]
    @next: "Implement_Features"
  }
  
  Implement_Features {
    @uses: ["Components", "Patterns", "Utils"]
    @next: "Apply_Theming"
  }
  
  Apply_Theming {
    @modifies: ["CSS_Variables", "Tailwind_Classes"]
    @next: "Test_Implementation"
  }
}
```

### Task Group G: Block Relations

#### G1. Dashboard Block
```poml
Dashboard_01 {
  @components: ["Sidebar", "Card", "Chart", "Table", "Button"]
  @patterns: ["Layout", "Data-Display", "Navigation"]
  @data_flow: "Fetch → Process → Display → Interact"
  @responsive: ["Mobile", "Tablet", "Desktop"]
  @see_also: ["Sidebar-Variants", "Chart-Types"]
}
```

#### G2. Sidebar Blocks
```poml
Sidebar_Variants {
  @total: 16
  @categories: ["Simple", "Collapsible", "Nested", "Floating", "Icon-Only"]
  @components: ["Navigation-Menu", "Button", "Avatar", "Badge"]
  @responsive_behavior: ["Drawer-Mobile", "Fixed-Desktop"]
  @see_also: ["Dashboard", "Navigation-Patterns"]
}
```

### Task Group H: Utility Relations

#### H1. cn() Function
```poml
cn_utility {
  @purpose: "Merge Tailwind classes with conflict resolution"
  @depends_on: ["clsx", "tailwind-merge"]
  @used_by: "ALL_COMPONENTS"
  @pattern: "Class-Name-Merging"
  @example: "cn('p-2', 'p-4') // Result: 'p-4'"
  @critical: true
}
```

#### H2. useIsMobile Hook
```poml
useIsMobile {
  @purpose: "Responsive viewport detection"
  @breakpoint: 768
  @used_by: ["Responsive-Components", "Mobile-Menus"]
  @pattern: "Media-Query-Hook"
  @see_also: ["Responsive-Design", "Mobile-First"]
}
```

### Task Group I: Cross-References

#### I1. Form Components Cross-Reference
```poml
Form_Components {
  Input → ["Form", "Search", "Command"]
  Select → ["Form", "Settings", "Filters"]
  Checkbox → ["Form", "Table-Selection", "Settings"]
  Switch → ["Settings", "Preferences", "Feature-Flags"]
  RadioGroup → ["Form", "Settings", "Surveys"]
}
```

#### I2. Overlay Components Cross-Reference
```poml
Overlay_Components {
  Dialog ↔ Sheet: "Alternatives for modal content"
  Popover ↔ Tooltip: "Hover vs click triggers"
  DropdownMenu ↔ ContextMenu: "Click vs right-click"
  AlertDialog → Dialog: "Extends with confirmation"
}
```

#### I3. Navigation Components Cross-Reference
```poml
Navigation_Components {
  Tabs → ["Router-Integration", "Content-Switching"]
  NavigationMenu → ["Site-Header", "Main-Nav"]
  Breadcrumb → ["Route-Path", "Navigation-Trail"]
  Command → ["Search", "Command-Palette"]
  Pagination → ["Table", "List", "Gallery"]
}
```

### Task Group J: Pattern Relations

#### J1. Composition Pattern
```poml
Composition_Pattern {
  @description: "Building complex components from simple ones"
  @examples: ["Card", "Dialog", "Form"]
  @benefits: ["Flexibility", "Reusability", "Maintainability"]
  @implementation: {
    Card: ["CardHeader", "CardContent", "CardFooter"]
    Dialog: ["DialogTrigger", "DialogContent", "DialogHeader"]
    Form: ["FormField", "FormItem", "FormControl", "FormMessage"]
  }
}
```

#### J2. Variant Pattern
```poml
Variant_Pattern {
  @tool: "class-variance-authority"
  @examples: ["Button", "Badge", "Alert"]
  @implementation: "cva() function"
  @benefits: ["Type-safety", "Consistency", "Predictability"]
  @see_also: ["Theming", "Styling"]
}
```

### Task Group K: Framework Relations

#### K1. Next.js Relations
```poml
Next_js {
  @components: "All"
  @dark_mode: "next-themes"
  @routing: "App Router | Pages Router"
  @deployment: "Vercel"
  @ssr: true
  @see_also: ["React-Server-Components", "Edge-Runtime"]
}
```

#### K2. Vite Relations
```poml
Vite {
  @components: "All"
  @build: "Rollup"
  @dev_server: "ESBuild"
  @spa: true
  @see_also: ["React-Router", "Client-Side-Routing"]
}
```

### Task Group L: Registry Relations

#### L1. MCP Server Relations
```poml
MCP_Server {
  @tools: [
    "get_project_registries",
    "list_items_in_registries",
    "search_items_in_registries",
    "view_items_in_registries",
    "get_item_examples_from_registries",
    "get_add_command_for_items",
    "get_audit_checklist"
  ]
  @workflow: "List → Search → View → Add"
  @see_also: ["CLI", "Registry-System"]
}
```

#### L2. CLI Relations
```poml
CLI {
  @commands: ["init", "add", "diff", "update", "view", "search", "build"]
  @workflow: "Init → Add → Customize"
  @config: "components.json"
  @see_also: ["MCP-Server", "Manual-Installation"]
}
```

---

## VALIDATION TASKS (Phase 3)

### Task Group M: Bidirectional Validation
```
M1. Verify all @depends_on have corresponding @used_by
M2. Verify all @alternatives are mutual
M3. Verify all @see_also are reciprocal
M4. Verify workflow chains are complete
M5. Verify no orphaned references
```

### Task Group N: Navigation Path Testing
```
N1. Test: New user → First component
N2. Test: Component selection → Implementation
N3. Test: Problem → Solution finding
N4. Test: Framework migration path
N5. Test: Customization workflow
```

### Task Group O: Completeness Check
```
O1. All 48 components have relations
O2. All blocks have component lists
O3. All patterns have examples
O4. All workflows have complete paths
O5. All utilities have usage examples
```

---

## EXECUTION ORDER

### Priority 1 (Do First - Core Navigation)
- [ ] A1-A6: Section Inventory
- [ ] B1-B6: Dependency Mapping
- [ ] E1-E5: Core Component Relations (Button, Dialog, Form, Table, Card)

### Priority 2 (Foundation)
- [ ] C1-C6: Workflow Mapping
- [ ] F1-F2: Workflow Relations
- [ ] H1-H2: Utility Relations

### Priority 3 (Comprehensive Coverage)
- [ ] D: Apply template to remaining 43 components
- [ ] G1-G2: Block Relations
- [ ] I1-I3: Cross-References

### Priority 4 (Enhancement)
- [ ] J1-J2: Pattern Relations
- [ ] K1-K2: Framework Relations
- [ ] L1-L2: Registry Relations

### Priority 5 (Quality Assurance)
- [ ] M1-M5: Bidirectional Validation
- [ ] N1-N5: Navigation Testing
- [ ] O1-O5: Completeness Check

---

## Time Estimate

- Phase 1 (Analysis): 2 hours
- Phase 2 (Implementation): 6 hours
- Phase 3 (Validation): 1 hour

**Total: 9 hours of focused work**

---

## Next Immediate Action

Start with Task A1: Read POML and create the section inventory list.