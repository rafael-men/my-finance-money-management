import 'package:hive/hive.dart';

part 'investiment_item.g.dart'; 

@HiveType(typeId: 33) 
class InvestmentItem extends HiveObject {
  @HiveField(0)
  String name; 

  @HiveField(1)
  String amount; 

  @HiveField(2)
  DateTime date; 

  @HiveField(3)
  String type; 

  @HiveField(4, defaultValue: 'BRL')
  String currency; 

  @HiveField(5, defaultValue: '')
  String broker; 

  InvestmentItem({
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    this.currency = 'BRL',
    this.broker = '',
  });

  @override
  String toString() {
    return 'InvestmentItem(name: $name, amount: $amount, date: $date, type: $type, currency: $currency, broker: $broker)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestmentItem &&
        other.name == name &&
        other.amount == amount &&
        other.date == date &&
        other.type == type &&
        other.currency == currency &&
        other.broker == broker;
  }

  @override
  int get hashCode {
    return name.hashCode ^ 
           amount.hashCode ^ 
           date.hashCode ^ 
           type.hashCode ^ 
           currency.hashCode ^ 
           broker.hashCode;
  }
}