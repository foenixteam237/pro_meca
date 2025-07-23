import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';

class EditableTextField extends StatefulWidget {
  final String value;
  const EditableTextField({super.key, required this.value});

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  late bool _isEditable;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _isEditable = false;
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: _isEditable, // Contrôle l'éditabilité
      decoration: InputDecoration(
        hintText: widget.value,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        suffixIcon: IconButton(
          icon: Icon(_isEditable ? Icons.check : Icons.edit),
          onPressed: () {
            setState(() {
              _isEditable = !_isEditable;
              if (!_isEditable) {
                // Sauvegarder la valeur quand on quitte le mode édition
                print('Valeur sauvegardée: ${_controller.text}');
              }
            });
          },
        ),
      ),
      style: TextStyle(
        color: _isEditable
            ? Colors.black12
            : AppStyles.titleMedium(context).color,
      ),
    );
  }
}
