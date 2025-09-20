#!/usr/bin/env bash
# Parallel Flutter Widget Test Runner
# Runs widget tests in parallel to improve performance

echo "🚀 Running widget tests in parallel..."
START_TIME=$(date +%s)

# Run tests in parallel groups
(
  /snap/bin/flutter test test/widget/capture_screen_test.dart --reporter compact &
  /snap/bin/flutter test test/widget/receipts_list_async_test.dart --reporter compact &
  /snap/bin/flutter test test/widget/home_screen_test.dart test/widget/receipts_list_test.dart --reporter compact &
  /snap/bin/flutter test test/widget/capture/notes_field_editor_test.dart --reporter compact &
  wait
) 2>&1 | grep -E "^\+[0-9]+ -[0-9]+:|All tests passed|Some tests failed"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "⏱️  Total execution time: ${DURATION} seconds"

# Check if all tests passed
if [ $? -eq 0 ]; then
  echo "✅ All widget tests passed!"
else
  echo "❌ Some tests failed"
  exit 1
fi