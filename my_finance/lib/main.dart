import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/models/investiment_item.dart';
import 'package:my_finance/pages/investiments.dart';
import 'package:my_finance/pages/trips_page.dart'; 
import './pages/homepage.dart';
import './models/expense_item.dart';
import './models/trip_item.dart';
import './models/travel_expense.dart';

late Box<ExpenseItem> expenseBox;
late Box<InvestmentItem> investmentBox;
late Box<TripItem> tripBox;
late Box<TravelExpense> travelBox;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseItemAdapter());
    Hive.registerAdapter(InvestmentItemAdapter());
    Hive.registerAdapter(TripItemAdapter()); 
    Hive.registerAdapter(TravelExpenseAdapter()); 
    

    expenseBox = await Hive.openBox<ExpenseItem>('expensebox');
    investmentBox = await Hive.openBox<InvestmentItem>('investmentbox');
    tripBox = await Hive.openBox<TripItem>('trips'); 
    travelBox = await Hive.openBox<TravelExpense>('travel_expenses'); 
    await TravelData().init();
    
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Erro na inicialização: $e')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
      routes: {
        '/investments': (context) => const InvestmentsPage(), 
        '/trips': (context) => const TripsPage(),
      },
    );
  }
}