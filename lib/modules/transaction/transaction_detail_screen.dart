import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/transaction.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/category_helper.dart';
import '../../core/widgets/custom_dialogs.dart';
import 'transaction_controller.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;
  
  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TextEditingController amountController;
  late TextEditingController noteController;
  late DateTime selectedDate;
  final TransactionController controller = Get.find<TransactionController>();

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.transaction.amount.toString());
    noteController = TextEditingController(text: widget.transaction.note);
    selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = CategoryHelper.getCategoryById(widget.transaction.category);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        title: const Text("Chi tiết giao dịch", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Danh mục
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: category.color.withOpacity(0.2),
                    child: Icon(category.icon, color: category.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          DateHelper.formatDate(selectedDate),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.transaction.isExpense ? '-' : '+'}${CurrencyHelper.format(widget.transaction.amount)}',
                    style: TextStyle(
                      color: widget.transaction.isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút Chỉnh sửa
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Get.to(
                    () => AddTransactionScreen(transaction: widget.transaction),
                    transition: Transition.rightToLeft,
                  );
                },
                child: const Text(
                  "CHỈNH SỬA",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nút xóa
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDialog(
                      title: "Xóa giao dịch?",
                      message: "Bạn có chắc chắn muốn xóa giao dịch này không? Hành động không thể hoàn tác.",
                      confirmText: "Xóa",
                      cancelText: "Hủy",
                      confirmColor: Colors.red,
                      onConfirm: () {
                        controller.deleteTransaction(widget.transaction.id!);
                        Get.back(); // Quay lại
                        Get.snackbar("Thành công", "Đã xóa giao dịch");
                      },
                    ),
                  );
                },
                child: const Text(
                  "XÓA",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
