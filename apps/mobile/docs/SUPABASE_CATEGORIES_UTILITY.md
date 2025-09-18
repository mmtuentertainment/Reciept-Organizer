# Supabase Categories Utility

This document describes the utilities created to list and analyze categories from the Supabase database.

## Overview

The Receipt Organizer app uses Supabase as its backend database. The categories table stores expense categories that users can assign to their receipts. This utility provides tools to inspect and analyze the category data.

## Database Schema

Based on the documentation in `/docs/stories/1.1-enhanced-database-schema.md`, the categories table has the following structure:

```sql
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7), -- Hex color code (#RRGGBB)
    icon VARCHAR(50), -- Icon identifier
    display_order INTEGER DEFAULT 999,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, name)
);
```

## Default Categories

According to `/docs/stories/1.3-default-categories-seeding.md`, the following default business categories are seeded for new users:

| Name | Color | Icon | Purpose |
|------|-------|------|---------|
| Meals & Entertainment | #3B82F6 | utensils | Business meals, client entertainment |
| Travel | #10B981 | plane | Flights, hotels, travel expenses |
| Transportation | #F97316 | car | Local transport, parking, fuel |
| Office Supplies | #8B5CF6 | briefcase | Stationery, office materials |
| Software & Subscriptions | #F59E0B | laptop | SaaS, licenses, digital tools |
| Marketing | #EF4444 | megaphone | Advertising, promotion |
| Professional Services | #6B7280 | user-tie | Consulting, legal, accounting |
| Equipment | #9333EA | wrench | Hardware, tools, machinery |
| Utilities | #14B8A6 | zap | Internet, phone, electricity |
| Insurance | #0EA5E9 | shield | Business insurance |
| Rent & Lease | #84CC16 | home | Office rent, equipment lease |
| Other | #64748B | folder | Miscellaneous expenses |

## Files Created

### 1. SupabaseQueryTool (`lib/utils/supabase_query_tool.dart`)

A utility class that provides methods to query the categories table:

- `fetchAllCategories()` - Fetch all categories from database
- `fetchCategoriesForUser(userId)` - Fetch categories for a specific user
- `printAllCategories()` - Print formatted category list for debugging
- `categoryFromMap()` - Convert database map to Category model
- `categoriesToModels()` - Convert list of maps to Category models

Also includes a `Category` model class that matches the database schema.

### 2. Categories Listing Script (`scripts/list_categories.dart`)

A standalone Dart script that can be run to list categories:

```bash
# Run with Supabase credentials
dart run scripts/list_categories.dart \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### 3. Categories Listing Test (`test/infrastructure/categories_listing_test.dart`)

A comprehensive test file that serves dual purposes:
- Tests category data integrity and model mapping
- Provides detailed analysis and debugging output

## Usage

### Running the Test (Recommended)

The test file provides the most comprehensive analysis:

```bash
# Run categories test with Supabase credentials
flutter test test/infrastructure/categories_listing_test.dart \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

This will:
- Connect to your Supabase database
- Fetch all categories
- Display formatted table of category data
- Analyze category distribution by user
- Test Category model conversion
- Verify data integrity
- Test user-specific category fetching

### Using in Flutter App

```dart
import 'package:receipt_organizer/utils/supabase_query_tool.dart';

// Fetch all categories
final categories = await SupabaseQueryTool.fetchAllCategories();

// Convert to Flutter models
final categoryModels = SupabaseQueryTool.categoriesToModels(categories);

// Use in dropdowns, pickers, etc.
for (final category in categoryModels) {
  print('${category.name}: ${category.color}');
}
```

### Integration with Receipt Model

The Receipt model has a `categoryId` field that should reference the categories table:

```dart
final receipt = Receipt(
  // ... other fields
  categoryId: selectedCategory.id,
);
```

## Security Notes

- The utility uses Row Level Security (RLS) policies
- Users can only see their own categories
- Anonymous authentication is used for testing
- No credentials are hardcoded in the files

## Troubleshooting

### "No categories found"
- Check if database has been seeded with default categories
- Verify RLS policies are not blocking access
- Ensure proper authentication

### "Supabase not configured"
- Provide SUPABASE_URL and SUPABASE_ANON_KEY environment variables
- Check that Supabase project is properly configured

### Authentication errors
- Verify Supabase anon key has proper permissions
- Check if anonymous authentication is enabled
- Ensure RLS policies allow read access

## Expected Output

When running successfully, you should see output like:

```
🔍 FETCHING ALL CATEGORIES FROM SUPABASE
==========================================
📊 Total categories found: 60

👥 Categories by User:
  User: 12345678... (12 categories)
  User: 87654321... (12 categories)
  User: abcdef12... (12 categories)

📝 Category Details:
┌─────┬────────────────────────────────────┬─────────┬──────────────┬───────┐
│ #   │ Name                               │ Color   │ Icon         │ Order │
├─────┼────────────────────────────────────┼─────────┼──────────────┼───────┤
│   1 │ Meals & Entertainment             │ #3B82F6 │ utensils     │     1 │
│   2 │ Travel                            │ #10B981 │ plane        │     2 │
│   3 │ Transportation                    │ #F97316 │ car          │     3 │
...
```

This utility helps map Supabase category data to Flutter models for use in the mobile application.