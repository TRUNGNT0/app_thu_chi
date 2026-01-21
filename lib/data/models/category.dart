import 'package:flutter/material.dart';

class Category {
  final String id;        // ID để lưu vào Database (VD: "food", "salary")
  final String name;      // Tên hiển thị (VD: "Ăn uống")
  final IconData icon;    // Icon hiển thị
  final Color color;      // Màu nền icon cho đẹp
  final bool isExpense;   // true = Danh mục chi, false = Danh mục thu
  final List<String> keywords; // Từ khóa tìm kiếm (VD: ["ăn", "uống", "nhà hàng"])

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
    this.keywords = const [],
  });
}