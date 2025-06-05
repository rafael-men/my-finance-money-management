import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './pages/homepage.dart';
import './models/expense_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {

    await Hive.initFlutter();
    await Hive.openBox<ExpenseItem>('expensebox');
    
    runApp(MyApp());
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
      home: Homepage(),
    );
  }
}