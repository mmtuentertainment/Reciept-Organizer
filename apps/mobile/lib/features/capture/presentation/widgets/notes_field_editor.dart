import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotesFieldEditor extends StatefulWidget {
  final String? initialValue;
  final Function(String) onChanged;
  final VoidCallback? onSaved;
  final int maxLength;

  const NotesFieldEditor({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.onSaved,
    this.maxLength = 500,
  });

  @override
  State<NotesFieldEditor> createState() => _NotesFieldEditorState();
}

class _NotesFieldEditorState extends State<NotesFieldEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();

    // Auto-save on focus loss
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.onSaved != null) {
        _handleSave();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    // Call onChanged to update the value
    widget.onChanged(_controller.text);

    // Call onSaved for additional save logic
    if (widget.onSaved != null) {
      widget.onSaved!();
    }

    // Show save confirmation
    if (mounted) {
      setState(() => _isSaving = false);

      // Visual feedback
      HapticFeedback.lightImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes saved'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.note_add, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isSaving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),

        // Text field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 3,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: 'Add notes about this receipt...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(12),
            counterText: '${_controller.text.length}/${widget.maxLength}',
            counterStyle: TextStyle(
              color: _controller.text.length >= widget.maxLength
                  ? Colors.red
                  : Colors.grey,
              fontSize: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: (value) {
            setState(() {}); // Update character counter
            widget.onChanged(value);
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSave(),
        ),

        // Helper text
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'This note will be searchable and included in exports',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}