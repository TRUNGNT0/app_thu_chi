import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import Controller & Utils
import '../transaction/transaction_controller.dart';
import '../transaction/transaction_detail_screen.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/category_helper.dart';
import '../../data/models/category.dart';

// Import Widget con
import 'widgets/total_card.dart';
import 'calendar_screen.dart'; // Import màn hình lịch

class HomeScreen extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F), // Màu vàng chuẩn
        title: const Text('Sổ Thu Chi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () {
              Get.to(() => const CalendarScreen());
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          // 1. Bảng tổng kết
          TotalCard(),

          // 2. Danh sách giao dịch
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.transactionList.isEmpty) {
                return const Center(
                  child: Text(
                    "Chưa có giao dịch nào.\nBấm nút + ở dưới để thêm.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 20), // Chừa chút khoảng trống dưới cùng
                itemCount: controller.transactionList.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactionList[index];

                  return Dismissible(
                    key: ValueKey(transaction.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      controller.deleteTransaction(transaction.id!);
                      Get.snackbar("Đã xóa", "Giao dịch đã được xóa");
                    },
                    child: InkWell(
                      onTap: () {
                        Get.to(() => TransactionDetailScreen(transaction: transaction));
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: Builder(
                            builder: (context) {
                              Category cat = CategoryHelper.getCategoryById(transaction.category);
                              return CircleAvatar(
                                backgroundColor: cat.color.withOpacity(0.2),
                                child: Icon(cat.icon, color: cat.color),
                              );
                            },
                          ),
                          title: Text(
                            transaction.note.isEmpty ? "Không ghi chú" : transaction.note,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "${DateHelper.formatDate(transaction.date)} • ${CategoryHelper.getCategoryById(transaction.category).name}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${transaction.isExpense ? '-' : '+'}${CurrencyHelper.format(transaction.amount)}',
                            style: TextStyle(
                              color: transaction.isExpense ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      
      // ĐÃ XÓA PHẦN floatingActionButton Ở ĐÂY
    );
  }
}