import 'package:flutter/foundation.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repo.dart';

class HomeController with ChangeNotifier {
  final TransactionRepository _transactionRepo = TransactionRepository();

  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Lấy tất cả giao dịch
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    _transactions = await _transactionRepo.getAllTransactions();
    
    _isLoading = false;
    notifyListeners();
  }

  // Lấy giao dịch theo tháng
  Future<List<Transaction>> getTransactionsByMonth(int month, int year) async {
    return await _transactionRepo.getTransactionsByMonth(month, year);
  }

  // Tính tổng thu nhập
  double get totalIncome => _transactions
      .where((item) => !item.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  // Tính tổng chi tiêu
  double get totalExpense => _transactions
      .where((item) => item.isExpense)
      .fold(0.0, (sum, item) => sum + item.amount);

  // Tính số dư
  double get balance => totalIncome - totalExpense;
}
