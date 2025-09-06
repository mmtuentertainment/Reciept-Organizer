import 'package:flutter/material.dart';

class ReceiptThumbnailWidget extends StatelessWidget {
  final String imageUri;
  final double size;

  const ReceiptThumbnailWidget({
    super.key,
    required this.imageUri,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: const Icon(
        Icons.receipt,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}