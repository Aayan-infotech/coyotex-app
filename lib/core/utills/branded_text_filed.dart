import 'package:coyotex/core/utills/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrandedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final double height;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? sufix;
  final bool isFilled;
  final void Function(String)? onChanged;
  final int maxLines;
  final int minLines;
  final bool isEnabled;
  final bool isPassword;
  final void Function()? onTap;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? validator;
  final Color? backgroundColor;
  final double? fontSize; // New font size property
  final FocusNode? focusNode; // FocusNode parameter
  final int? maxLength;

  const BrandedTextField(
      {super.key,
      this.validator,
      this.isEnabled = true,
      this.isFilled = true,
      required this.controller,
      this.prefix,
      required this.labelText,
      this.height = 55,
      this.inputFormatters = const [],
      this.sufix,
      this.maxLines = 1,
      this.minLines = 1,
      this.keyboardType,
      this.onChanged,
      this.onTap,
      this.isPassword = false,
      this.backgroundColor,
      this.fontSize, // Accept font size
      this.focusNode, // Accept focus node
      this.maxLength});

  @override
  _BrandedTextFieldState createState() => _BrandedTextFieldState();
}

class _BrandedTextFieldState extends State<BrandedTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    double defaultFontSize =
        MediaQuery.of(context).size.width * 0.04; // Adaptive font size
    double fontSize = widget.fontSize ??
        defaultFontSize; // Use provided font size or fallback

    return TextFormField(
      validator: widget.validator,
      enabled: widget.isEnabled,
      onTap: widget.onTap,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: Pallete.textColor,
      ),
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      obscureText: widget.isPassword ? _isObscured : false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      focusNode: widget.focusNode,
      // Assign FocusNode here
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: widget.isFilled,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Pallete.whiteColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Pallete.accentColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Pallete.outLineColor),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        hintText: widget.labelText,
        hintStyle: TextStyle(
          fontSize: fontSize * 0.9, // Slightly smaller hint text
          color: Colors.grey,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Pallete.textColor,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : widget.sufix != null
                ? Padding(
                    padding: const EdgeInsets.all(12), child: widget.sufix)
                : null,
        prefixIcon: widget.prefix != null
            ? Padding(padding: const EdgeInsets.all(12), child: widget.prefix)
            : null,
        labelStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: const Color.fromRGBO(103, 103, 103, 1),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
