import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autofocus;
  final int? maxLength;
  final TextAlign textAlign;
  final TextStyle? style;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
    this.decoration,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    
    // Force keyboard to appear when field is focused
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      style: widget.style,
      readOnly: widget.readOnly,
      inputFormatters: widget.inputFormatters,
      autocorrect: widget.keyboardType != TextInputType.emailAddress && 
                   widget.keyboardType != TextInputType.visiblePassword,
      enableSuggestions: widget.keyboardType != TextInputType.visiblePassword,
      decoration: widget.decoration ?? InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: () {
        widget.onTap?.call();
        // Ensure keyboard shows when tapped
        Future.delayed(const Duration(milliseconds: 50), () {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        });
      },
    );
  }
} 