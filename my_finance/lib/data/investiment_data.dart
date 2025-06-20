import 'package:hive/hive.dart';
import '../models/investiment_item.dart';

class InvestmentData {
  late Box<InvestmentItem> _investmentBox;

  InvestmentData(this._investmentBox); 

  Future<void> addInvestment(InvestmentItem investment) async {
    await _investmentBox.add(investment);
  }


  List<InvestmentItem> getAllInvestments() {
    final investments = _investmentBox.values.toList();
    investments.sort((a, b) => b.date.compareTo(a.date));
    return investments;
  }

  List<InvestmentItem> getInvestmentsByType(String type) {
    return _investmentBox.values
        .where((investment) => investment.type == type)
        .toList();
  }


  List<InvestmentItem> getInvestmentsByBroker(String broker) {
    return _investmentBox.values
        .where((investment) => investment.broker == broker)
        .toList();
  }


  List<InvestmentItem> getInvestmentsByWeekday(int weekday) {
    return _investmentBox.values
        .where((investment) => investment.date.weekday == weekday)
        .toList();
  }


  List<InvestmentItem> getInvestmentsByMonth(int month, int year) {
    return _investmentBox.values
        .where((investment) =>
            investment.date.month == month && investment.date.year == year)
        .toList();
  }


  double getTotalInvestedBetween(DateTime start, DateTime end) {
    return _investmentBox.values
        .where((investment) =>
            investment.date.isAfter(start) && investment.date.isBefore(end))
        .fold(0.0, (sum, item) => sum + double.parse(item.amount));
  }

  double getTotalInvestedCurrentMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return getTotalInvestedBetween(firstDay, lastDay);
  }

  Map<String, double> getTotalInvestedByType() {
    final Map<String, double> totals = {};
    
    for (var investment in _investmentBox.values) {
      totals.update(
        investment.type,
        (value) => value + double.parse(investment.amount),
        ifAbsent: () => double.parse(investment.amount),
      );
    }
    
    return totals;
  }


  Map<String, double> getTotalInvestedByBroker() {
    final Map<String, double> totals = {};
    
    for (var investment in _investmentBox.values) {
      totals.update(
        investment.broker,
        (value) => value + double.parse(investment.amount),
        ifAbsent: () => double.parse(investment.amount),
      );
    }
    
    return totals;
  }


  Future<void> deleteInvestment(int key) async {
    await _investmentBox.delete(key);
  }

  Future<void> close() async {
    await _investmentBox.close();
  }

  void refreshData() {
    _investmentBox = Hive.box<InvestmentItem>('investments');
  }
}