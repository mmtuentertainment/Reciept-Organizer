/// Conditional export for image capture service
/// This file automatically selects the correct implementation based on platform
export 'interfaces/image_capture.dart';

// Conditionally export the correct implementation
// dart.library.html is true when running on web
export 'mobile/image_capture_mobile.dart'
    if (dart.library.html) 'web/image_capture_web.dart';