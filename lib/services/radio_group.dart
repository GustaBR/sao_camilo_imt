import 'package:flutter/material.dart';

class CustomRadioGroup extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const CustomRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<bool>(
          title: const Text('Sim'),
          value: true,
          groupValue: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFB30000),
        ),
        RadioListTile<bool>(
          title: const Text('Não'),
          value: false,
          groupValue: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFB30000),
        ),
      ],
    );
  }
}