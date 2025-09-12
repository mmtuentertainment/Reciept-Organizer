# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Receipt Organizer MVP** project focused on building a mom-and-pop business receipt capture, OCR, and CSV export application. The project is now in **active development** with a Flutter mobile app, API backend, and cloud infrastructure.

## Project Architecture

### Core Requirements
- **Target Users**: Owner-operators, mom-and-pop businesses, solo bookkeepers managing 100-500 receipts/month
- **Offline-First**: All processing must work without network connectivity
- **Core Workflow**: Photo capture → OCR extraction → CSV export
- **Key Fields**: Merchant, Date, Total, Tax (4 fields only for MVP)

### Technical Stack (Recommended)
Based on comprehensive research in `COMPREHENSIVE_FEASIBLE_TECH_STACK_RECOMMENDATION_2025.md`:

- **Frontend**: Flutter (cross-platform mobile)
- **OCR Engine**: PaddleOCR (local processing, 89-92% accuracy target)
- **Image Processing**: OpenCV (edge detection, preprocessing)
- **Database**: RxDB (offline-first, reactive)
- **CSV Generation**: Papa Parse (RFC 4180 compliant)
- **Background Processing**: BullMQ (async job processing)

### Success Metrics
From `project_brief_mom_and_pop_receipt_organizer_mvp_v_1.md`:

- **Capture→Extract latency**: ≤ 5s p95
- **Field accuracy**: Total ≥ 95%, Date ≥ 95%, Merchant ≥ 90%, Tax ≥ 85%
- **Zero-touch happy path**: ≥ 70% require no edits
- **CSV export pass rate**: ≥ 99% pass QuickBooks/Xero validators
- **Offline reliability**: Full functionality without network
- **Stability**: ≥ 99.5% crash-free sessions

## File Organization

### Core Documents
- `project_brief_mom_and_pop_receipt_organizer_mvp_v_1.md` - Primary MVP specification
- `COMPREHENSIVE_FEASIBLE_TECH_STACK_RECOMMENDATION_2025.md` - Detailed architecture analysis

### Research & Analysis
- `analysis/` - Evidence audits and compatibility specifications
  - `EVIDENCE_BACKED_REQUIREMENTS.md` - Fact-checked requirements analysis
  - `CSV_COMPATIBILITY_ANALYSIS.md` - QuickBooks/Xero compatibility specs
- `studies/` - Research protocols
  - `RECEIPT_OCR_BASELINE_STUDY.md` - OCR accuracy measurement methodology
- `research/` - Market analysis and supporting data
  - `Receipt_Organizer_Evidence_Based_MVP_2025.md` - MVP analysis
  - `receipt_organizer_analysis_2025.json` - Structured research findings

## Development Constraints

### What we WILL build (MVP Scope)
1. Smart edge detection with manual override
2. Confidence-based OCR with quick edit (4 fields only)
3. Basic vendor normalization
4. Pre-flight CSV validation with templates
5. Offline-first local storage
6. Batch capture and simple organizing aids

### What we will NOT build (v1)
- Cloud accounts/multi-user sync
- Bank/ERP integrations
- Line-item extraction
- Complex approvals/workflows
- Heavy ML training
- Multi-device support beyond one Android and one iPhone

## Key Principles

1. **KISS/YAGNI/DIW**: Each change must be reversible, minimal, and measured
2. **Offline-First**: All functionality must work without internet
3. **Evidence-Based**: All technical decisions backed by research data
4. **CSV as Contract**: Publish schemas and validate pre-export
5. **Honest OCR UX**: Visible confidence scores + fast correction over perfect automation

## CRITICAL: Test Suite Management

### ⚠️ IMPORTANT: Simplified Test Strategy (15 Tests Only)
**DO NOT ADD MORE TESTS WITHOUT EXPLICIT DISCUSSION**

This project uses a **minimal test strategy** following the CleanArchitectureTodoApp pattern:
- **Original**: 571 tests (way too many, 131 failing)
- **Current**: 15 critical tests only
- **Location**: `apps/mobile/test/`
- **Strategy**: See `apps/mobile/test/SIMPLIFIED_TEST_STRATEGY.md`

#### The 15 Critical Tests:
1. **Core Tests** (`test/core_tests/`):
   - Receipt repository operations
   - CSV export functionality
   - App launch verification

2. **Integration Tests** (`test/integration_tests/`):
   - Critical user flows only
   - Capture → OCR → Export workflow

### Why Only 15 Tests?
- Industry best practice: Most successful Flutter apps have 50-200 tests, not 500+
- CleanArchitectureTodoApp (a reference implementation) uses only 12 tests
- Maintenance burden of 571 tests was unsustainable
- Focus on critical business logic, not edge cases

### Before Adding ANY Test:
1. Read `apps/mobile/test/SIMPLIFIED_TEST_STRATEGY.md`
2. Justify why it's critical for MVP
3. Consider if existing tests already cover it
4. Get explicit approval in the conversation

## Getting Started

When beginning development:
1. Review the project brief for core requirements
2. Check the tech stack recommendation for architectural guidance  
3. Reference the evidence-backed requirements to avoid fabricated assumptions
4. Use the CSV compatibility analysis for export format specifications
5. Follow the OCR baseline study for accuracy measurement protocols

### Build & Test Commands
```bash
# Flutter app (from apps/mobile/)
flutter test test/core_tests/ test/integration_tests/  # Run ONLY the 15 critical tests
flutter run                                             # Run the app

# API (from apps/api/)
npm run dev                                            # Start development server
npm run build                                          # Build for production
```
- doc-out
- risk