import 'package:intl/intl.dart';
import '../../data/models/transaction.dart';
import '../utils/category_helper.dart';

class SearchService {
  /// Tìm kiếm giao dịch theo từ khóa (tên ghi chú hoặc danh mục)
  static List<Transaction> searchByKeyword(
    List<Transaction> transactions,
    String keyword,
  ) {
    if (keyword.isEmpty) return transactions;
    
    final lowerKeyword = keyword.toLowerCase();
    return transactions.where((t) {
      return t.note.toLowerCase().contains(lowerKeyword) ||
             t.category.toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  /// Lọc giao dịch theo khoảng ngày
  static List<Transaction> filterByDateRange(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return transactions.where((t) {
      return t.date.isAfter(startDate) && t.date.isBefore(normalizedEnd);
    }).toList();
  }

  /// Lọc giao dịch theo danh mục
  static List<Transaction> filterByCategory(
    List<Transaction> transactions,
    String categoryId,
  ) {
    if (categoryId.isEmpty) return transactions;
    return transactions.where((t) => t.category == categoryId).toList();
  }

  /// Lọc giao dịch theo loại (chi/thu)
  static List<Transaction> filterByType(
    List<Transaction> transactions,
    bool? isExpense,
  ) {
    if (isExpense == null) return transactions;
    return transactions.where((t) => t.isExpense == isExpense).toList();
  }

  /// Lọc giao dịch theo số tiền (min - max)
  static List<Transaction> filterByAmount(
    List<Transaction> transactions,
    double? minAmount,
    double? maxAmount,
  ) {
    return transactions.where((t) {
      if (minAmount != null && t.amount < minAmount) return false;
      if (maxAmount != null && t.amount > maxAmount) return false;
      return true;
    }).toList();
  }

  /// Tìm kiếm nâng cao với đa tiêu chí
  static List<Transaction> advancedSearch(
    List<Transaction> transactions, {
    String? keyword,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    bool? isExpense,
    double? minAmount,
    double? maxAmount,
  }) {
    var results = transactions;

    // Áp dụng từng filter
    if (keyword != null && keyword.isNotEmpty) {
      results = searchByKeyword(results, keyword);
    }

    if (startDate != null && endDate != null) {
      results = filterByDateRange(results, startDate, endDate);
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      results = filterByCategory(results, categoryId);
    }

    if (isExpense != null) {
      results = filterByType(results, isExpense);
    }

    if (minAmount != null || maxAmount != null) {
      results = filterByAmount(results, minAmount, maxAmount);
    }

    return results;
  }

  /// Tìm kiếm với sắp xếp
  static List<Transaction> searchWithSort(
    List<Transaction> transactions,
    String sortBy, // 'date', 'amount', 'name'
    {bool isAscending = false}
  ) {
    final sorted = List<Transaction>.from(transactions);
    
    switch (sortBy) {
      case 'date':
        sorted.sort((a, b) {
          final comparison = a.date.compareTo(b.date);
          return isAscending ? comparison : -comparison;
        });
        break;
      case 'amount':
        sorted.sort((a, b) {
          final comparison = a.amount.compareTo(b.amount);
          return isAscending ? comparison : -comparison;
        });
        break;
      case 'name':
        sorted.sort((a, b) {
          final comparison = a.note.compareTo(b.note);
          return isAscending ? comparison : -comparison;
        });
        break;
    }
    
    return sorted;
  }

  /// Nhóm giao dịch theo tháng
  static Map<String, List<Transaction>> groupByMonth(
    List<Transaction> transactions,
  ) {
    Map<String, List<Transaction>> grouped = {};
    
    for (var transaction in transactions) {
      final monthKey = DateFormat('yyyy-MM').format(transaction.date);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }
    
    return grouped;
  }

  /// Nhóm giao dịch theo danh mục
  static Map<String, List<Transaction>> groupByCategory(
    List<Transaction> transactions,
  ) {
    Map<String, List<Transaction>> grouped = {};
    
    for (var transaction in transactions) {
      final categoryId = transaction.category;
      if (!grouped.containsKey(categoryId)) {
        grouped[categoryId] = [];
      }
      grouped[categoryId]!.add(transaction);
    }
    
    return grouped;
  }

  /// Tìm kiếm danh mục theo từ khóa
  /// Trả về danh sách Category khớp với keyword
  static searchCategoriesFromTransactions(
    List<Transaction> transactions,
    String keyword,
    bool isExpense,
  ) {
    if (keyword.isEmpty) {
      return isExpense 
          ? CategoryHelper.expenseCategories 
          : CategoryHelper.incomeCategories;
    }
    
    return CategoryHelper.searchCategoriesByKeyword(keyword, isExpense);
  }
}
