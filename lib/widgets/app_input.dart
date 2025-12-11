import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.prefixText,
    this.prefixIcon,
    this.focusNode,
    this.onTap,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final TextAlign textAlign;
  final String? prefixText;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = Colors.green; // slight green tint for borders
    final textColor = isDark
        ? Colors.white
        : Colors.black; // keep text dark since fill is white
    final fill = isDark
        ? Colors.grey.shade900
        : Colors.white; // keep input background white in both modes

    OutlineInputBorder _border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: 1),
        );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      textAlign: textAlign,
      style: TextStyle(color: textColor),
      focusNode: focusNode,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        prefixText: prefixText,
        prefixIcon: prefixIcon,
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: TextStyle(color: textColor),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: fill,
        border: _border(borderColor.withOpacity(0.5)),
        enabledBorder: _border(borderColor.withOpacity(0.5)),
        focusedBorder: _border(borderColor),
        counterText: maxLength != null ? '' : null,
      ),
    );
  }
}
