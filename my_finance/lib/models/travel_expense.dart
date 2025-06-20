import 'package:hive/hive.dart';

part 'travel_expense.g.dart';

@HiveType(typeId: 35)
class TravelExpense extends HiveObject{
  @HiveField(0)
  final String tripId; 

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  TravelExpense({
    required this.tripId,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}