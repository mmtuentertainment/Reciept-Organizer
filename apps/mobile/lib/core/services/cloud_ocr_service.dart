import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../platform/interfaces/ocr_processor.dart';
import 'ocr_configuration_service.dart';

/// Cloud-based OCR service that works on all platforms
/// Uses Google Cloud Vision API when API key is available
class CloudOcrService {
  final OcrConfigurationService _config = OcrConfigurationService();

  /// Process image using Google Cloud Vision API
  Future<OcrResult?> processWithGoogleVision(Uint8List imageBytes) async {
    final apiKey = _config.getGoogleVisionApiKey();
    if (apiKey == null) {
      debugPrint('CloudOCR: Google Vision API key not configured');
      return null;
    }

    try {
      // Prepare the request
      final base64Image = base64Encode(imageBytes);
      final requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'TEXT_DETECTION',
                'maxResults': 1,
              },
              {
                'type': 'DOCUMENT_TEXT_DETECTION',
                'maxResults': 1,
              }
            ],
            'imageContext': {
              'languageHints': ['en'],
            }
          }
        ]
      };

      // Make the API call
      final response = await http.post(
        Uri.parse('${_config.getGoogleVisionEndpoint()}?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final responses = responseData['responses'] as List;

        if (responses.isNotEmpty) {
          final textAnnotations = responses[0]['textAnnotations'] as List?;
          final fullTextAnnotation = responses[0]['fullTextAnnotation'] as Map?;

          if (textAnnotations != null && textAnnotations.isNotEmpty) {
            final fullText = textAnnotations[0]['description'] as String;

            // Extract text blocks for structured parsing
            final blocks = <TextBlock>[];
            if (fullTextAnnotation != null) {
              final pages = fullTextAnnotation['pages'] as List?;
              if (pages != null) {
                for (final page in pages) {
                  final pageBlocks = page['blocks'] as List?;
                  if (pageBlocks != null) {
                    for (final block in pageBlocks) {
                      blocks.add(_parseTextBlock(block));
                    }
                  }
                }
              }
            }

            return OcrResult(
              text: fullText,
              confidence: _calculateConfidence(textAnnotations),
              blocks: [],  // Convert TextBlock to OcrBlock if needed
              metadata: {
                'provider': 'google_cloud_vision',
                'processingTime': DateTime.now().millisecondsSinceEpoch,
              },
            );
          }
        }
      } else {
        debugPrint('CloudOCR: Google Vision API error: ${response.statusCode}');
        debugPrint('CloudOCR: Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('CloudOCR: Error processing with Google Vision: $e');
    }

    return null;
  }

  /// Process image using Azure Computer Vision API
  Future<OcrResult?> processWithAzureVision(Uint8List imageBytes) async {
    final apiKey = _config.getAzureVisionApiKey();
    final endpoint = _config.getAzureVisionEndpoint();

    if (apiKey == null || endpoint == null) {
      debugPrint('CloudOCR: Azure Vision API not configured');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$endpoint/vision/v3.2/ocr?language=en&detectOrientation=true'),
        headers: {
          'Ocp-Apim-Subscription-Key': apiKey,
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extract text from Azure response
        final regions = responseData['regions'] as List?;
        if (regions != null && regions.isNotEmpty) {
          final textBuilder = StringBuffer();
          final blocks = <TextBlock>[];

          for (final region in regions) {
            final lines = region['lines'] as List?;
            if (lines != null) {
              for (final line in lines) {
                final words = line['words'] as List?;
                if (words != null) {
                  final lineText = words
                      .map((w) => w['text'] as String)
                      .join(' ');
                  textBuilder.writeln(lineText);
                }
              }
            }
          }

          return OcrResult(
            text: textBuilder.toString(),
            confidence: 0.85, // Azure doesn't provide overall confidence
            blocks: [],  // Convert if needed
            metadata: {
              'provider': 'azure_computer_vision',
              'processingTime': DateTime.now().millisecondsSinceEpoch,
            },
          );
        }
      } else {
        debugPrint('CloudOCR: Azure Vision API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('CloudOCR: Error processing with Azure Vision: $e');
    }

    return null;
  }

  /// Process image with any available cloud provider
  Future<OcrResult?> processImage(Uint8List imageBytes) async {
    // Try Google Vision first
    final googleResult = await processWithGoogleVision(imageBytes);
    if (googleResult != null) return googleResult;

    // Fall back to Azure if available
    final azureResult = await processWithAzureVision(imageBytes);
    if (azureResult != null) return azureResult;

    return null;
  }

  /// Parse text block from Google Vision response
  TextBlock _parseTextBlock(Map<String, dynamic> blockData) {
    final paragraphs = blockData['paragraphs'] as List?;
    final textBuilder = StringBuffer();

    if (paragraphs != null) {
      for (final paragraph in paragraphs) {
        final words = paragraph['words'] as List?;
        if (words != null) {
          for (final word in words) {
            final symbols = word['symbols'] as List?;
            if (symbols != null) {
              for (final symbol in symbols) {
                textBuilder.write(symbol['text'] ?? '');

                // Add space or line break based on detected breaks
                final detectedBreak = symbol['property']?['detectedBreak'];
                if (detectedBreak != null) {
                  final breakType = detectedBreak['type'] as String?;
                  if (breakType == 'SPACE' || breakType == 'SURE_SPACE') {
                    textBuilder.write(' ');
                  } else if (breakType == 'EOL_SURE_SPACE' || breakType == 'LINE_BREAK') {
                    textBuilder.writeln();
                  }
                }
              }
            }
          }
        }
      }
    }

    return TextBlock(
      text: textBuilder.toString(),
      confidence: _extractConfidence(blockData),
    );
  }

  /// Calculate overall confidence from annotations
  double _calculateConfidence(List<dynamic> annotations) {
    if (annotations.length <= 1) return 0.85; // Default confidence

    double totalConfidence = 0;
    int count = 0;

    for (int i = 1; i < annotations.length; i++) {
      final confidence = annotations[i]['confidence'] as double?;
      if (confidence != null) {
        totalConfidence += confidence;
        count++;
      }
    }

    return count > 0 ? totalConfidence / count : 0.85;
  }

  /// Extract confidence from block data
  double _extractConfidence(Map<String, dynamic> blockData) {
    final confidence = blockData['confidence'] as double?;
    return confidence ?? 0.85;
  }
}

/// Text block for structured OCR results
class TextBlock {
  final String text;
  final double confidence;

  TextBlock({
    required this.text,
    required this.confidence,
  });
}