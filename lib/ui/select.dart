import 'package:flutter/material.dart';

class SelectWidget extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
  final String? value;
  final Function(String?) onChanged;
  final String hintText;

  const SelectWidget({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hintText
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      // better ui. change styles
      isExpanded: true,
      itemHeight: 60,
      hint: Text(hintText),
      value: value,
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down),
      items: items,
    );
  }
}