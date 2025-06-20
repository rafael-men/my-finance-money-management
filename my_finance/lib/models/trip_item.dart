import 'package:hive/hive.dart';

part 'trip_item.g.dart';

@HiveType(typeId: 34)
class TripItem extends HiveObject {
  @HiveField(0)
  final String destination;

  @HiveField(1)
  final String currency;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
  final String? notes;

  TripItem({
    required this.destination,
    required this.currency,
    required this.startDate,
    required this.endDate,
    this.notes,
  });
}