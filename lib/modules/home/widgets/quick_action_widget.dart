import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../transaction/add_transaction_screen.dart';

/// Widget Shortcut nhanh để thêm giao dịch
class QuickActionWidget extends StatelessWidget {
  const QuickActionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickButton(
              icon: Icons.shopping_bag,
              label: "Mua sắm",
              color: Colors.orange,
              onTap: () {
                Get.to(() => AddTransactionScreen());
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickButton(
              icon: Icons.restaurant,
              label: "Ăn uống",
              color: Colors.pink,
              onTap: () {
                Get.to(() => AddTransactionScreen());
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickButton(
              icon: Icons.payment,
              label: "Thanh toán",
              color: Colors.purple,
              onTap: () {
                Get.to(() => AddTransactionScreen());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
