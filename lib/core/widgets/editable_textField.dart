import 'package:flutter/material.dart';

class EditableTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final String? hintText;
  final ValueChanged<String>? onSaved;

  const EditableTextField({
    super.key,
    required this.controller,
    this.enabled = false,
    this.hintText,
    this.onSaved,
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool _isEditing = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _saveChanges();
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _focusNode.requestFocus();
      } else {
        _saveChanges();
      }
    });
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus();
    widget.onSaved?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: _isEditing && widget.enabled,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            style: TextStyle(
              color: widget.enabled ? Colors.black : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (widget.enabled)
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEditing,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}