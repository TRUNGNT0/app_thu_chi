import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/category.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/category_helper.dart';
import '../transaction/transaction_controller.dart';

class CategoryListScreen extends StatefulWidget {
  final Category category;
  
  const CategoryListScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final TransactionController controller = Get.find<TransactionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        title: Text(
          "Lịch sử - ${widget.category.name}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        // Lọc giao dịch theo danh mục
        final categoryTransactions = controller.transactionList
            .where((t) => t.category == widget.category.id)
            .toList();

        if (categoryTransactions.isEmpty) {
          return Center(
            child: Text(
              "Chưa có giao dịch nào cho danh mục '${widget.category.name}'",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        // Tính tổng
        final total = categoryTransactions.fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );

        return Column(
          children: [
            // Header với tổng
            Container(
              padding: const EdgeInsets.all(16),
              color: widget.category.color.withOpacity(0.1),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: widget.category.color.withOpacity(0.3),
                        child: Icon(
                          widget.category.icon,
                          color: widget.category.color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${categoryTransactions.length} giao dịch",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tổng",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            CurrencyHelper.format(total),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: widget.category.isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Trung bình",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            CurrencyHelper.format(total / categoryTransactions.length),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // Danh sách giao dịch
            Expanded(
              child: ListView.builder(
                itemCount: categoryTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = categoryTransactions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        transaction.note.isEmpty ? "Không ghi chú" : transaction.note,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        DateHelper.formatDate(transaction.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        '${widget.category.isExpense ? '-' : '+'}${CurrencyHelper.format(transaction.amount)}',
                        style: TextStyle(
                          color: widget.category.isExpense ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
