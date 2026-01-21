import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/currency_helper.dart';
import 'statistic_controller.dart';

class StatisticScreen extends StatelessWidget {
  final StatisticController controller = Get.put(StatisticController());

  StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê chi tiêu"),
        centerTitle: true,
        backgroundColor: Colors.amber, // Màu vàng cho đồng bộ
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. THANH CHỌN THÁNG (MỚI)
          Container(
            color: Colors.amber, // Nền vàng
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => controller.changeMonth(-1), // Lùi 1 tháng
                ),
                Obx(() => Text(
                  "Tháng ${controller.selectedDate.value.month}/${controller.selectedDate.value.year}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () => controller.changeMonth(1), // Tiến 1 tháng
                ),
              ],
            ),
          ),

          // 2. PHẦN NỘI DUNG BIỂU ĐỒ
          Expanded(
            child: Obx(() {
              if (controller.statList.isEmpty) {
                return Center(
                  child: Text(
                    "Không có chi tiêu trong tháng ${controller.selectedDate.value.month}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 20),
                  // Biểu đồ tròn
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: controller.statList.map((stat) {
                          return PieChartSectionData(
                            color: stat.color,
                            value: stat.amount,
                            title: '${stat.percentage.toStringAsFixed(1)}%',
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Divider(),

                  // Danh sách chi tiết
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.statList.length,
                      itemBuilder: (context, index) {
                        final stat = controller.statList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: stat.color,
                            radius: 15,
                            child: Icon(Icons.circle, color: Colors.white, size: 10), 
                            // Hoặc hiển thị icon danh mục nếu bạn muốn sửa CategoryStat để lưu cả Icon
                          ),
                          title: Text(stat.categoryName),
                          trailing: Text(
                            CurrencyHelper.format(stat.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: LinearProgressIndicator(
                            value: stat.percentage / 100,
                            backgroundColor: Colors.grey[200],
                            color: stat.color,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}