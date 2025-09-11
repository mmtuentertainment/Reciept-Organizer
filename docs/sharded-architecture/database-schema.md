# Database Schema

```poml
SECTION_METADATA:
  type: "database_specification"
  section_number: 9
  focus: "SQLite database design and optimization"
  performance_approach: "Denormalized for query speed, normalized for integrity"

DATABASE_ARCHITECTURE:
  primary_engine: "SQLite 3.x"
  access_layer: "sqflite package for Flutter"
  settings_store: "Hive for key-value preferences"
  state_management: "Riverpod for reactive updates"
  optimization_strategy: "Strategic denormalization for mobile performance"
  
DESIGN_PRINCIPLES:
  mobile_optimization: "Minimize JOIN operations for performance"
  offline_first: "Complete functionality without network"
  data_integrity: "Constraints and validation at database level"
  query_performance: "Indexes on all frequently queried fields"
  storage_efficiency: "Compression and cleanup strategies"
```

## SQLite Database Schema

```poml
DATABASE_TABLES:
  core_entities:
    receipts: "Primary entity with denormalized OCR results"
    export_batches: "CSV export tracking and metadata"
    app_settings: "Application configuration and preferences"
  
  design_rationale:
    denormalization: "OCR results embedded in receipts table for performance"
    indexing_strategy: "Cover indexes for common query patterns"
    soft_deletes: "Maintain data integrity with is_deleted flags"
    versioning: "Optimistic locking with version numbers"
```

### receipts

```poml
RECEIPTS_TABLE:
  purpose: "Core entity storing receipt data with denormalized OCR results"
  performance_rationale: "Denormalized for mobile query performance"
  storage_approach: "Primary data with embedded processing results"
  
PRIMARY_FIELDS:
  identity: ["id", "version"]
  content: ["image_uri", "thumbnail_uri", "notes"]
  metadata: ["captured_at", "last_modified", "created_at", "updated_at"]
  status: ["status", "is_deleted"]
  
DENORMALIZED_OCR_FIELDS:
  merchant: ["merchant_name", "merchant_confidence", "merchant_edited"]
  date: ["receipt_date", "date_confidence", "date_edited"]  
  total: ["total_amount", "total_confidence", "total_edited"]
  tax: ["tax_amount", "tax_confidence", "tax_edited"]
  processing: ["overall_confidence", "processing_engine", "processing_duration_ms"]
  
DEVICE_METADATA:
  device_info: ["device_model", "os_version", "app_version"]
  image_info: ["image_original_size", "image_compressed_size"]
```

```sql
CREATE TABLE receipts (
    id TEXT PRIMARY KEY,
    image_uri TEXT NOT NULL,
    thumbnail_uri TEXT,
    captured_at INTEGER NOT NULL, -- Unix timestamp
    status TEXT NOT NULL CHECK(status IN ('captured', 'processing', 'ready', 'exported', 'error')),
    last_modified INTEGER NOT NULL,
    notes TEXT,
    is_deleted INTEGER DEFAULT 0,
    version INTEGER DEFAULT 1,
    
    -- Denormalized processing results for query performance
    merchant_name TEXT,
    merchant_confidence REAL,
    merchant_edited INTEGER DEFAULT 0,
    
    receipt_date TEXT, -- ISO 8601 format
    date_confidence REAL,
    date_edited INTEGER DEFAULT 0,
    
    total_amount REAL,
    total_confidence REAL,
    total_edited INTEGER DEFAULT 0,
    
    tax_amount REAL,
    tax_confidence REAL,
    tax_edited INTEGER DEFAULT 0,
    
    overall_confidence REAL,
    processing_engine TEXT,
    processing_duration_ms INTEGER,
    
    -- Metadata
    device_model TEXT,
    os_version TEXT,
    app_version TEXT,
    image_original_size INTEGER,
    image_compressed_size INTEGER,
    
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
```

```poml
RECEIPTS_INDEXES:
  performance_indexes:
    - name: "idx_receipts_captured_at"
      columns: ["captured_at DESC"]
      purpose: "Recent receipts query (primary use case)"
    
    - name: "idx_receipts_status"  
      columns: ["status"]
      condition: "WHERE is_deleted = 0"
      purpose: "Filter by processing status"
    
    - name: "idx_receipts_receipt_date"
      columns: ["receipt_date"]
      condition: "WHERE is_deleted = 0"
      purpose: "Date range queries for export"
    
    - name: "idx_receipts_merchant"
      columns: ["merchant_name"]
      condition: "WHERE is_deleted = 0" 
      purpose: "Merchant grouping and search"
    
    - name: "idx_receipts_overall_confidence"
      columns: ["overall_confidence"]
      purpose: "Low confidence receipt identification"
    
    - name: "idx_receipts_deleted"
      columns: ["is_deleted"]
      purpose: "Exclude deleted records efficiently"
```

```sql
-- Indexes for common queries
CREATE INDEX idx_receipts_captured_at ON receipts(captured_at DESC);
CREATE INDEX idx_receipts_status ON receipts(status) WHERE is_deleted = 0;
CREATE INDEX idx_receipts_receipt_date ON receipts(receipt_date) WHERE is_deleted = 0;
CREATE INDEX idx_receipts_merchant ON receipts(merchant_name) WHERE is_deleted = 0;
CREATE INDEX idx_receipts_overall_confidence ON receipts(overall_confidence);
CREATE INDEX idx_receipts_deleted ON receipts(is_deleted);
```

### export_batches

```poml
EXPORT_BATCHES_TABLE:
  purpose: "Track CSV export operations and results"
  relationship: "References receipt IDs for batch composition"
  validation_storage: "JSON arrays for warnings and errors"
  
EXPORT_TRACKING:
  batch_metadata: ["id", "created_at", "format", "total_receipts"]
  date_filtering: ["date_range_start", "date_range_end"]
  validation_results: ["valid_receipts", "validation_warnings", "validation_errors"]
  file_info: ["file_name", "file_path", "file_size_bytes"]
  status_tracking: ["status", "exported_at"]
```

```sql
CREATE TABLE export_batches (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    format TEXT NOT NULL CHECK(format IN ('quickbooks', 'xero', 'generic')),
    date_range_start TEXT,
    date_range_end TEXT,
    total_receipts INTEGER NOT NULL,
    valid_receipts INTEGER NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('pending', 'validating', 'generating', 'complete', 'failed')),
    file_name TEXT,
    file_path TEXT,
    file_size_bytes INTEGER,
    validation_warnings TEXT, -- JSON array
    validation_errors TEXT,   -- JSON array
    exported_at INTEGER
);
```

### app_settings

```poml
APP_SETTINGS_TABLE:
  purpose: "Application configuration and user preferences"
  design: "Single row with comprehensive settings"
  categories: ["export", "ocr", "storage", "ui"]
  
SETTINGS_CATEGORIES:
  export_defaults:
    - "default_export_format"
    - "auto_delete_after_export"
    - "date_format"
    - "currency_symbol"
  
  ocr_configuration:
    - "confidence_threshold"
    - "preferred_engine"
    - "enable_fallback"
    - "max_processing_time_ms"
    - "enhance_contrast"
    - "auto_rotate"
  
  storage_management:
    - "max_storage_mb"
    - "compression_level"
    - "keep_originals"
    - "retention_days"
  
  ui_preferences:
    - "show_confidence_scores"
    - "haptic_feedback"
    - "sound_effects"
    - "theme"
```

```sql
CREATE TABLE app_settings (
    id TEXT PRIMARY KEY DEFAULT 'default',
    default_export_format TEXT DEFAULT 'quickbooks',
    confidence_threshold REAL DEFAULT 75.0,
    auto_save_enabled INTEGER DEFAULT 1,
    batch_mode_enabled INTEGER DEFAULT 0,
    merchant_normalization INTEGER DEFAULT 1,
    image_quality REAL DEFAULT 0.8,
    
    -- Storage settings
    auto_delete_after_export INTEGER DEFAULT 0,
    max_storage_mb INTEGER DEFAULT 1000,
    compression_level INTEGER DEFAULT 7,
    keep_originals INTEGER DEFAULT 1,
    retention_days INTEGER DEFAULT 0, -- 0 = forever
    
    -- OCR settings
    preferred_engine TEXT DEFAULT 'auto',
    enable_fallback INTEGER DEFAULT 1,
    max_processing_time_ms INTEGER DEFAULT 5000,
    enhance_contrast INTEGER DEFAULT 1,
    auto_rotate INTEGER DEFAULT 1,
    
    -- UI preferences
    show_confidence_scores INTEGER DEFAULT 1,
    haptic_feedback INTEGER DEFAULT 1,
    sound_effects INTEGER DEFAULT 0,
    theme TEXT DEFAULT 'auto',
    date_format TEXT DEFAULT 'MM/DD/YYYY',
    currency_symbol TEXT DEFAULT '$',
    
    last_modified INTEGER NOT NULL
);
```

```poml
DATABASE_PERFORMANCE_OPTIMIZATION:
  sqlite_configuration:
    journal_mode: "WAL" # Write-Ahead Logging for better concurrency
    synchronous: "NORMAL" # Balance durability vs performance
    cache_size: "-64000" # 64MB cache (negative value = KB)
    temp_store: "MEMORY" # Use memory for temp tables
    foreign_keys: "ON" # Enforce referential integrity
  
  query_optimization:
    denormalization: "OCR fields in receipts table avoid JOINs"
    partial_indexes: "WHERE clauses on indexes for deleted records"
    covering_indexes: "Include commonly selected columns"
    query_planning: "Use EXPLAIN QUERY PLAN for optimization"
  
  maintenance_strategies:
    vacuum: "PRAGMA vacuum; -- Periodic space reclamation"
    analyze: "PRAGMA analyze; -- Update query planner statistics"
    integrity_check: "PRAGMA integrity_check; -- Data validation"
    wal_checkpoint: "PRAGMA wal_checkpoint; -- WAL file management"

STORAGE_ESTIMATES:
  receipt_record: "~2KB per receipt (including denormalized OCR data)"
  image_storage: "~100KB compressed per receipt image"
  thumbnail_storage: "~10KB per thumbnail"
  
  capacity_planning:
    - "1000 receipts: ~2MB database + ~110MB images"
    - "5000 receipts: ~10MB database + ~550MB images" 
    - "10000 receipts: ~20MB database + ~1.1GB images"
```

## Hive Key-Value Storage

```poml
HIVE_CONFIGURATION:
  purpose: "Lightweight settings and preferences storage"
  rationale: "Faster than SQLite for simple key-value pairs"
  implementation: "Hive 2.2+ with type adapters"
  
  advantages_over_sqlite:
    - "No SQL overhead for simple settings"
    - "Type-safe with code generation"
    - "Lazy loading and caching"
    - "Smaller footprint for preferences"
    
  use_cases:
    - "User preferences that change frequently"
    - "OAuth tokens and credentials"
    - "Temporary UI state"
    - "Feature flags and experiments"
```

### Hive Boxes (Collections)

```dart
// Settings Box - User Preferences
Box<dynamic> settingsBox = await Hive.openBox('settings');
/*
Keys stored:
  - default_export_format: String
  - confidence_threshold: double
  - merchant_normalization_enabled: bool
  - show_confidence_scores: bool
  - haptic_feedback_enabled: bool
  - theme_mode: String
  - batch_mode_default: bool
  - auto_save_enabled: bool
*/

// OAuth Box - Secure Credentials
Box<dynamic> oauthBox = await Hive.openBox('oauth', 
  encryptionCipher: HiveAesCipher(encryptionKey));
/*
Keys stored:
  - quickbooks_access_token: String (encrypted)
  - quickbooks_refresh_token: String (encrypted)
  - quickbooks_token_expiry: DateTime
  - xero_access_token: String (encrypted)
  - xero_refresh_token: String (encrypted)
  - xero_token_expiry: DateTime
*/

// Cache Box - Temporary Data
Box<dynamic> cacheBox = await Hive.openBox('cache');
/*
Keys stored:
  - last_export_date: DateTime
  - merchant_normalization_cache: Map<String, String>
  - recent_merchants: List<String>
  - ui_state: Map (collapsible sections, sort preferences)
*/
```

### Hive vs SQLite Usage Guidelines

```poml
USE_HIVE_FOR:
  simple_values: "Single key-value pairs"
  frequent_updates: "Settings that change often"
  small_datasets: "< 1000 items"
  examples:
    - "User preferences"
    - "OAuth tokens"
    - "UI state"
    - "Feature flags"
    
USE_SQLITE_FOR:
  structured_data: "Complex relational data"
  large_datasets: "> 1000 items"
  queries: "Need WHERE, JOIN, ORDER BY"
  examples:
    - "Receipt records"
    - "Export history"
    - "Audit logs"
    - "Bulk operations"
```

### Migration Strategy

```dart
// Settings Migration: SQLite app_settings → Hive
class SettingsMigration {
  static Future<void> migrateFromSQLite() async {
    // 1. Read from SQLite app_settings table
    final sqliteSettings = await db.query('app_settings');
    
    // 2. Write to Hive settingsBox
    final box = await Hive.openBox('settings');
    for (var setting in sqliteSettings.first.entries) {
      await box.put(setting.key, setting.value);
    }
    
    // 3. Mark migration complete
    await box.put('migrated_from_sqlite', true);
    
    // 4. Keep SQLite table for rollback capability
  }
}
```

### Performance Comparison

```poml
PERFORMANCE_METRICS:
  read_single_setting:
    hive: "< 1ms"
    sqlite: "5-10ms"
    
  write_single_setting:
    hive: "< 2ms" 
    sqlite: "10-20ms"
    
  batch_read_10_settings:
    hive: "< 5ms"
    sqlite: "15-30ms"
    
  memory_overhead:
    hive: "~100KB for settings box"
    sqlite: "~1MB minimum database size"
```