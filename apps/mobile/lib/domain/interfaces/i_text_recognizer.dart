import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Interface for TextRecognizer to enable mocking
abstract class ITextRecognizer {
  Future<RecognizedText> processImage(InputImage inputImage);
  Future<void> close();
}

/// Wrapper implementation that delegates to Google ML Kit's TextRecognizer
class TextRecognizerWrapper implements ITextRecognizer {
  final TextRecognizer _textRecognizer;
  
  TextRecognizerWrapper() : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  @override
  Future<RecognizedText> processImage(InputImage inputImage) {
    return _textRecognizer.processImage(inputImage);
  }
  
  @override
  Future<void> close() {
    return _textRecognizer.close();
  }
}