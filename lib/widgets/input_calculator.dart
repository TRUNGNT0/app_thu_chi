import 'package:flutter/material.dart';

/// Bàn phím số đơn giản (stub)
class InputCalculator extends StatelessWidget {
  final ValueChanged<String>? onSubmit;
  const InputCalculator({Key? key, this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(height: 240, color: Colors.grey[200], child: const Center(child: Text('Numeric Pad')));
  }
}
