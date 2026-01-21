import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper cho SharedPreferences để quản lý dữ liệu cục bộ
class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  static SharedPreferences? _preferences;

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  // Khởi tạo SharedPreferences
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Lưu String
  Future<bool> setString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  // Lấy String
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  // Lưu Integer
  Future<bool> setInt(String key, int value) async {
    return await _preferences?.setInt(key, value) ?? false;
  }

  // Lấy Integer
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  // Lưu Double
  Future<bool> setDouble(String key, double value) async {
    return await _preferences?.setDouble(key, value) ?? false;
  }

  // Lấy Double
  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  // Lưu Boolean
  Future<bool> setBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  // Lấy Boolean
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  // Xóa một key
  Future<bool> remove(String key) async {
    return await _preferences?.remove(key) ?? false;
  }

  // Xóa tất cả
  Future<bool> clear() async {
    return await _preferences?.clear() ?? false;
  }

  // Kiểm tra tồn tại
  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  // Lấy tất cả keys
  List<String> getAllKeys() {
    return _preferences?.getKeys().toList() ?? [];
  }
}
