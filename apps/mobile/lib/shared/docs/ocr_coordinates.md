# OCR Coordinate System Documentation

## Overview

This document describes the coordinate system used for OCR bounding boxes in the Receipt Organizer application.

## Coordinate Systems

### 1. OCR Coordinates (Normalized)

OCR services typically return bounding box coordinates in a normalized format:
- **Range**: 0.0 to 1.0 for both X and Y axes
- **Origin**: Top-left corner of the image (0,0)
- **Format**: `Rect(left, top, right, bottom)` where all values are between 0 and 1
- **Example**: A box at the center might be `Rect(0.25, 0.25, 0.75, 0.75)`

### 2. Display Coordinates

When rendering bounding boxes on screen, coordinates must be transformed:
- **Range**: 0 to widget width/height in pixels
- **Origin**: Top-left corner of the widget
- **Scaling**: Must account for image aspect ratio preservation
- **Centering**: Images are centered within the display area

## Transformation Process

### Step 1: Calculate Scale Factor
```dart
final scaleX = displaySize.width / imageSize.width;
final scaleY = displaySize.height / imageSize.height;
final scale = min(scaleX, scaleY); // Preserve aspect ratio
```

### Step 2: Calculate Centering Offset
```dart
final scaledWidth = imageSize.width * scale;
final scaledHeight = imageSize.height * scale;
final offsetX = (displaySize.width - scaledWidth) / 2;
final offsetY = (displaySize.height - scaledHeight) / 2;
```

### Step 3: Transform Normalized Coordinates
```dart
final displayRect = Rect.fromLTRB(
  normalizedRect.left * scaledWidth + offsetX,
  normalizedRect.top * scaledHeight + offsetY,
  normalizedRect.right * scaledWidth + offsetX,
  normalizedRect.bottom * scaledHeight + offsetY,
);
```

## Zoom and Pan Transformation

When the user zooms or pans the image, an additional transformation matrix is applied:

### InteractiveViewer Transformation
- The `TransformationController` provides a 4x4 matrix
- This matrix includes scale, translation, and rotation transformations
- The bounding box overlay must be synchronized with this transformation

### Applying the Transformation
```dart
final transformed = MatrixUtils.transformRect(
  transformationMatrix,
  displayRect
);
```

## Debug Mode Visualization

Enable debug mode to visualize coordinate transformations:
- **Red dots**: Original normalized coordinates
- **Blue dots**: Transformed display coordinates
- **Green lines**: Transformation vectors
- **Text labels**: Coordinate values for debugging

## Common Issues and Solutions

### Issue 1: Bounding Boxes Don't Align
**Cause**: Incorrect aspect ratio handling
**Solution**: Always use the minimum scale factor to preserve aspect ratio

### Issue 2: Boxes Move When Zooming
**Cause**: Not applying the transformation matrix
**Solution**: Use AnimatedBuilder with TransformationController

### Issue 3: Taps Don't Match Boxes
**Cause**: Touch coordinates not transformed correctly
**Solution**: Apply inverse transformation to touch points

## Example Usage

```dart
// Extract bounding boxes from OCR result
final boxes = BoundingBoxOverlay.extractFromProcessingResult(ocrResult);

// Create overlay with proper sizing
BoundingBoxOverlay(
  boundingBoxes: boxes,
  imageSize: Size(originalWidth, originalHeight),
  displaySize: Size(widgetWidth, widgetHeight),
  onFieldTapped: (fieldName) {
    // Handle field selection
  },
)
```

## Testing Coordinates

Use the following test scenarios:
1. **Corner boxes**: Test boxes at (0,0), (0,1), (1,0), (1,1)
2. **Edge boxes**: Test boxes touching each edge
3. **Aspect ratios**: Test with square, portrait, and landscape images
4. **Zoom levels**: Test at min, max, and intermediate zoom levels
5. **Device sizes**: Test on phone and tablet screen sizes