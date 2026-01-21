import 'package:intl/intl.dart';

class CurrencyHelper {
  // Hàm static để gọi được luôn không cần new class
  static String format(double amount) {
    // locale: 'vi_VN' để dùng định dạng Việt Nam (dấu chấm phân cách ngàn)
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }
}