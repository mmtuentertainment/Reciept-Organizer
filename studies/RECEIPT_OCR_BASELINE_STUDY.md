# Receipt OCR Field-Level Baseline Study
## Primary Research Protocol Implementation

**CRITICAL EVIDENCE GAP IDENTIFIED**: Literature review of 4+ sources revealed **NO published field-specific precision/recall metrics** for receipt OCR extraction (merchant, date, total, tax).

**STATUS**: Primary research protocol **APPROVED** - proceeding with implementation.

---

## 📊 **STUDY OVERVIEW**

### Research Objective
Establish empirically-grounded precision/recall baselines for receipt OCR field extraction to replace fabricated Project Brief targets (45% fabrication rate identified).

### Sample Requirements
- **Target Size**: 400+ receipts
- **Confidence**: 95% (±3% margin of error)
- **Quality Control**: ≥90% inter-annotator agreement

---

## 🏗️ **PHASE 1: RECRUITMENT & SETUP** ⚡ *IN PROGRESS*

### Annotation Team Recruitment Specification

#### **Team Composition Required**
```
Role                    | Count | Qualifications                    | Compensation
------------------------|-------|-----------------------------------|---------------
Lead Annotator         |   1   | OCR experience, quality control   | $25/hour
Senior Annotators      |   2   | Data labeling experience         | $18/hour  
Junior Annotators      |   3   | Detail-oriented, trained         | $15/hour
Quality Validator      |   1   | Statistical background           | $22/hour
```

#### **Recruitment Channels**
1. **Upwork/Freelancer**: OCR data labeling specialists
2. **University Partnerships**: Graduate students in CS/Data Science  
3. **Amazon MTurk**: Qualified workers (HIT approval ≥95%)
4. **Internal Team**: If available resources

#### **Screening Criteria**
- **Experience**: Minimum 100+ hours data annotation
- **OCR Knowledge**: Familiar with text extraction challenges
- **Attention to Detail**: Pass 10-receipt qualification test
- **Availability**: 20+ hours/week for 4-week study

### **PILOT STUDY SETUP** (Week 1)

#### **Pilot Sample Selection**
```
Store Type          | Pilot Count | Full Study Target
--------------------|-------------|-------------------
Grocery            |     12      |       100
Restaurant         |     10      |        80
Retail             |      8      |        60
Gas Station        |      8      |        60  
Pharmacy           |      6      |        40
Coffee Shop        |      6      |        40
E-receipts         |      0      |        20
PILOT TOTAL:       |     50      |       400
```

#### **Quality Gates for Pilot**
1. **Inter-annotator Agreement**: ≥90% exact match required
2. **Completion Time**: <5 minutes per receipt average
3. **Error Pattern Analysis**: Document systematic issues
4. **Rubric Refinement**: Update based on edge cases found

---

## 📋 **DETAILED ANNOTATION PROTOCOL**

### **Receipt Collection Strategy**

#### **Source Diversification**
```
Collection Method     | Target % | Rationale
---------------------|----------|------------------
Team Member Receipts |    40%   | Quick access, diverse stores
Public Datasets      |    30%   | SROIE, CORD (re-annotation)
Crowdsourced Photos  |    20%   | Real user conditions  
Generated/Synthetic  |    10%   | Edge case coverage
```

#### **Geographic Distribution**
- **Primary Market**: North America (80%)
- **International**: Europe/Asia (20%) for format diversity
- **Language**: English-dominant with multilingual subset

### **Field Extraction Annotation Standards**

#### **MERCHANT/COMPANY NAME Annotation**

**POSITIVE EXAMPLES:**
```
✅ "McDonald's Restaurant #1234"
✅ "WAL-MART SUPERCENTER"  
✅ "Target Corp"
✅ "Shell Oil Company"
```

**NEGATIVE EXAMPLES:**  
```
❌ "123 Main Street" (address, not name)
❌ "Thank You For Shopping" (message, not name)
❌ "Manager: John Smith" (person, not company)
```

**EDGE CASE RULES:**
- If multiple business names present → Select topmost/largest
- Include legal suffixes (LLC, Inc, Corp) when present
- Exclude store numbers unless part of brand name
- Abbreviations acceptable if clear (McDonald's vs McDonalds)

#### **DATE Field Annotation**

**ACCEPTABLE FORMATS:**
```
✅ 12/25/2024, 25/12/2024, 2024-12-25
✅ Dec 25, 2024
✅ 25-DEC-24
✅ 12.25.24
```

**DISAMBIGUATION RULES:**
- Transaction date NOT receipt print date
- If multiple dates → Use transaction/sale date
- Time stamps acceptable but not required
- Invalid dates (02/30/2024) → Mark as extraction error

#### **TOTAL AMOUNT Annotation**

**EXTRACTION REQUIREMENTS:**
```
✅ Include currency symbol: $45.67
✅ Final charged amount (post-tax, post-discount)  
✅ Handle multiple formats: $45.67, 45,67€, ¥4567
✅ Zero amounts acceptable: $0.00
```

**PRECISION REQUIREMENTS:**
- **Exact match required** (no partial credit)
- Must include decimal places when present
- Currency symbol inclusion preferred but not required
- Leading zeros acceptable: $045.67 = $45.67

#### **TAX AMOUNT Annotation**

**INCLUSION CRITERIA:**
```
✅ Sales Tax, VAT, GST, Service Tax
✅ Multiple tax types combined if clearly summed
✅ Zero tax amounts: $0.00 TAX
```

**EXCLUSION CRITERIA:**
```
❌ Tips/Gratuity (not government tax)
❌ Fees (delivery, service fees)  
❌ Discounts (negative amounts)
❌ Tax-exempt transactions (mark N/A)
```

---

## 📊 **EVALUATION METRICS & SCORING**

### **Precision/Recall Calculation**

```python
# Field-Level Evaluation Formula
precision = true_positives / (true_positives + false_positives)
recall = true_positives / (true_positives + false_negatives)  
f1_score = 2 * (precision * recall) / (precision + recall)

# Error Type Classification
MISS = field_not_detected           # Impacts Recall
MISREAD = wrong_text_extracted      # Impacts Precision  
MISPLACED = text_in_wrong_field     # Impacts Both
FORMAT_ERROR = correct_but_wrong_format  # Impacts Precision
```

### **Partial Scoring Matrix**

```
Field Type     | Exact Match | Partial Credit Rules
---------------|-------------|---------------------
Merchant       |    1.0      | 0.8 if core name correct, suffix wrong
Date          |    1.0      | 0.5 if MM/DD transposed, 0.8 if ±1 day
Total         |    1.0      | 0.0 (exact match required)
Tax           |    1.0      | 0.0 (exact match required)
```

### **Quality Control Checkpoints**

#### **Daily Metrics Tracking**
- Inter-annotator agreement per field type
- Average annotation time per receipt  
- Error pattern frequency analysis
- Annotator performance consistency

#### **Weekly Review Process**  
1. **Consensus Meeting**: Resolve annotation disagreements
2. **Rubric Updates**: Document new edge cases and rules
3. **Progress Assessment**: Sample size and quality gates
4. **Error Analysis**: Systematic vs. random error patterns

---

## 📈 **STATISTICAL ANALYSIS PLAN**

### **Power Analysis Validation**
```
Current Sample: 400 receipts
Expected Accuracy: 85-95% per field
Confidence Level: 95%
Margin of Error: ±3%
Power: >80% to detect 5% accuracy differences
```

### **Baseline Calculation Method**

#### **Primary Metrics**
```
Field_Precision = Correctly_Extracted / Total_Extraction_Attempts
Field_Recall = Correctly_Extracted / Total_Fields_Present  
Field_F1 = 2 * (Precision * Recall) / (Precision + Recall)
```

#### **Secondary Metrics**
```  
Miss_Rate = Fields_Not_Detected / Total_Fields_Present
Misread_Rate = Wrong_Text_Extracted / Total_Extraction_Attempts
Format_Error_Rate = Format_Errors / Total_Extractions
```

#### **Confidence Intervals**
- **Bootstrap Method**: 1000 resamples for CI estimation
- **Stratified Analysis**: By store type, image quality, receipt format
- **Sensitivity Analysis**: Impact of annotation disagreements

---

## ⚠️ **RISK MITIGATION STRATEGIES**

### **Data Quality Risks**

#### **Annotator Drift Prevention**
- **Daily Calibration**: Review 5 receipts as team
- **Blind Validation**: 10% random re-annotation  
- **Performance Monitoring**: Flag consistency drops >10%
- **Refresher Training**: Weekly rubric reinforcement

#### **Sample Bias Mitigation**
- **Geographic Diversity**: Multi-region collection
- **Format Variety**: Include thermal, laser, mobile POS receipts
- **Quality Stratification**: 25% challenging/poor quality images
- **Temporal Spread**: Recent receipts (2023-2024) only

### **External Validity Threats**

#### **Domain Generalization**
- **Store Type Coverage**: 7 categories minimum
- **Regional Formats**: Include non-US receipt layouts
- **Seasonal Variation**: Include holiday/sale receipts
- **OCR Engine Testing**: Validate on Google Vision, AWS, PaddleOCR

#### **Real-World Alignment**
- **Mobile Photo Conditions**: Include shadows, angles, blur
- **Receipt Age Factors**: Faded thermal receipts
- **Multi-language Content**: Bilingual receipts when available

---

## 🎯 **SUCCESS CRITERIA & DELIVERABLES**

### **Study Success Gates**
1. **Sample Size**: ≥400 receipts with required stratification
2. **Quality**: ≥90% inter-annotator agreement sustained  
3. **Completeness**: All 4 fields annotated for all receipts
4. **Validation**: Statistical significance achieved (p<0.05)

### **Final Deliverables**

#### **Evidence-Backed Baseline Table**
```
Field            | Precision | Recall | F1 Score | 95% CI    | Sample Size
-----------------|-----------|--------|----------|-----------|------------
Merchant Name    |   [TBD]   | [TBD]  |  [TBD]   | [TBD]     |    400
Date            |   [TBD]   | [TBD]  |  [TBD]   | [TBD]     |    400  
Total Amount    |   [TBD]   | [TBD]  |  [TBD]   | [TBD]     |    400
Tax Amount      |   [TBD]   | [TBD]  |  [TBD]   | [TBD]     |    300*
```
*Tax not present on all receipts

#### **Production-Ready Accuracy Targets**
```
Field            | Conservative | Target | Stretch
-----------------|-------------|--------|--------  
Merchant Name    |    [TBD]    | [TBD]  | [TBD]
Date            |    [TBD]    | [TBD]  | [TBD]
Total Amount    |    [TBD]    | [TBD]  | [TBD]  
Tax Amount      |    [TBD]    | [TBD]  | [TBD]
```

#### **Error Analysis Report**
- **Common Failure Patterns**: Systematic error documentation  
- **OCR Engine Comparison**: Performance across providers
- **Quality Impact Analysis**: How image quality affects accuracy
- **External Validity Assessment**: Generalizability limitations

---

## 📅 **IMPLEMENTATION TIMELINE**

```
Phase                    | Duration | Key Milestones
-------------------------|----------|------------------
Team Recruitment        |  Week 1  | Annotators hired, trained
Pilot Study             |  Week 2  | 50 receipts, rubric validated  
Full Study Collection   |  Week 3-4| 400 receipts annotated
Quality Validation      |  Week 5  | Inter-annotator agreement confirmed
Statistical Analysis    |  Week 6  | Baseline calculations complete
Report & Integration    |  Week 7  | Evidence-backed targets established
```

**CRITICAL PATH**: This study **MUST complete** before architectural OCR implementation decisions.

---

## 🚀 **IMMEDIATE NEXT ACTIONS**

### **THIS WEEK - RECRUITMENT LAUNCH**
1. ✅ **Study Protocol Approved** - Ready for execution
2. 🔄 **Post Upwork/Freelancer Jobs** - OCR annotation specialists  
3. 🔄 **University Outreach** - Graduate student partnerships
4. 🔄 **Internal Resource Assessment** - Available team capacity
5. 🔄 **Pilot Receipt Collection** - Begin gathering diverse samples

### **SUCCESS TRACKING**
- **Daily**: Recruitment pipeline progress
- **Weekly**: Pilot study quality gates  
- **Bi-weekly**: Full study progress against timeline

**This primary research will provide the evidence-backed field-level baselines needed to replace the fabricated accuracy targets identified in the 45% fabrication audit.**

---

*Next Update: Weekly progress report on recruitment and pilot study initiation.*