import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/utils/currency_helper.dart';
import '../../core/utils/category_helper.dart';
import '../transaction/transaction_controller.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TransactionController controller = Get.find<TransactionController>();
  
  // Ngày đang được chọn trên lịch
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch"),
        backgroundColor: const Color(0xFFFFD54F), // Màu vàng
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 1. WIDGET LỊCH
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            
            // Cấu hình giao diện lịch giống ảnh
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Color(0xFFFFD54F), shape: BoxShape.circle),
              todayTextStyle: TextStyle(color: Colors.white),
              selectedTextStyle: TextStyle(color: Colors.black),
              cellMargin: EdgeInsets.symmetric(vertical: 6),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              weekendStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              decoration: const BoxDecoration(color: Colors.transparent),
              dowTextFormatter: (date, locale) {
                // Format: Sun, Mon, Tue, Wed, Thu, Fri, Sat
                const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                return days[date.weekday % 7];
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // Ẩn nút "2 weeks", "Month"
              titleCentered: true,
              headerPadding: EdgeInsets.only(bottom: 12),
            ),
            
            // Xử lý khi bấm vào ngày
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            
            // Hiển thị chấm nhỏ dưới ngày có giao dịch
            eventLoader: (day) {
              // Lọc xem ngày đó có giao dịch không
              return controller.transactionList
                  .where((t) => isSameDay(t.date, day))
                  .toList();
            },
          ),
          
          const Divider(thickness: 5, color: Colors.grey), // Đường kẻ ngăn cách

          // 2. DANH SÁCH GIAO DỊCH CỦA NGÀY ĐƯỢC CHỌN
          Expanded(
            child: Obx(() {
              // Lọc danh sách theo ngày đang chọn (_selectedDay)
              final dailyTransactions = controller.transactionList
                  .where((t) => 
                      t.date.year == _selectedDay.year && 
                      t.date.month == _selectedDay.month && 
                      t.date.day == _selectedDay.day)
                  .toList();

              if (dailyTransactions.isEmpty) {
                return const Center(child: Text("Không có giao dịch ngày này"));
              }

              return ListView.builder(
                itemCount: dailyTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = dailyTransactions[index];
                  final category = CategoryHelper.getCategoryById(transaction.category);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color.withOpacity(0.2),
                      child: Icon(category.icon, color: category.color),
                    ),
                    title: Text(transaction.note.isEmpty ? category.name : transaction.note),
                    trailing: Text(
                      '${transaction.isExpense ? '-' : '+'}${CurrencyHelper.format(transaction.amount)}',
                      style: TextStyle(
                        color: transaction.isExpense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}