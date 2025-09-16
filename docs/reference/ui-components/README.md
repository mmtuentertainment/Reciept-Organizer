# Web UI Development Knowledgebase for Receipt Organizer

## 📁 Directory Path
```
/home/matt/FINAPP/Receipt Organizer/docs/web-ui-knowledgebase/
```

## 📚 Purpose
This knowledgebase contains comprehensive documentation for developing the Receipt Organizer web application using shadcn/ui components. It's optimized for Claude Code to quickly understand and implement UI features.

## 🗂️ Files in this Directory

1. **README.md** - This navigation file
2. **CLAUDE_CONTEXT.poml** - Essential context for Claude Code (LOAD FIRST)
3. **01-quick-reference.poml** - Quick commands and patterns
4. **02-component-registry.poml** - Complete shadcn component documentation
5. **03-implementation-workflows.poml** - Step-by-step implementation guides
6. **04-receiptorganizer-components.poml** - App-specific component mappings
7. **05-validation-checklist.poml** - Quality assurance checklist

## 🚀 Quick Start

For Claude Code, load files in this order:
1. First: `CLAUDE_CONTEXT.poml` - Essential project context
2. Second: `01-quick-reference.poml` - Commands you'll need
3. As needed: Other files for specific implementations

## 🛠️ Technology Stack

- **Framework**: Next.js 15.5.2
- **UI Library**: shadcn/ui (copy-paste components)
- **Styling**: Tailwind CSS v4
- **Validation**: Zod + React Hook Form
- **Location**: `/apps/web/`

## 🎯 Key Features to Build

### Landing Page (Priority 1)
- Hero section with product mockup
- Features grid
- Pricing table
- Testimonials
- Integration ecosystem display

### Dashboard (Priority 2)
- Sidebar navigation
- Stats cards
- Receipt table
- Analytics charts
- Export controls

### Forms (Priority 3)
- Receipt upload
- Export configuration
- Settings panels
- Authentication

## 📝 Essential Commands

```bash
# From apps/web directory:
npx shadcn@latest init              # Initialize shadcn
npx shadcn@latest add button card   # Add components
npm run dev                          # Start dev server
npm run build                        # Production build
```

## 🎨 Brand Colors

- Primary: `#2563EB` (blue)
- Background: `#F3F4F6` (light gray)
- Text: `#111827` (dark gray)
- Success: `#10B981` (green)
- Error: `#EF4444` (red)

## 📍 Important Paths

- Web App: `/home/matt/FINAPP/Receipt Organizer/apps/web/`
- Components: `/apps/web/components/ui/`
- Images: `/apps/web/public/images/` (15 landing page images ready)
- This Knowledgebase: `/docs/web-ui-knowledgebase/`

## ✅ Next Steps

1. Navigate to `/apps/web/`
2. Run `npx shadcn@latest init`
3. Start adding components for landing page
4. Reference the POML files in this directory for detailed guidance

---
*Optimized for Claude Code v1.0+*
*Last Updated: 2025-01-12*