import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  // Singleton pattern: Đảm bảo chỉ có 1 instance duy nhất
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // Getter để lấy database. Nếu chưa có thì khởi tạo, có rồi thì dùng luôn.
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Kiểm tra platform - web không hỗ trợ sqflite
    if (kIsWeb) {
      // Trên web, cần sử dụng sqflite_common_ffi hoặc các giải pháp khác
      // Tạm thời để trống
      throw Exception('SQLite không hỗ trợ trên web');
    }
    
    _database = await _initDatabase();
    return _database!;
  }

  // Hàm khởi tạo database
  Future<Database> _initDatabase() async {
    // Lấy đường dẫn thư mục lưu trữ của app trên điện thoại
    String path = join(await getDatabasesPath(), 'money_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate, // Gọi hàm này khi chạy lần đầu tiên để tạo bảng
    );
  }

  // Hàm tạo bảng (Chỉ chạy 1 lần duy nhất khi mới cài app)
  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng Transactions khớp với Model ở Bước 1
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        note TEXT,
        date TEXT,
        is_expense INTEGER,
        category TEXT
      )
    ''');
    
    // Sau này muốn tạo thêm bảng Category hay Budget thì viết thêm lệnh execute ở dưới
  }
}