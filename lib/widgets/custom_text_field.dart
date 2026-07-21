import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;

  // New Optional Properties
  final Color? fillColor;
  final Color textColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.fillColor,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,

      // Text Color
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),

      decoration: InputDecoration(
        // Background
        filled: fillColor != null,
        fillColor: fillColor,

        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black,
        ),

        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Colors.black,
              )
            : null,
        suffixIcon: suffixIcon,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.teal,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),

        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 14,
        ),
      ),
    );
  }
}
