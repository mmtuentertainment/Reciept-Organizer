/// Conditional export for background processor
/// This file automatically selects the correct implementation based on platform
export 'interfaces/background_processor.dart';

// Conditionally export the correct implementation
// dart.library.html is true when running on web
export 'mobile/background_processor_mobile.dart'
    if (dart.library.html) 'web/background_processor_web.dart';