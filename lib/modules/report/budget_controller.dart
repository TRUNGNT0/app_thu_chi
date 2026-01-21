import 'package:get/get.dart';
import '../../core/services/local_storage.dart';
import '../profile/profile_controller.dart';

class BudgetController extends GetxController {
  static const double DEFAULT_BUDGET = 5000000; // 5 triệu đồng

  final LocalStorage _storage = LocalStorage();
  var monthlyBudget = DEFAULT_BUDGET.obs;

  @override
  void onInit() {
    super.onInit();
    loadBudget(DateTime.now());
    
    // Listen to currency changes to trigger UI updates
    try {
      final profileController = Get.find<ProfileController>();
      ever(profileController.currency, (currency) {
        // Notify UI to rebuild by refreshing the observable
        monthlyBudget.refresh();
      });
    } catch (e) {
      // ProfileController might not be initialized yet
    }
  }

  /// Tạo key duy nhất cho tháng/năm (VD: budget_2024_01)
  String _getBudgetKey(DateTime date) {
    return 'budget_${date.year}_${date.month.toString().padLeft(2, '0')}';
  }

  /// Lấy ngân sách của tháng cụ thể
  Future<void> loadBudget(DateTime date) async {
    final key = _getBudgetKey(date);
    final savedBudget = _storage.getDouble(key);
    if (savedBudget != null) {
      monthlyBudget.value = savedBudget;
    } else {
      monthlyBudget.value = DEFAULT_BUDGET;
    }
  }

  /// Cập nhật ngân sách cho tháng cụ thể
  Future<void> setBudget(DateTime date, double budget) async {
    final key = _getBudgetKey(date);
    await _storage.setDouble(key, budget);
    monthlyBudget.value = budget;
  }

  /// Reset ngân sách tháng về mặc định
  Future<void> resetBudget(DateTime date) async {
    await setBudget(date, DEFAULT_BUDGET);
  }
}
