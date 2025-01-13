import 'package:coyotex/core/utills/app_colors.dart';
import 'package:flutter/material.dart';

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
  final String? Function(String?)? validator;
  final Color? backgroundColor; // New background color property

  const BrandedTextField({
    super.key,
    this.validator,
    this.isEnabled = true,
    this.isFilled = true,
    required this.controller,
    this.prefix,
    required this.labelText,
    this.height = 55,
    this.sufix,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.isPassword = false,
    this.backgroundColor, // Initialize the new background color property
  });

  @override
  _BrandedTextFieldState createState() => _BrandedTextFieldState();
}

class _BrandedTextFieldState extends State<BrandedTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: TextFormField(
        validator: widget.validator,
        enabled: widget.isEnabled,
        onTap: widget.onTap,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Pallete.textColor),
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        obscureText: widget.isPassword ? _isObscured : false,
        decoration: InputDecoration(
          fillColor: Colors.white, //const Color.fromARGB(255, 226, 226, 245),
          filled: widget.isFilled,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Pallete.whiteColor),
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Pallete.accentColor), // Change the color as desired
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Pallete.outLineColor), // Change the color as desired
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          hintText: widget.labelText,
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
                      padding: const EdgeInsets.all(12),
                      child: widget.sufix,
                    )
                  : null,
          prefixIcon: widget.prefix != null
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: widget.prefix,
                )
              : null,
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color.fromRGBO(103, 103, 103, 1),
              fontSize: 12),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
