import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/category_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/transaction.dart';
import '../transaction/transaction_controller.dart';
import '../profile/profile_controller.dart';
import '../category/category_list_screen.dart';
import 'budget_controller.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedTab = 0;
  late DateTime _selectedDate;
  final TransactionController controller = Get.find<TransactionController>();
  final BudgetController budgetController = Get.put(BudgetController());
  late final ProfileController profileController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    budgetController.loadBudget(_selectedDate);
    
    // Get ProfileController and listen to currency changes
    profileController = Get.find<ProfileController>();
    
    // When currency changes, rebuild the UI by calling setState
    ever(profileController.currency, (currency) {
      if (mounted) {
        setState(() {
          // Trigger rebuild when currency changes
        });
      }
    });
  }

  /// Lọc giao dịch theo tháng/năm đã chọn
  List<Transaction> _getTransactionsByMonth(List<Transaction> transactions) {
    return transactions.where((t) {
      return t.date.year == _selectedDate.year && t.date.month == _selectedDate.month;
    }).toList();
  }

  /// Tính tổng chi tiêu tháng đã chọn
  double _getTotalExpenseForMonth() {
    final filtered = _getTransactionsByMonth(controller.transactionList);
    return filtered.where((t) => t.isExpense).fold(0, (sum, t) => sum + t.amount);
  }

  /// Tính tổng thu nhập tháng đã chọn
  double _getTotalIncomeForMonth() {
    final filtered = _getTransactionsByMonth(controller.transactionList);
    return filtered.where((t) => !t.isExpense).fold(0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo cáo", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFD54F),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 0. CHỌN THÁNG/NĂM
          Container(
            color: const Color(0xFFFFD54F),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                      budgetController.loadBudget(_selectedDate);
                    });
                  },
                ),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        budgetController.loadBudget(_selectedDate);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Tháng ${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.black),
                  onPressed: _selectedDate.month == DateTime.now().month && _selectedDate.year == DateTime.now().year
                    ? null
                    : () {
                      setState(() {
                        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                        budgetController.loadBudget(_selectedDate);
                      });
                    },
                ),
              ],
            ),
          ),

          // 1. THANH TAB
          Container(
            color: const Color(0xFFFFD54F),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.black : const Color(0xFFFFD54F),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                        ),
                        child: Text(
                          "Phân tích",
                          style: TextStyle(
                            color: _selectedTab == 0 ? const Color(0xFFFFD54F) : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.black : const Color(0xFFFFD54F),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                        ),
                        child: Text(
                          "Tôi",
                          style: TextStyle(
                            color: _selectedTab == 1 ? const Color(0xFFFFD54F) : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. NỘI DUNG
          Expanded(
            child: _selectedTab == 0 
                ? _buildAnalysisTab() 
                : _buildAccountTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // CARD 1: THỐNG KÊ HÀNG THÁNG
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Thống kê", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                // --- Thống kê tháng đã chọn ---
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Chi tiêu", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyHelper.format(_getTotalExpenseForMonth()),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Thu nhập", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyHelper.format(_getTotalIncomeForMonth()),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 2: BIỂU ĐỒ CHI TIÊU THEO DANH MỤC
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Chi tiêu theo danh mục", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Biểu đồ Pie Chart
                // Obx(() => _buildExpensePieChart()),
                
                const SizedBox(height: 20),
                
                // Chi tiết từng danh mục
                Obx(() => _buildCategoryDetails()),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 3: NGÂN SÁCH
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Ngân sách hàng tháng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: _showBudgetDialog,
                      child: const Icon(Icons.edit, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 70, height: 70,
                      child: Stack(
                        children: [
                          Obx(
                            () => SizedBox(
                              width: 70, height: 70,
                              child: CircularProgressIndicator(
                                value: _getTotalExpenseForMonth() > 0 ? _getTotalExpenseForMonth() / budgetController.monthlyBudget.value : 0,
                                backgroundColor: Colors.grey[300],
                                strokeWidth: 8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getTotalExpenseForMonth() > budgetController.monthlyBudget.value ? Colors.red : Colors.green,
                                ),
                              ),
                            ),
                          ),
                          Obx(() => Center(
                            child: Text(
                              "${((_getTotalExpenseForMonth() / budgetController.monthlyBudget.value) * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    
                    Expanded(
                      child: Obx(() => Column(
                        children: [
                          _buildBudgetRow("Còn lại :", budgetController.monthlyBudget.value - _getTotalExpenseForMonth()),
                          const SizedBox(height: 8),
                          _buildBudgetRow("Ngân sách :", budgetController.monthlyBudget.value),
                          const SizedBox(height: 8),
                          _buildBudgetRow("Chi tiêu :", _getTotalExpenseForMonth()),
                        ],
                      )),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Biểu đồ Pie Chart chi tiêu theo danh mục
  Widget _buildExpensePieChart() {
    List<PieChartSectionData> sections = [];
    double totalExpense = _getTotalExpenseForMonth();

    if (totalExpense == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Chưa có chi tiêu")),
      );
    }

    // Lọc chi tiêu tháng đã chọn và nhóm theo danh mục
    final expenses = _getTransactionsByMonth(controller.transactionList).where((t) => t.isExpense).toList();
    final Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    int colorIndex = 0;
    categoryTotals.forEach((category, total) {
      final percentage = (total / totalExpense) * 100;
      sections.add(
        PieChartSectionData(
          value: total,
          title: "${percentage.toStringAsFixed(1)}%",
          radius: 100,
          color: colors[colorIndex % colors.length],
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
      colorIndex++;
    });

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 50,
        ),
      ),
    );
  }

  // Chi tiết chi tiêu theo danh mục (tháng đã chọn)
  Widget _buildCategoryDetails() {
    // Lọc chi tiêu tháng đã chọn và nhóm theo danh mục
    final expenses = _getTransactionsByMonth(controller.transactionList).where((t) => t.isExpense).toList();
    final Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sắp xếp theo tiền giảm dần
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        const Divider(),
        ...sortedCategories.map((entry) {
          final category = CategoryHelper.getCategoryById(entry.key);
          return InkWell(
            onTap: () {
              Get.to(() => CategoryListScreen(
              category: category,
              month: _selectedDate,
            ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: category.color.withOpacity(0.3),
                    child: Icon(
                      category.icon,
                      size: 16,
                      color: category.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    CurrencyHelper.format(entry.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // CARD 2: NGÂN SÁCH
  Widget _buildBudgetRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            CurrencyHelper.format(amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Tab Tài khoản - Cài đặt ngân sách
  Widget _buildAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // CARD 1: CÀI ĐẶT NGÂN SÁCH
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ngân sách hàng tháng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Hiển thị ngân sách hiện tại
                Obx(() => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Ngân sách hiện tại:",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          CurrencyHelper.format(budgetController.monthlyBudget.value),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),

                // Nút chỉnh sửa
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _showBudgetDialog,
                    child: const Text(
                      "Chỉnh sửa ngân sách",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 2: THỐNG KÊ TỔNG HỢP
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Thống kê tổng hợp",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                Obx(() => Column(
                  children: [
                    _buildStatRow("Tổng chi tiêu", controller.totalExpense, Colors.red),
                    const SizedBox(height: 12),
                    _buildStatRow("Tổng thu nhập", controller.totalIncome, Colors.green),
                    const SizedBox(height: 12),
                    _buildStatRow("Số dư", controller.balance, Colors.blue),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      "Còn lại trong tháng",
                      budgetController.monthlyBudget.value - controller.totalExpense,
                      controller.totalExpense > budgetController.monthlyBudget.value ? Colors.red : Colors.green,
                    ),
                  ],
                )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 3: DANH MỤC CHI TIÊU
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Danh mục chi tiêu lớn nhất",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                Obx(() {
                  final expenses = controller.transactionList.where((t) => t.isExpense).toList();
                  if (expenses.isEmpty) {
                    return const Center(
                      child: Text("Chưa có chi tiêu nào", style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // Nhóm theo danh mục
                  Map<String, double> categoryTotals = {};
                  for (var e in expenses) {
                    categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
                  }

                  // Sắp xếp
                  final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                  
                  // Lấy top 3
                  final top3 = sorted.take(3).toList();

                  return Column(
                    children: List.generate(
                      top3.length,
                      (index) {
                        final category = CategoryHelper.getCategoryById(top3[index].key);
                        final amount = top3[index].value;
                        final percent = (amount / controller.totalExpense * 100);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: category.color.withOpacity(0.3),
                                    child: Icon(category.icon, size: 14, color: category.color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ),
                                  Text(
                                    CurrencyHelper.format(amount),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent / 100,
                                  backgroundColor: Colors.grey[200],
                                  minHeight: 6,
                                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${percent.toStringAsFixed(1)}%",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper để hiển thị hàng thống kê
  Widget _buildStatRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            CurrencyHelper.format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Dialog chỉnh sửa ngân sách
  void _showBudgetDialog() {
    final textController = TextEditingController(
      text: budgetController.monthlyBudget.value.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cài đặt ngân sách"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Tháng ${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text("Nhập số tiền ngân sách (đ):"),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: "5,000,000",
                suffixText: "đ",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              budgetController.resetBudget(_selectedDate);
              Navigator.pop(context);
              setState(() {});
              Get.snackbar("Thành công", "Đã reset ngân sách về mặc định");
            },
            child: const Text("Reset", style: TextStyle(color: Colors.orange)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD54F)),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                final value = double.tryParse(textController.text.replaceAll(',', ''));
                if (value != null && value > 0) {
                  budgetController.setBudget(_selectedDate, value);
                  Navigator.pop(context);
                  setState(() {});
                  Get.snackbar("Thành công", "Ngân sách đã được cập nhật");
                }
              }
            },
            child: const Text(
              "Lưu",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}