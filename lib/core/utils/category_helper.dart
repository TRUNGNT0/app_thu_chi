
import 'package:flutter/material.dart';
import '../../data/models/category.dart';

class CategoryHelper {
  // 1. Danh sách các hạng mục Chi tiêu
  static List<Category> expenseCategories = [
    Category(
      id: 'shopping', 
      name: 'Mua sắm', 
      icon: Icons.shopping_cart, 
      color: Colors.blue, 
      isExpense: true,
      keywords: ['mua', 'sắm', 'shopping', 'hàng', 'shop']
    ),
    Category(
      id: 'food', 
      name: 'Ăn uống', 
      icon: Icons.restaurant, 
      color: Colors.orange, 
      isExpense: true,
      keywords: ['ăn', 'uống', 'đồ ăn', 'cơm', 'bún', 'phở', 'nhà hàng', 'quán ăn', 'cafe', 'cà phê', 'bia']
    ),
    Category(
      id: 'phone', 
      name: 'Điện thoại', 
      icon: Icons.phone_iphone, 
      color: Colors.blueGrey, 
      isExpense: true,
      keywords: ['điện thoại', 'phone', 'sim', 'data', 'gói cước']
    ),
    Category(
      id: 'entertainment', 
      name: 'Giải trí', 
      icon: Icons.mic, 
      color: Colors.pink, 
      isExpense: true,
      keywords: ['giải trí', 'phim', 'nhạc', 'game', 'ca hát', 'karaoke', 'vé xem']
    ),
    Category(
      id: 'education', 
      name: 'Giáo dục', 
      icon: Icons.book, 
      color: Colors.brown, 
      isExpense: true,
      keywords: ['giáo dục', 'học', 'sách', 'khóa học', 'lớp học', 'trường']
    ),
    Category(
      id: 'beauty', 
      name: 'Sắc đẹp', 
      icon: Icons.face, 
      color: Colors.purple, 
      isExpense: true,
      keywords: ['sắc đẹp', 'mỹ phẩm', 'cắt tóc', 'spa', 'salon', 'mỹ viện']
    ),
    Category(
      id: 'sport', 
      name: 'Thể thao', 
      icon: Icons.pool, 
      color: Colors.cyan, 
      isExpense: true,
      keywords: ['thể thao', 'gym', 'tập', 'bơi', 'chạy', 'yoga']
    ),
    Category(
      id: 'social', 
      name: 'Xã hội', 
      icon: Icons.people, 
      color: Colors.teal, 
      isExpense: true,
      keywords: ['xã hội', 'hội hè', 'tiệc', 'dự tiệc', 'quà tặng']
    ),
    Category(
      id: 'transport', 
      name: 'Đi lại', 
      icon: Icons.directions_bus, 
      color: Colors.indigo, 
      isExpense: true,
      keywords: ['đi lại', 'xe buýt', 'taxi', 'grab', 'xăng', 'bến xe']
    ),
    Category(
      id: 'clothing', 
      name: 'Quần áo', 
      icon: Icons.checkroom, 
      color: Colors.deepPurple, 
      isExpense: true,
      keywords: ['quần áo', 'áo', 'quần', 'giày', 'dép']
    ),
    Category(
      id: 'car', 
      name: 'Ô tô', 
      icon: Icons.directions_car, 
      color: Colors.blueAccent, 
      isExpense: true,
      keywords: ['ô tô', 'xe', 'xăng', 'sửa xe', 'rửa xe']
    ),
    Category(
      id: 'health', 
      name: 'Sức khỏe', 
      icon: Icons.medical_services, 
      color: Colors.redAccent, 
      isExpense: true,
      keywords: ['sức khỏe', 'bệnh', 'thuốc', 'bác sĩ', 'bệnh viện', 'y tế']
    ),
    Category(
      id: 'housing', 
      name: 'Nhà ở', 
      icon: Icons.home, 
      color: Colors.grey[600]!, 
      isExpense: true,
      keywords: ['nhà ở', 'nhà', 'tiền nhà', 'phòng', 'thuê']
    ),
  ];

  // 2. Danh sách các hạng mục Thu nhập
  static List<Category> incomeCategories = [
    Category(
      id: 'salary', 
      name: 'Lương', 
      icon: Icons.account_balance_wallet,
      color: Colors.amber[700]!,
      isExpense: false,
      keywords: ['lương', 'salary', 'tiền lương', 'tính lương']
    ),
    Category(
      id: 'invest', 
      name: 'Khoản đầu tư', 
      icon: Icons.savings,
      color: Colors.pinkAccent,
      isExpense: false,
      keywords: ['đầu tư', 'invest', 'cổ phiếu', 'chứng chỉ']
    ),
    Category(
      id: 'overtime', 
      name: 'Làm thêm', 
      icon: Icons.access_time,
      color: Colors.blue,
      isExpense: false,
      keywords: ['làm thêm', 'overtime', 'phụ cấp', 'thêm giờ']
    ),
    Category(
      id: 'bonus', 
      name: 'Tiền thưởng', 
      icon: Icons.card_giftcard,
      color: Colors.teal,
      isExpense: false,
      keywords: ['thưởng', 'bonus', 'tết', 'tá lộ']
    ),
    Category(
      id: 'allowance', 
      name: 'Trợ cấp', 
      icon: Icons.volunteer_activism,
      color: Colors.green,
      isExpense: false,
      keywords: ['trợ cấp', 'allowance', 'hỗ trợ', 'cấp dưỡng']
    ),
    Category(
      id: 'other', 
      name: 'Khác', 
      icon: Icons.apps,
      color: Colors.grey,
      isExpense: false,
      keywords: ['khác', 'other']
    ),
  ];

  // 3. Hàm tìm Category theo ID (Dùng để hiển thị lịch sử)
  static Category getCategoryById(String id) {
    // Tìm trong cả 2 list
    final all = [...expenseCategories, ...incomeCategories];
    return all.firstWhere(
      (cat) => cat.id == id,
      // Nếu không tìm thấy (lỗi) thì trả về icon mặc định
      orElse: () => Category(id: 'other', name: 'Khác', icon: Icons.help_outline, color: Colors.grey, isExpense: true),
    );
  }

  // 4. Hàm lấy tất cả categories (để hiển thị danh sách)
  static List<Category> getAllCategories() {
    return [...expenseCategories, ...incomeCategories];
  }

  // 5. Hàm tìm kiếm categories theo từ khóa
  static List<Category> searchCategoriesByKeyword(String keyword, bool isExpense) {
    final lowerKeyword = keyword.toLowerCase();
    final categories = isExpense ? expenseCategories : incomeCategories;
    
    return categories.where((cat) {
      // Tìm trong tên danh mục
      if (cat.name.toLowerCase().contains(lowerKeyword)) return true;
      
      // Tìm trong từ khóa
      return cat.keywords.any((kw) => kw.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  // 6. Hàm tìm kiếm categories trong cả 2 loại theo từ khóa
  static List<Category> searchAllCategoriesByKeyword(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    final all = getAllCategories();
    
    return all.where((cat) {
      // Tìm trong tên danh mục
      if (cat.name.toLowerCase().contains(lowerKeyword)) return true;
      
      // Tìm trong từ khóa
      return cat.keywords.any((kw) => kw.toLowerCase().contains(lowerKeyword));
    }).toList();
  }
}
