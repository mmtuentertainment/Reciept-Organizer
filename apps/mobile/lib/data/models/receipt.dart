import 'package:uuid/uuid.dart';

enum ReceiptStatus { captured, processing, ready, exported, error }

class Receipt {
  final String id;
  final String imageUri;
  final DateTime capturedAt;
  final ReceiptStatus status;
  final String? batchId;

  Receipt({
    String? id,
    required this.imageUri,
    DateTime? capturedAt,
    this.status = ReceiptStatus.captured,
    this.batchId,
  }) : 
    id = id ?? const Uuid().v4(),
    capturedAt = capturedAt ?? DateTime.now();

  Receipt copyWith({
    String? id,
    String? imageUri,
    DateTime? capturedAt,
    ReceiptStatus? status,
    String? batchId,
  }) {
    return Receipt(
      id: id ?? this.id,
      imageUri: imageUri ?? this.imageUri,
      capturedAt: capturedAt ?? this.capturedAt,
      status: status ?? this.status,
      batchId: batchId ?? this.batchId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUri': imageUri,
      'capturedAt': capturedAt.toIso8601String(),
      'status': status.name,
      'batchId': batchId,
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      imageUri: json['imageUri'],
      capturedAt: DateTime.parse(json['capturedAt']),
      status: ReceiptStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReceiptStatus.captured,
      ),
      batchId: json['batchId'],
    );
  }

  @override
  String toString() {
    return 'Receipt(id: $id, imageUri: $imageUri, capturedAt: $capturedAt, status: $status, batchId: $batchId)';
  }
}