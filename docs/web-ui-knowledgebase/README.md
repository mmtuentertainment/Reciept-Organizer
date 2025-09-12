# Web UI Development Knowledgebase

## 📚 Purpose
This knowledgebase provides comprehensive guidance for developing the Receipt Organizer web application using shadcn/ui components, optimized for Claude Code consumption.

## 🗂️ Directory Structure

```
web-ui-knowledgebase/
├── README.md                          # This file - Quick navigation guide
├── CLAUDE_CONTEXT.md                  # Optimized context for Claude Code
├── 01-quick-reference.md              # Essential commands and patterns
├── 02-component-registry.poml         # Complete component documentation
├── 03-implementation-workflows.md     # Step-by-step implementation guides
├── 04-receiptorganizer-components.md  # App-specific component mappings
└── 05-validation-checklist.md         # Quality assurance and testing
```

## 🚀 Quick Start for Claude Code

When starting any web UI task, reference these files in order:
1. **CLAUDE_CONTEXT.md** - Load this first for optimal context
2. **01-quick-reference.md** - Quick lookup for commands and patterns
3. **02-component-registry.poml** - Full component details when needed
4. **04-receiptorganizer-components.md** - App-specific implementations

## 🎯 Key Use Cases

### Building Landing Page
- Reference: `04-receiptorganizer-components.md` → Landing Page section
- Components needed: Hero, Features, Pricing, Testimonials
- Images available: `/apps/web/public/images/`

### Adding Dashboard
- Reference: `02-component-registry.poml` → Dashboard_Blocks
- Components: Sidebar, Card, Chart, Table, Stats
- Patterns: Layout, Data Display, Navigation

### Form Implementation
- Reference: `03-implementation-workflows.md` → Form Workflow
- Stack: React Hook Form + Zod + shadcn Form
- Components: Form, Input, Select, Button, Toast

## 🛠️ Technology Stack

### Core Technologies
- **Framework**: Next.js 15.5.2 (apps/web)
- **UI Library**: shadcn/ui (copy-paste components)
- **Styling**: Tailwind CSS v4
- **Validation**: Zod + React Hook Form
- **Icons**: Lucide React
- **Themes**: CSS variables with dark mode

### Available Tools
- **CLI**: `npx shadcn@latest [command]`
- **MCP Server**: 7 registry tools for component discovery
- **Development**: Component-driven with hot reload

## 📊 Component Categories

| Category | Count | Primary Use |
|----------|-------|-------------|
| UI Components | 48 | Core interface elements |
| Dashboard Blocks | 10 | Pre-built dashboard layouts |
| Sidebar Variants | 16 | Navigation patterns |
| Chart Types | 79 | Data visualization |
| Form Components | 12 | User input and validation |
| Authentication | 10 | Login/signup flows |

## 🔄 Workflow Commands

```bash
# Initialize shadcn in web app
cd apps/web
npx shadcn@latest init

# Add components
npx shadcn@latest add button card form

# Check for updates
npx shadcn@latest diff [component]

# Update components
npx shadcn@latest update [component]
```

## 🎨 Receipt Organizer Brand

### Colors (from landing page designs)
- Primary: #2563EB (blue)
- Background: #F3F4F6 (light gray)
- Text: #111827 (dark gray)
- Success: #10B981 (green)
- Error: #EF4444 (red)

### Key Features to Implement
1. Receipt capture and OCR visualization
2. Analytics dashboard
3. Export workflow UI
4. Integration ecosystem display
5. Security features showcase

## 📝 Notes for Claude Code

- This knowledgebase is optimized for the Receipt Organizer project
- All paths are relative to `/home/matt/FINAPP/Receipt Organizer/`
- The web app is located in `apps/web/`
- Landing page images are in `apps/web/public/images/`
- Use POML format for structured component documentation
- Prioritize offline-first, privacy-focused features

## 🔗 Related Documentation

- Main project: `/CLAUDE.md`
- Architecture: `/docs/sharded-architecture/`
- PRD: `/docs/sharded-prd/`
- API: `/apps/api/`

---
*Last Updated: 2025-01-12*
*Optimized for Claude Code v1.0+*