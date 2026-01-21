import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    // dd/MM/yyyy -> Ngày/Tháng/Năm
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
  
  // Sau này sẽ thêm hàm lấy ngày đầu tháng, cuối tháng ở đây...
}