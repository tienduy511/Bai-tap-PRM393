import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextInputAction action;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String? Function(String?) validator;
  final Function(String?) onSaved;

  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscure = false,
    required this.action,
    required this.focusNode,
    this.nextFocus,
    required this.validator,
    required this.onSaved,

    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      obscureText: obscure,
      focusNode: focusNode,
      textInputAction: action,

      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      validator: validator,
      onSaved: onSaved,

      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
    );
  }
}