import '../../core/services/database_service.dart';
import '../models/transaction.dart';

class TransactionRepository {
  // Lấy instance của DatabaseService
  final DatabaseService _databaseService = DatabaseService();

  // 1. Hàm thêm giao dịch mới
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await _databaseService.database;
    // 'transactions' là tên bảng mình đã tạo ở Bước 2
    return await db.insert('transactions', transaction.toMap());
  }

  // 2. Hàm lấy tất cả giao dịch (Mới nhất lên đầu)
  Future<List<Transaction>> getAllTransactions() async {
    final db = await _databaseService.database;
    
    // Query lấy dữ liệu và sắp xếp theo ngày giảm dần (DESC)
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: "date DESC", 
    );

    // Chuyển đổi từ List<Map> sang List<Transaction>
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  // 3. Hàm xóa giao dịch
  Future<int> deleteTransaction(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'transactions',
      where: 'id = ?', // Xóa tại dòng có id bằng...
      whereArgs: [id], // ... giá trị này
    );
  }

  // 4. Hàm cập nhật giao dịch (Ví dụ sửa số tiền)
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await _databaseService.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // 5. Hàm lấy giao dịch theo tháng năm
  Future<List<Transaction>> getTransactionsByMonth(int month, int year) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: "date DESC",
    );
    
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]))
        .where((t) => t.date.month == month && t.date.year == year)
        .toList();
  }

  // 6. Hàm lấy giao dịch theo danh mục
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [categoryId],
      orderBy: "date DESC",
    );
    
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // 7. Hàm lấy tổng chi/thu theo danh mục
  Future<double> getTotalByCategory(String categoryId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [categoryId],
    );
    
    double total = 0;
    for (var map in maps) {
      total += map['amount'] as double;
    }
    return total;
  }

  // 8. Hàm lấy giao dịch trong khoảng ngày
  Future<List<Transaction>> getTransactionsByDateRange(DateTime from, DateTime to) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: "date DESC",
    );
    
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // 9. Hàm xóa tất cả giao dịch
  Future<int> deleteAllTransactions() async {
    final db = await _databaseService.database;
    return await db.delete('transactions');
  }
}