class Budget {
  final String id;
  final int amount;
  final DateTime start;
  final DateTime end;

  Budget({required this.id, required this.amount, required this.start, required this.end});

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'] as String,
        amount: json['amount'] as int,
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
      );

  Map<String, dynamic> toJson() => {'id': id, 'amount': amount, 'start': start.toIso8601String(), 'end': end.toIso8601String()};
}
