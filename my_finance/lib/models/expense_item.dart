import 'package:hive/hive.dart';


@HiveType(typeId: 0)
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
}
