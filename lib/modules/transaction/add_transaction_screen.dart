import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../core/utils/category_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../core/services/search_service.dart';
import 'transaction_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction; // null = thêm mới, có giá trị = chỉnh sửa
  
  const AddTransactionScreen({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with SingleTickerProviderStateMixin {
  final TransactionController controller = Get.find<TransactionController>();
  late TabController _tabController;
  bool get isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    // Xác định tab ban đầu dựa vào loại giao dịch
    int initialTab = 0;
    if (isEditMode) {
      // Nếu là chế độ edit, xác định tab dựa vào transaction hiện tại
      Category category = CategoryHelper.getCategoryById(widget.transaction!.category);
      initialTab = CategoryHelper.expenseCategories.contains(category) ? 0 : 1;
    }
    _tabController = TabController(length: 2, initialIndex: initialTab, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // HÀM QUAN TRỌNG: Hiển thị popup nhập tiền sau khi chọn icon
  void _showInputModal(Category category) {
    final amountController = TextEditingController(
      text: isEditMode ? widget.transaction!.amount.toString() : ""
    );
    final noteController = TextEditingController(
      text: isEditMode ? widget.transaction!.note : ""
    );
    DateTime selectedDate = isEditMode ? widget.transaction!.date : DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để popup full màn hình hoặc cao lên
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Đẩy lên khi phím hiện
              left: 16, right: 16, top: 16
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Tiêu đề: Icon + Tên danh mục đã chọn
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: category.color.withOpacity(0.2),
                      child: Icon(category.icon, color: category.color),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEditMode ? "Chỉnh sửa giao dịch" : category.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Nhập số tiền
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true, // Tự động bật bàn phím
                  decoration: const InputDecoration(
                    labelText: "Số tiền",
                    border: OutlineInputBorder(),
                    suffixText: "đ",
                  ),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 15),

                // 3. Chọn ngày (với DatePicker)
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.black, // Màu đen cho nút OK
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFFFFD54F)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateHelper.formatDate(selectedDate),
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 4. Nhập ghi chú
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: "Ghi chú",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 15),

                // 5. Nút Lưu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black), // Màu đen
                    onPressed: () {
                      if (amountController.text.isEmpty) return;

                      if (isEditMode) {
                        // Chế độ chỉnh sửa
                        final updatedTransaction = Transaction(
                          id: widget.transaction!.id,
                          amount: double.parse(amountController.text),
                          note: noteController.text.isEmpty ? category.name : noteController.text,
                          date: selectedDate,
                          isExpense: widget.transaction!.isExpense,
                          category: widget.transaction!.category,
                        );
                        controller.updateTransaction(updatedTransaction);
                        Get.back(); // Đóng Modal
                        Get.back(); // Quay về Detail screen
                        Get.back(); // Quay về Home
                        Get.snackbar("Thành công", "Đã cập nhật giao dịch");
                      } else {
                        // Chế độ thêm mới
                        final newTransaction = Transaction(
                          amount: double.parse(amountController.text),
                          note: noteController.text.isEmpty ? category.name : noteController.text,
                          date: selectedDate,
                          isExpense: category.isExpense,
                          category: category.id,
                        );

                        controller.addTransaction(newTransaction);
                        Get.back(); // Đóng Modal
                        Get.back(); // Quay về Home
                        Get.snackbar("Thành công", "Đã thêm giao dịch");
                      }
                    },
                    child: Text(
                      isEditMode ? "CẬP NHẬT" : "LƯU",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị lưới Icon
  Widget _buildCategoryGrid(List<Category> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 cột giống ảnh
        childAspectRatio: 0.8, // Tỉ lệ chiều cao/rộng
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () => _showInputModal(cat), // Bấm vào thì hiện popup nhập
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Vòng tròn xám bao quanh icon
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[200],
                child: Icon(cat.icon, color: Colors.grey[700], size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                cat.name, 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Màu vàng đặc trưng
    const Color primaryYellow = Color(0xFFFFD54F); 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryYellow,
        title: Text(
          isEditMode ? "Chỉnh sửa" : "Thêm",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Get.back(),
          child: const Text("Hủy", style: TextStyle(color: Colors.black)),
        ),
        // PHẦN TAB BAR CHUYỂN ĐỔI
        bottom: !isEditMode ? TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Chi tiêu"),
            Tab(text: "Thu nhập"),
          ],
        ) : null,
      ),
      
      // Nội dung thay đổi theo Tab
      body: isEditMode
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.edit, size: 48, color: Color(0xFFFFD54F)),
                      const SizedBox(height: 16),
                      const Text(
                        "Nhấn vào danh mục để chỉnh sửa",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Giao dịch hiện tại: ${CategoryHelper.getCategoryById(widget.transaction!.category).name}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () => _showInputModal(
                          CategoryHelper.getCategoryById(widget.transaction!.category)
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD54F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Chỉnh sửa ngay",
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
              ],
            ),
          )
        : TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Lưới Chi tiêu
            _buildCategoryGrid(CategoryHelper.expenseCategories),
            
            // Tab 2: Lưới Thu nhập
            _buildCategoryGrid(CategoryHelper.incomeCategories),
            
            // Tab 3: Chuyển khoản (Tạm thời để trống)
            const Center(child: Text("Tính năng đang phát triển")),
          ],
        ),
    );
  }
}