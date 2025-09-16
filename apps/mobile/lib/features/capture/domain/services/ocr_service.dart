import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ProcessingResult {
  final String? merchant;
  final DateTime? date;
  final double? total;
  final double? tax;
  final Map<String, double> confidence;
  final String rawText;

  ProcessingResult({
    this.merchant,
    this.date,
    this.total,
    this.tax,
    required this.confidence,
    required this.rawText,
  });
}

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ProcessingResult> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseReceiptData(recognizedText.text);
    } catch (e) {
      // Return empty result on failure
      return ProcessingResult(
        confidence: {'overall': 0.0},
        rawText: '',
      );
    }
  }

  ProcessingResult _parseReceiptData(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    String? merchant;
    DateTime? date;
    double? total;
    double? tax;
    final confidence = <String, double>{};

    // Simple merchant extraction (first non-empty line)
    if (lines.isNotEmpty) {
      merchant = lines.first;
      confidence['merchant'] = 0.8; // High confidence for first line
    }

    // Find total amount (look for "TOTAL" keyword)
    for (final line in lines) {
      final upperLine = line.toUpperCase();
      if (upperLine.contains('TOTAL') && !upperLine.contains('SUBTOTAL')) {
        final amount = _extractAmount(line);
        if (amount != null) {
          total = amount;
          confidence['total'] = 0.9; // High confidence for TOTAL keyword
          break;
        }
      }
    }

    // Find tax amount
    for (final line in lines) {
      if (line.toUpperCase().contains('TAX')) {
        final amount = _extractAmount(line);
        if (amount != null) {
          tax = amount;
          confidence['tax'] = 0.85;
          break;
        }
      }
    }

    // Find date (common formats: MM/DD/YYYY, MM-DD-YYYY, DD/MM/YYYY)
    final dateRegex = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})');
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        date = _parseDate(match.group(1)!);
        if (date != null) {
          confidence['date'] = 0.75;
          break;
        }
      }
    }

    // Calculate overall confidence
    confidence['overall'] = confidence.values.isEmpty
        ? 0.0
        : confidence.values.reduce((a, b) => a + b) / confidence.values.length;

    return ProcessingResult(
      merchant: merchant,
      date: date,
      total: total,
      tax: tax,
      confidence: confidence,
      rawText: text,
    );
  }

  double? _extractAmount(String line) {
    // Extract numeric amount from line (handles $12.34 or 12.34)
    final amountRegex = RegExp(r'\$?(\d+\.?\d{0,2})');
    final matches = amountRegex.allMatches(line);

    // Get the last match (usually the amount is at the end)
    if (matches.isNotEmpty) {
      final lastMatch = matches.last;
      return double.tryParse(lastMatch.group(1)!);
    }
    return null;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split(RegExp(r'[/-]'));
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        var year = int.parse(parts[2]);

        // Handle 2-digit years
        if (year < 100) {
          year += (year > 50) ? 1900 : 2000;
        }

        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}