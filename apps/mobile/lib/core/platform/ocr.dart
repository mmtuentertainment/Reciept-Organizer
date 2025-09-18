/// Conditional export for OCR processor
/// This file automatically selects the correct implementation based on platform
export 'interfaces/ocr_processor.dart';

// Conditionally export the correct implementation
// dart.library.html is true when running on web
export 'mobile/ocr_processor_mobile.dart'
    if (dart.library.html) 'web/ocr_processor_web.dart';