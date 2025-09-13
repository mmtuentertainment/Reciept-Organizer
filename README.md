# Receipt Organizer MVP

A Flutter-based receipt management application for small businesses, providing offline-first OCR processing and CSV export capabilities.

## Quick Start

```bash
# Mobile app development
cd apps/mobile
flutter test test/core_tests/ test/integration_tests/  # Run tests
flutter run                                             # Run app

# API development
cd apps/api
npm run dev                                            # Start API
```

## Documentation Structure

### Core Documentation
- [`CLAUDE.md`](./CLAUDE.md) - AI assistant instructions and development guidelines
- [`PROJECT_STATUS.md`](./PROJECT_STATUS.md) - Current project state and next steps
- [`project_brief_mom_and_pop_receipt_organizer_mvp_v_1.md`](./project_brief_mom_and_pop_receipt_organizer_mvp_v_1.md) - Original MVP specification

### Architecture & Technical Docs
- [`docs/sharded-architecture/`](./docs/sharded-architecture/) - Complete technical architecture
  - [Tech Stack](./docs/sharded-architecture/tech-stack.md) - Technology decisions
  - [Database Schema](./docs/sharded-architecture/database-schema.md) - Data layer design
  - [Frontend Architecture](./docs/sharded-architecture/frontend-architecture.md) - Flutter app structure
  - [High Level Architecture](./docs/sharded-architecture/high-level-architecture.md) - System overview

### Product Requirements
- [`docs/sharded-prd/`](./docs/sharded-prd/) - Product requirements in POML format
- [`docs/stories/`](./docs/stories/) - User stories (1.1 through 3.12)
- [`docs/epics/`](./docs/epics/) - Epic definitions

### Quality Assurance
- [`docs/qa/`](./docs/qa/) - QA gates and assessments
- [`apps/mobile/test/SIMPLIFIED_TEST_STRATEGY.md`](./apps/mobile/test/SIMPLIFIED_TEST_STRATEGY.md) - 15-test strategy

## Project Structure

```
Receipt Organizer/
├── apps/
│   ├── mobile/          # Flutter app (main codebase)
│   ├── api/             # Next.js/Vercel API
│   └── web/             # Web frontend
├── docs/
│   ├── sharded-architecture/  # Technical architecture
│   ├── sharded-prd/           # Product requirements
│   ├── stories/               # User stories
│   ├── epics/                 # Epic definitions
│   ├── qa/                    # Quality assurance
│   ├── integration/           # Integration guides
│   └── testing/               # Testing guides
└── .bmad-core/          # BMad methodology files
```

## Current Status

- ✅ Flutter 3.35.3 migration complete
- ✅ Simplified test suite (15 critical tests)
- ✅ Offline-first architecture with cloud-ready interfaces
- 🚧 Story 3.12 - Export validation blocking issue
- 📋 Next: Track 1 - Test infrastructure interfaces
- 📋 Next: Track 2 - Cloud infrastructure (Supabase)

## Development

This project uses Flutter for mobile development and follows an offline-first architecture with progressive cloud enhancement.

For detailed development instructions, see [`CLAUDE.md`](./CLAUDE.md).