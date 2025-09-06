import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget for editing receipt notes with character limit and auto-save functionality.
/// 
/// Provides a multi-line text field specifically designed for adding contextual
/// notes to receipts. Features include character counting, hint text, and
/// proper keyboard handling.
class NotesFieldEditor extends StatefulWidget {
  /// The initial text value for the notes field.
  final String? initialValue;
  
  /// Callback when the notes text changes.
  final ValueChanged<String> onChanged;
  
  /// Whether the field is enabled for editing.
  final bool enabled;
  
  /// Maximum number of characters allowed.
  static const int maxCharacters = 500;

  const NotesFieldEditor({
    Key? key,
    this.initialValue,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<NotesFieldEditor> createState() => _NotesFieldEditorState();
}

class _NotesFieldEditorState extends State<NotesFieldEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
    _characterCount = _controller.text.length;
    
    // Listen for text changes
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final sanitized = _sanitizeInput(_controller.text);
    
    // Only update if sanitization changed the text
    if (sanitized != _controller.text) {
      // Preserve cursor position as much as possible
      final cursorPos = _controller.selection.baseOffset;
      final lengthDiff = _controller.text.length - sanitized.length;
      
      _controller.value = _controller.value.copyWith(
        text: sanitized,
        selection: TextSelection.collapsed(
          offset: (cursorPos - lengthDiff).clamp(0, sanitized.length),
        ),
      );
      return; // The recursive listener call will handle the state update
    }
    
    setState(() {
      _characterCount = _controller.text.length;
    });
    widget.onChanged(_controller.text);
  }
  
  /// Sanitizes input text to remove potentially harmful characters while
  /// preserving legitimate content for receipt notes.
  String _sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // Remove null bytes and other control characters except newline and tab
    String sanitized = input.replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'), '');
    
    // Remove potentially dangerous HTML/script patterns (defense in depth)
    // This is overly cautious for a mobile app but follows security best practices
    sanitized = sanitized
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
    
    // Normalize excessive whitespace (keep single newlines and spaces)
    sanitized = sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    sanitized = sanitized.replaceAll(RegExp(r' {3,}'), '  ');
    
    // Trim to max length (redundant with maxLength but ensures consistency)
    if (sanitized.length > NotesFieldEditor.maxCharacters) {
      sanitized = sanitized.substring(0, NotesFieldEditor.maxCharacters);
    }
    
    return sanitized;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          maxLines: 3,
          maxLength: NotesFieldEditor.maxCharacters,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            labelText: 'Notes',
            hintText: 'Add notes about this receipt...',
            hintMaxLines: 2,
            alignLabelWithHint: true,
            semanticsLabel: 'Receipt notes. Maximum 500 characters.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: theme.colorScheme.surfaceVariant,
                width: 1.0,
              ),
            ),
            filled: !widget.enabled,
            fillColor: !widget.enabled ? theme.colorScheme.surfaceVariant : null,
            counterText: '', // Hide default counter, we'll use custom
          ),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        // Custom character counter
        Align(
          alignment: Alignment.centerRight,
          child: Semantics(
            label: '$_characterCount of ${NotesFieldEditor.maxCharacters} characters used',
            liveRegion: true,
            child: Text(
              '$_characterCount / ${NotesFieldEditor.maxCharacters}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _characterCount >= NotesFieldEditor.maxCharacters
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}