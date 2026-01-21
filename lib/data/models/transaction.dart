class Transaction {
  int? id;              // ID tự tăng trong Database
  double amount;        // Số tiền
  String note;          // Ghi chú
  DateTime date;        // Ngày giờ
  bool isExpense;       // true = Chi, false = Thu
  
  // Sau này chúng ta sẽ liên kết với bảng Category, 
  // nhưng tạm thời để String để test cho dễ nhé.
  String category;      

  Transaction({
    this.id,
    required this.amount,
    required this.note,
    required this.date,
    required this.isExpense,
    required this.category,
  });

  // Chuyển từ Object sang Map (để lưu vào SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'is_expense': isExpense ? 1 : 0, // SQLite dùng 1 và 0 thay cho true/false
      'category': category,
    };
  }

  // Chuyển từ Map (từ SQLite) sang Object
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      isExpense: map['is_expense'] == 1,
      category: map['category'],
    );
  }

  // CopyWith method để update một số field
  Transaction copyWith({
    int? id,
    double? amount,
    String? note,
    DateTime? date,
    bool? isExpense,
    String? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      category: category ?? this.category,
    );
  }
}