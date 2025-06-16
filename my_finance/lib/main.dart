import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_finance/models/investiment_item.dart';
import 'package:my_finance/pages/investiments.dart'; // Corrigi o nome do arquivo para 'investments_page.dart'
import './pages/homepage.dart';
import './models/expense_item.dart';
 // Corrigi o nome do arquivo para 'investment_item.dart'

// Variáveis globais para os boxes (solução simples e eficaz)
late Box<ExpenseItem> expenseBox;
late Box<InvestmentItem> investmentBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseItemAdapter());
    Hive.registerAdapter(InvestmentItemAdapter());
    
    // Inicializa os boxes e armazena nas variáveis globais
    expenseBox = await Hive.openBox<ExpenseItem>('expensebox');
    investmentBox = await Hive.openBox<InvestmentItem>('investmentbox');
    
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
        '/investments': (context) => const InvestmentsPage(), // Removi o parâmetro investmentBox
      },
    );
  }
}