import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the ProfileController from GetX
    final profileController = Get.find<ProfileController>();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        title: const Text("Cài đặt", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== SECTION 1: NGÂN SÁCH =====
              _buildSectionTitle("Ngân Sách"),
              _buildSettingCard(
                title: "Tiền gốc",
                value: "${profileController.initialMoney.value.toStringAsFixed(0)} ${profileController.currency.value}",
                onTap: () => _showInitialMoneyDialog(profileController),
              ),

              const SizedBox(height: 24),

              // ===== SECTION 2: CÀI ĐẶT =====
              _buildSectionTitle("Cài Đặt"),
              _buildSettingCard(
                title: "Loại tiền tệ",
                value: profileController.currency.value,
                onTap: () => _showCurrencyDialog(profileController),
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // ===== CÁC HÀM HỖ TRỢ =====

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ===== DIALOGS =====

  void _showInitialMoneyDialog(ProfileController controller) {
    final initialMoneyController = TextEditingController(
      text: controller.initialMoney.value.toStringAsFixed(0),
    );
    Get.dialog(
      AlertDialog(
        title: const Text("Cập nhật tiền gốc"),
        content: TextField(
          controller: initialMoneyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Số tiền (đ)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              double money = double.tryParse(initialMoneyController.text) ?? 0;
              await controller.updateInitialMoney(money);
              Get.back();
              Get.snackbar("Thành công", "Đã cập nhật tiền gốc");
            },
            child: const Text("Lưu", style: TextStyle(color: Color(0xFFFFD54F))),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(ProfileController controller) {
    List<String> currencies = ['VNĐ', 'USD'];
    Get.dialog(
      AlertDialog(
        title: const Text("Chọn tiền tệ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: controller.currency.value,
              onChanged: (value) async {
                if (value != null) {
                  await controller.updateCurrency(value);
                  Get.back();
                  Get.snackbar("Thành công", "Đã cập nhật tiền tệ và convert tất cả dữ liệu");
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
