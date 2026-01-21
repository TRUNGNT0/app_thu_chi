import 'package:get/get.dart';
import '../../core/services/local_storage.dart';
import '../../data/repositories/transaction_repo.dart';
import '../transaction/transaction_controller.dart';
import '../report/budget_controller.dart';

class ProfileController extends GetxController {
  final LocalStorage _localStorage = LocalStorage();
  final TransactionRepository _transactionRepo = TransactionRepository();

  late RxDouble _monthlyBudget;
  late RxDouble _initialMoney;
  late RxString _currency;
  
  // Tỷ giá: 1 USD = 26.000 VND
  static const double usdToVnd = 26000;

  RxDouble get monthlyBudget => _monthlyBudget;
  RxDouble get initialMoney => _initialMoney;
  RxString get currency => _currency;

  @override
  void onInit() {
    super.onInit();
    _monthlyBudget = RxDouble(5000000);
    _initialMoney = RxDouble(0);
    _currency = RxString('VNĐ');
    _loadSettings();
  }

  // Tải cài đặt từ storage
  Future<void> _loadSettings() async {
    _monthlyBudget.value = _localStorage.getDouble('monthlyBudget') ?? 5000000;
    _initialMoney.value = _localStorage.getDouble('initialMoney') ?? 0;
    _currency.value = _localStorage.getString('currency') ?? 'VNĐ';
  }

  // Cập nhật ngân sách hàng tháng
  Future<void> updateMonthlyBudget(double budget) async {
    _monthlyBudget.value = budget;
    await _localStorage.setDouble('monthlyBudget', budget);
  }

  // Cập nhật tiền gốc
  Future<void> updateInitialMoney(double money) async {
    _initialMoney.value = money;
    await _localStorage.setDouble('initialMoney', money);
  }

  // Cập nhật loại tiền tệ và convert all data
  Future<void> updateCurrency(String currency) async {
    if (_currency.value == currency) return; // Không thay đổi
    
    String oldCurrency = _currency.value;
    _currency.value = currency;
    
    // Nếu chuyển từ VND sang USD hoặc ngược lại, cần convert tất cả dữ liệu
    if ((oldCurrency == 'VNĐ' && currency == 'USD') || 
        (oldCurrency == 'USD' && currency == 'VNĐ')) {
      // Convert ngân sách
      if (oldCurrency == 'VNĐ' && currency == 'USD') {
        _monthlyBudget.value = _monthlyBudget.value / usdToVnd;
        _initialMoney.value = _initialMoney.value / usdToVnd;
      } else {
        _monthlyBudget.value = _monthlyBudget.value * usdToVnd;
        _initialMoney.value = _initialMoney.value * usdToVnd;
      }
      
      // Convert tất cả giao dịch trong database
      await _convertAllTransactionsCurrency(oldCurrency, currency);
      
      // Lưu các giá trị đã convert
      await _localStorage.setDouble('monthlyBudget', _monthlyBudget.value);
      await _localStorage.setDouble('initialMoney', _initialMoney.value);
      
      // IMPORTANT: Reload data in other controllers after conversion
      try {
        // Reload transactions in TransactionController
        final transactionController = Get.find<TransactionController>();
        transactionController.loadTransactions();
        
        // Reload budget in BudgetController
        final budgetController = Get.find<BudgetController>();
        budgetController.loadBudget(DateTime.now());
      } catch (e) {
        print('Error reloading controllers: $e');
      }
    }
    
    await _localStorage.setString('currency', currency);
  }

  // Convert tất cả giao dịch khi đổi tiền tệ
  Future<void> _convertAllTransactionsCurrency(String fromCurrency, String toCurrency) async {
    try {
      // Lấy tất cả giao dịch
      final transactions = await _transactionRepo.getAllTransactions();
      
      for (var transaction in transactions) {
        double newAmount = transaction.amount;
        
        if (fromCurrency == 'VNĐ' && toCurrency == 'USD') {
          newAmount = transaction.amount / usdToVnd;
        } else if (fromCurrency == 'USD' && toCurrency == 'VNĐ') {
          newAmount = transaction.amount * usdToVnd;
        }
        
        // Update giao dịch với giá trị mới
        final updatedTransaction = transaction.copyWith(amount: newAmount);
        await _transactionRepo.updateTransaction(updatedTransaction);
      }
      
      // Also convert all stored budgets for each month/year
      await _convertAllStoredBudgets(fromCurrency, toCurrency);
    } catch (e) {
      print('Error converting transactions: $e');
    }
  }

  // Convert tất cả ngân sách được lưu trong localStorage
  Future<void> _convertAllStoredBudgets(String fromCurrency, String toCurrency) async {
    try {
      // Get all keys from localStorage
      final allKeys = _localStorage.getAllKeys();
      
      for (String key in allKeys) {
        // Check if key is a budget key (format: budget_YYYY_MM)
        if (key.startsWith('budget_')) {
          final budgetValue = _localStorage.getDouble(key);
          if (budgetValue != null) {
            double convertedBudget = budgetValue;
            
            if (fromCurrency == 'VNĐ' && toCurrency == 'USD') {
              convertedBudget = budgetValue / usdToVnd;
            } else if (fromCurrency == 'USD' && toCurrency == 'VNĐ') {
              convertedBudget = budgetValue * usdToVnd;
            }
            
            await _localStorage.setDouble(key, convertedBudget);
          }
        }
      }
    } catch (e) {
      print('Error converting budgets: $e');
    }
  }

  // Xóa tất cả dữ liệu
  Future<bool> clearAllData() async {
    try {
      await _transactionRepo.deleteAllTransactions();
      await _localStorage.clear();
      await _loadSettings();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Lấy thông tin app
  Map<String, String> getAppInfo() {
    return {
      'version': '1.0.0',
      'buildNumber': '1',
      'name': 'Money Manager',
      'author': 'Your Name',
    };
  }
}
