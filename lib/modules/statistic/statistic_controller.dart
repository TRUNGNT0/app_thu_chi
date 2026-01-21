import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/category.dart';
import '../../core/utils/category_helper.dart';
import '../transaction/transaction_controller.dart';

class CategoryStat {
  final String categoryName;
  final double amount;
  final Color color;
  final double percentage;

  CategoryStat({
    required this.categoryName,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}

class StatisticController extends GetxController {
  final TransactionController _transactionController = Get.find<TransactionController>();

  var statList = <CategoryStat>[].obs;
  
  // 1. Thêm biến theo dõi tháng đang chọn (Mặc định là hôm nay)
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Khi danh sách giao dịch thay đổi HOẶC ngày chọn thay đổi -> Tính lại
    ever(_transactionController.transactionList, (_) => calculateStats());
    ever(selectedDate, (_) => calculateStats()); // <--- Thêm dòng này
    calculateStats();
  }

  // 2. Hàm chuyển tháng (tiến/lùi)
  void changeMonth(int monthsToAdd) {
    var newDate = DateTime(selectedDate.value.year, selectedDate.value.month + monthsToAdd);
    selectedDate.value = newDate;
  }

  void calculateStats() {
    // 3. Lọc dữ liệu: Chỉ lấy CHI TIÊU + TRONG THÁNG ĐANG CHỌN
    final allExpenses = _transactionController.transactionList
        .where((t) => t.isExpense)
        .where((t) => 
            t.date.month == selectedDate.value.month && 
            t.date.year == selectedDate.value.year
        ) // <--- Logic lọc tháng nằm ở đây
        .toList();

    if (allExpenses.isEmpty) {
      statList.clear();
      return;
    }

    double totalExpense = allExpenses.fold(0.0, (sum, item) => sum + item.amount);

    Map<String, double> group = {};
    for (var t in allExpenses) {
      if (group.containsKey(t.category)) {
        group[t.category] = group[t.category]! + t.amount;
      } else {
        group[t.category] = t.amount;
      }
    }

    List<CategoryStat> result = [];
    group.forEach((key, value) {
      Category cat = CategoryHelper.getCategoryById(key);
      result.add(CategoryStat(
        categoryName: cat.name,
        amount: value,
        color: cat.color,
        percentage: (value / totalExpense) * 100,
      ));
    });

    result.sort((a, b) => b.amount.compareTo(a.amount));
    statList.assignAll(result);
  }
}