import 'package:hive/hive.dart';

part 'expense_item.g.dart'; 

@HiveType(typeId: 32)
class ExpenseItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String amount;

  @HiveField(2)
  DateTime date;

  ExpenseItem({
    required this.name,
    required this.amount,
    required this.date,
  });

  @override
  String toString() {
    return 'ExpenseItem(name: $name, amount: $amount, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseItem &&
        other.name == name &&
        other.amount == amount &&
        other.date == date;
  }

  @override
  int get hashCode {
    return name.hashCode ^ amount.hashCode ^ date.hashCode;
  }
}