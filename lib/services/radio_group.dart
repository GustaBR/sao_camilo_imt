// lib/screens/services/radio_group.dart
import 'package:flutter/material.dart';

class RadioGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroupInherited<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }
}

class RadioGroupInherited<T> extends InheritedWidget {
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const RadioGroupInherited({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required super.child,
  });

  static RadioGroupInherited<T?> of<T>(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<RadioGroupInherited<T?>>();
    assert(result != null, 'No RadioGroupInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant RadioGroupInherited oldWidget) {
    return groupValue != oldWidget.groupValue;
  }
}

class RadioOption<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const RadioOption({
    super.key,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final group = RadioGroupInherited<T?>.of(context);
    return GestureDetector(
      onTap: () => group.onChanged(value),
      child: Row(
        children: [
          Radio<T>(
            value: value,
            groupValue: group.groupValue,
            onChanged: group.onChanged,
            activeColor: const Color(0xFFB30000),
          ),
          child,
        ],
      ),
    );
  }
}