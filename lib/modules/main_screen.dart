import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'report/report_screen.dart';
import 'home/home_screen.dart';
import 'statistic/statistic_screen.dart';
import 'transaction/add_transaction_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),      // 0. Trang chủ
    StatisticScreen(), // 1. Biểu đồ
    Container(),       // 2. Nút cộng
    const ReportScreen(), // 3. Báo cáo
    const ProfileScreen(),     // 4. Tôi
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      Get.to(() => const AddTransactionScreen());
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: "Trang chủ"),
          const BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: "Biểu đồ"),
          
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD54F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
            label: "",
          ),
          
          const BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined), label: "Báo cáo"),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tôi"),
        ],
      ),
    );
  }
}