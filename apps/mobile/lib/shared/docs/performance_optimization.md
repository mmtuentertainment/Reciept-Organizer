# Performance Optimization Documentation

## Overview

This document describes the performance optimizations implemented for the Receipt Organizer image viewer to ensure 60 FPS performance with images up to 10MB.

## Performance Targets

- **Frame Rate**: Maintain 60 FPS during zoom/pan gestures
- **Gesture Response**: < 16ms response time
- **Image Sizes**: Support up to 10MB images
- **Memory Usage**: Efficient caching and disposal

## Implemented Optimizations

### 1. Progressive Image Loading

For images larger than 2MB:
- Load low-quality thumbnail (400x400) first for immediate display
- Load full-quality image in background
- Show loading indicator during progressive loading

```dart
// Thumbnail loads quickly
final thumbnail = await _cacheService.getThumbnail(path, size: 400, quality: 20);

// Full image loads in background
final fullImage = await _cacheService.getCachedImage(path, quality: 85);
```

### 2. Image Compression

- Automatic downsampling to max 1920x1920 for display
- Quality adjustment based on use case (thumbnails: 20, display: 85)
- EXIF data removal to save memory
- Format optimization using flutter_image_compress

### 3. Memory Management

#### Image Cache Service
- LRU (Least Recently Used) eviction policy
- Maximum 10 images in memory cache
- Maximum 50MB total cache size
- 24-hour cache expiration
- Cache hit/miss tracking

#### Widget Disposal
- Proper disposal of TransformationController
- Image provider eviction on dispose
- Stream subscription cleanup
- Animation controller disposal

### 4. Performance Monitoring

Real-time performance tracking with:
- FPS monitoring (current, average, min, max)
- Gesture response time tracking
- Memory usage monitoring
- Visual performance overlay in debug mode

```dart
// Track gesture performance
_performanceMonitor.recordGestureStart('zoom_gesture');
// ... perform gesture
_performanceMonitor.recordGestureEnd('zoom_gesture');
```

### 5. Rendering Optimizations

- **RepaintBoundary**: Isolates expensive repaints
- **Conditional Rendering**: Only render overlays when needed
- **Animated Transitions**: Smooth animations using curves
- **Frame Scheduling**: Proper use of WidgetsBinding callbacks

### 6. Gesture Optimization

- Debounced transformation updates
- Optimized double-tap zoom calculations
- Efficient pan boundary checking
- Hardware acceleration via InteractiveViewer

## Performance Test Results

### Test Scenarios

1. **1MB Image**: Target 60 FPS maintained
2. **5MB Image**: 50+ FPS average
3. **10MB Image**: Progressive loading ensures responsiveness
4. **Rapid Gestures**: < 20ms max response time
5. **Memory Release**: < 1MB increase after disposal

### Performance Metrics Display

The debug overlay shows:
- Current FPS (green: ≥55, red: <55)
- Average FPS over time
- Gesture response time
- Image dimensions
- Overall performance status

## Best Practices

### For Developers

1. **Always use ImageCacheService** for loading images
2. **Enable progressive loading** for images > 2MB
3. **Monitor performance** in debug builds
4. **Test with various image sizes** (1MB, 5MB, 10MB)
5. **Check memory leaks** using Flutter DevTools

### Configuration

```dart
// Enable performance monitoring
showFpsOverlay: true

// Set image quality
imageQuality: 85

// Progressive loading threshold
progressiveLoadingThreshold: 2 * 1024 * 1024 // 2MB

// Cache configuration
maxMemoryCacheSize: 10
maxCacheSizeMb: 50
```

## Troubleshooting

### Low FPS
- Check image size and enable progressive loading
- Verify RepaintBoundary is in place
- Review custom paint operations

### High Memory Usage
- Clear cache periodically
- Check for retained references
- Verify disposal methods are called

### Slow Gestures
- Enable performance monitoring
- Check for synchronous operations
- Review transformation calculations

## Future Optimizations

1. **WebP Format Support**: Better compression ratios
2. **Tile-Based Loading**: For very large images
3. **GPU Caching**: Direct GPU texture caching
4. **Predictive Preloading**: Load likely next images
5. **Resolution Switching**: Dynamic quality based on zoom level