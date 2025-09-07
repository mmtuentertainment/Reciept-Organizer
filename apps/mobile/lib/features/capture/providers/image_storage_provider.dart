import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/domain/services/image_storage_service.dart';
import 'package:receipt_organizer/infrastructure/services/image_storage_service_impl.dart';

/// Provider for image storage service
final imageStorageServiceProvider = Provider<IImageStorageService>((ref) {
  return ImageStorageServiceImpl();
});