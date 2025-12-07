import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget{
  final  int maxLines;
  final String label;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextInputType type;
   
  const CustomInputField({super.key, required this.label, required this.validator, required this.onSaved, required this.type, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        
        enabledBorder: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent)
        ),
        errorBorder: const OutlineInputBorder(),
        label: Text(label),
      ),
      validator: validator,
      onSaved: onSaved,
      keyboardType: type,
    );
  }
}