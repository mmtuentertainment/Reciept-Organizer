import 'dart:typed_data';
import 'dart:math' show Point;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

// Manual mock for TextRecognizer since it cannot be auto-generated
class MockTextRecognizer extends Mock implements TextRecognizer {
  @override
  Future<RecognizedText> processImage(InputImage? inputImage) =>
      super.noSuchMethod(
        Invocation.method(#processImage, [inputImage]),
        returnValue: Future.value(MockRecognizedText()),
        returnValueForMissingStub: Future.value(MockRecognizedText()),
      ) as Future<RecognizedText>;

  @override
  Future<void> close() => super.noSuchMethod(
        Invocation.method(#close, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

// Manual mock for RecognizedText
class MockRecognizedText extends Mock implements RecognizedText {
  @override
  String get text => super.noSuchMethod(
        Invocation.getter(#text),
        returnValue: '',
        returnValueForMissingStub: '',
      );

  @override
  List<TextBlock> get blocks => super.noSuchMethod(
        Invocation.getter(#blocks),
        returnValue: <TextBlock>[],
        returnValueForMissingStub: <TextBlock>[],
      );
}

// Manual mock for TextBlock
class MockTextBlock extends Mock implements TextBlock {
  @override
  String get text => super.noSuchMethod(
        Invocation.getter(#text),
        returnValue: '',
        returnValueForMissingStub: '',
      );

  @override
  List<TextLine> get lines => super.noSuchMethod(
        Invocation.getter(#lines),
        returnValue: <TextLine>[],
        returnValueForMissingStub: <TextLine>[],
      );

  @override
  Rect get boundingBox => super.noSuchMethod(
        Invocation.getter(#boundingBox),
        returnValue: Rect.zero,
        returnValueForMissingStub: Rect.zero,
      );

  @override
  List<Point<int>> get cornerPoints => super.noSuchMethod(
        Invocation.getter(#cornerPoints),
        returnValue: <Point<int>>[],
        returnValueForMissingStub: <Point<int>>[],
      );

  @override
  List<String> get recognizedLanguages => super.noSuchMethod(
        Invocation.getter(#recognizedLanguages),
        returnValue: <String>[],
        returnValueForMissingStub: <String>[],
      );
}

// Manual mock for TextLine
class MockTextLine extends Mock implements TextLine {
  @override
  String get text => super.noSuchMethod(
        Invocation.getter(#text),
        returnValue: '',
        returnValueForMissingStub: '',
      );

  @override
  List<TextElement> get elements => super.noSuchMethod(
        Invocation.getter(#elements),
        returnValue: <TextElement>[],
        returnValueForMissingStub: <TextElement>[],
      );

  @override
  Rect get boundingBox => super.noSuchMethod(
        Invocation.getter(#boundingBox),
        returnValue: Rect.zero,
        returnValueForMissingStub: Rect.zero,
      );

  @override
  List<Point<int>> get cornerPoints => super.noSuchMethod(
        Invocation.getter(#cornerPoints),
        returnValue: <Point<int>>[],
        returnValueForMissingStub: <Point<int>>[],
      );

  @override
  List<String> get recognizedLanguages => super.noSuchMethod(
        Invocation.getter(#recognizedLanguages),
        returnValue: <String>[],
        returnValueForMissingStub: <String>[],
      );

  @override
  double? get confidence => super.noSuchMethod(
        Invocation.getter(#confidence),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  double? get angle => super.noSuchMethod(
        Invocation.getter(#angle),
        returnValue: null,
        returnValueForMissingStub: null,
      );
}

// Manual mock for TextElement
class MockTextElement extends Mock implements TextElement {
  @override
  String get text => super.noSuchMethod(
        Invocation.getter(#text),
        returnValue: '',
        returnValueForMissingStub: '',
      );

  @override
  Rect get boundingBox => super.noSuchMethod(
        Invocation.getter(#boundingBox),
        returnValue: Rect.zero,
        returnValueForMissingStub: Rect.zero,
      );

  @override
  List<Point<int>> get cornerPoints => super.noSuchMethod(
        Invocation.getter(#cornerPoints),
        returnValue: <Point<int>>[],
        returnValueForMissingStub: <Point<int>>[],
      );

  @override
  List<String> get recognizedLanguages => super.noSuchMethod(
        Invocation.getter(#recognizedLanguages),
        returnValue: <String>[],
        returnValueForMissingStub: <String>[],
      );

  @override
  double? get confidence => super.noSuchMethod(
        Invocation.getter(#confidence),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  double? get angle => super.noSuchMethod(
        Invocation.getter(#angle),
        returnValue: null,
        returnValueForMissingStub: null,
      );
}

// Helper class to simplify creating InputImage mocks
class MockInputImage extends Mock implements InputImage {
  final Uint8List _bytes;
  final InputImageMetadata _metadata;

  MockInputImage({
    required Uint8List bytes,
    required InputImageMetadata metadata,
  }) : _bytes = bytes,
       _metadata = metadata;

  @override
  Uint8List? get bytes => _bytes;

  @override
  InputImageMetadata? get metadata => _metadata;

  @override
  String? get filePath => null;

  @override
  InputImageType get type => InputImageType.bytes;
}