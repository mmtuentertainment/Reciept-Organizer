# Project Brief — Mom‑and‑Pop Receipt Organizer (MVP v1.0)

## Problem Statement
Owner‑operators and very small businesses struggle to capture, organize, and export receipts in a bookkeeping‑ready format. Competing apps routinely over‑promise OCR accuracy and under‑deliver on the correction and export experience, leading to:
- Frequent edge‑detection failures and misreads (merchant, date, total, tax)
- High manual correction overhead per receipt
- CSV exports rejected by accounting tools due to format/field mismatches
- Sync/upload fragility; users want offline reliability and simple, honest workflows

**First‑principles take:** Users don’t need “perfect OCR”; they need a fast, trustworthy *assist* that makes corrections trivial and exports pass on the first try.

---

## Target Users
- **Owner‑operators / Mom‑and‑Pop** businesses (non‑technical, time‑poor)
- **Solo bookkeepers** managing 100–500 receipts/month
- **Accountants** who request clean CSVs that import without rework

Primary device: Mobile (camera capture). Secondary: Desktop/web drag‑drop for scanned PDFs.

---

## Success Metrics (v1 acceptance bars)
- **Capture→Extract latency:** ≤ **5s p95** on target mid‑tier devices
- **Field accuracy after capture (with manual crop):** Total ≥ **95%**, Date ≥ **95%**, Merchant ≥ **90%**, Tax ≥ **85%** on a 50‑receipt test set
- **Zero‑touch happy path:** ≥ **70%** of clear photos require no edits
- **Export pass rate:** ≥ **99%** of exports pass **QuickBooks** and **Xero** CSV validators on first attempt
- **Offline reliability:** Full capture/edit/export without network; background sync optional later
- **Stability:** Crash‑free sessions ≥ **99.5%** over one week of beta

---

## MVP Scope (what we will build now)
1. **Smart Edge Detection + Manual Override**  
   Auto‑crop with quick handles; adjust boundaries in ≤3 taps when auto fails.
2. **Confidence‑Based OCR with Quick Edit (4 fields)**  
   Extract **Merchant, Date, Total, Tax**. Highlight low‑confidence fields; 1‑tap in‑place edit.
3. **Basic Vendor Normalization**  
   Case/punctuation cleanup + suffix removal (Inc/LLC/Corp) + simple alias table ("McDonald’s #123" → "McDonald’s").
4. **Pre‑Flight CSV Validation + Templates**  
   Built‑in CSV schemas for **QuickBooks Online** and **Xero** (v1), with inline error messages before export.
5. **Offline‑First Local Storage**  
   All data local by default; privacy copy and redacted logs.
6. **Batch Capture & Simple Organizing Aids**  
   Multi‑capture queue, basic categories, notes, and search.

**Deliverables:** Mobile app (camera capture), minimal web drag‑drop, export utility, vendor‑template CSV schemas, acceptance tests & privacy copy.

---

## Constraints (what we will NOT do in v1)
- **No cloud accounts / multi‑user sync / real‑time collaboration**
- **No bank/ERP integrations** (CSV export only)
- **No line‑item extraction** (totals only in v1)
- **No complex approvals/workflows**
- **No heavy ML training**; use proven on‑device OCR + deterministic rules; consider a tiny on‑device model only if it stays below app size & latency budgets
- **Device matrix limited** to one Android (e.g., Pixel 6) and one iPhone (e.g., iPhone 12) for acceptance
- **KISS / YAGNI / DIW:** Each change must be reversible, minimal, and measured against the acceptance bars above

---

### Notes for PRD handoff
- Treat CSV as a **contract**: publish schemas (columns, types, examples) and validate pre‑export
- Ship an **honest OCR UX** (visible confidence + fast correction) rather than chasing perfect automation
- Keep the backlog for v1.1+: line‑items, cloud sync, additional vendor templates (Wave, Zoho, FreshBooks), email‑in

