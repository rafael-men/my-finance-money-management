import 'package:hive/hive.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/models/travel_expense.dart';

class TravelData {

  static final TravelData _instance = TravelData._internal();


  factory TravelData() {
    return _instance;
  }


  TravelData._internal();

  late Box<TripItem> _tripBox;
  late Box<TravelExpense> _expenseBox;
  bool _initialized = false;


  Future<void> init() async {
    if (!_initialized) {
      _tripBox = await Hive.openBox<TripItem>('trips');
      _expenseBox = await Hive.openBox<TravelExpense>('travel_expenses');
      _initialized = true;
    }
  }


  Box<TripItem> get tripBox {
    if (!_initialized) throw Exception('TravelData não inicializado. Chame init() primeiro.');
    return _tripBox;
  }

  Box<TravelExpense> get expenseBox {
    if (!_initialized) throw Exception('TravelData não inicializado. Chame init() primeiro.');
    return _expenseBox;
  }


  Future<void> deleteTrip(int tripKey) async {
    final Map<dynamic, TravelExpense> expensesMap = _expenseBox.toMap();
    final List<dynamic> keysToDelete = [];

    expensesMap.forEach((key, expense) {
      if (expense.tripId == tripKey.toString()) {
        keysToDelete.add(key);
      }
    });

    if (keysToDelete.isNotEmpty) {
      await _expenseBox.deleteAll(keysToDelete);
    }
    
    await _tripBox.delete(tripKey);
  }
  
  Future<void> addTrip(TripItem trip) async => await tripBox.add(trip);
  List<TripItem> getAllTrips() => tripBox.values.toList();
  Future<void> addExpense(TravelExpense expense) async => await expenseBox.add(expense);
  List<TravelExpense> getExpensesForTrip(String tripId) =>
      expenseBox.values.where((e) => e.tripId == tripId).toList();
  double getTotalExpensesForTrip(String tripId) {
    return expenseBox.values
        .where((e) => e.tripId == tripId)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
}