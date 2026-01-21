import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// Map một ID (String) sang Widget Icon. Thêm logic map ở đây.
Widget iconFromId(String id, {Color? color}) {
  switch (id) {
    case 'food':
      return Icon(Icons.fastfood, color: color);
    case 'transport':
      return Icon(Icons.directions_car, color: color);
    default:
      return Icon(Icons.help_outline, color: color);
  }
}
