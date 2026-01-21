import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../transaction/transaction_controller.dart';
import '../../profile/profile_controller.dart';
import '../../../core/utils/currency_helper.dart';

class TotalCard extends StatelessWidget {
  // Tìm Controller đang hoạt động để lấy số liệu
  final TransactionController controller = Get.find<TransactionController>();
  final ProfileController profileController = Get.find<ProfileController>();

  TotalCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng Obx để khi số tiền thay đổi, widget này tự vẽ lại
    return Obx(() {
      // Lấy ngân sách từ ProfileController
      final initialMoney = profileController.initialMoney.value;
      
      // Tính tiền hiện có (tiền gốc + thu nhập - chi tiêu)
      final currentMoney = initialMoney + controller.totalIncome - controller.totalExpense;

      return Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Dòng 1: Tiền hiện có
              const Text("Tiền hiện có", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                CurrencyHelper.format(currentMoney),
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: currentMoney >= 0 ? Colors.green : Colors.red
                ),
              ),
              const Divider(height: 30, thickness: 1),
              
              // Dòng 2: Chia đôi Thu và Chi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Cột Thu
                  Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text("Thu nhập"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyHelper.format(controller.totalIncome),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  
                  // Cột Chi
                  Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text("Chi tiêu"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyHelper.format(controller.totalExpense),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}