import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expense_item.dart';

class ExpenseData extends ChangeNotifier {
  late final Box<ExpenseItem> _expenseBox;
  DateTime _lastRecordedMonth = DateTime.now();

  Future<void> init() async {
    _expenseBox = await Hive.openBox<ExpenseItem>('expenseBox');
    _checkMonthReset();
  }

  
  Future<void> prepareData() async {
    _checkMonthReset();
    notifyListeners(); 
  }

  List<ExpenseItem> get overallExpenseList => _expenseBox.values.toList();

  List<ExpenseItem> getAllExpenseList() {
    _checkMonthReset();
    final expenses = overallExpenseList;
    return expenses;
  }


  Future<void> addExpense(ExpenseItem expense) async {
    try {

      await _expenseBox.add(expense);    
      _checkMonthReset();
      notifyListeners();
      
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense(ExpenseItem expense) async {
    try {
      final keyToDelete = _expenseBox.keys.firstWhere(
        (key) => _expenseBox.get(key) == expense,
        orElse: () => null,
      );

      if (keyToDelete != null) {
        await _expenseBox.delete(keyToDelete);
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao deletar expense: $e');
    }
  }

  String getDayName(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    int dayIndex;
    if (date.weekday == 7) {
      dayIndex = 0;
    } else {
      dayIndex = date.weekday; 
    }
    return days[dayIndex];
  }

  DateTime startOfWeekDate() {
    final today = DateTime.now();
    final daysFromSunday = today.weekday % 7;
    return today.subtract(Duration(days: daysFromSunday));
  }

  List<ExpenseItem> getExpensesForCurrentWeek() {
    final start = startOfWeekDate();
    final end = start.add(const Duration(days: 6));

    return overallExpenseList.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
             expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<ExpenseItem> getExpensesForWeekday(String weekday) {
    return getExpensesForCurrentWeek().where((expense) {
      return getDayName(expense.date) == weekday;
    }).toList();
  }

  void _checkMonthReset() {
    final now = DateTime.now();
    if (_lastRecordedMonth.month != now.month ||
         _lastRecordedMonth.year != now.year) {
      print('Detectada mudança de mês - limpando despesas antigas');
      _resetExpenseBox();
      _lastRecordedMonth = now;
    }
  }

  Future<void> _resetExpenseBox() async {
    await _expenseBox.clear();
    notifyListeners();
    print('ExpenseBox resetado para novo mês');
  }

  Future<void> close() async {
    await _expenseBox.close();
  }


  int getExpenseCount() {
    return _expenseBox.length;
  }


  void refreshData() {
    notifyListeners();
    print('refreshData chamado manualmente');
  }
 
}