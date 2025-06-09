import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expense_item.dart';

class ExpenseData extends ChangeNotifier {
  late final Box<ExpenseItem> _expenseBox;

  Future<void> init() async {
    _expenseBox = await Hive.openBox<ExpenseItem>('expenseBox');
  }

  Future<void> prepareData() async {
    notifyListeners(); 
  }

  List<ExpenseItem> get overallExpenseList => _expenseBox.values.toList();

  List<ExpenseItem> getAllExpenseList() {
    return overallExpenseList;
  }

  Future<void> addExpense(ExpenseItem expense) async {
    try {
      await _expenseBox.add(expense);    
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
