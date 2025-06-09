import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/expense_data.dart';
import '../models/expense_item.dart';
import '../widgets/sidebar.dart'; 
import '../pages/create_expense_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  ExpenseData? expenseData;
  final TextEditingController _limitController = TextEditingController();
  double spendingLimit = 0.0;
  bool isLoading = true;
  late Box settingsBox;

  @override
  void initState() {
    super.initState();
    _initializeExpenseData();
  }

  Future<void> _initializeExpenseData() async {
    try {
      expenseData = ExpenseData();
      await expenseData!.init();
      await expenseData!.prepareData();
      
     
      settingsBox = await Hive.openBox('settings');
      
     
      spendingLimit = settingsBox.get('spendingLimit', defaultValue: 0.0);
      _limitController.text = spendingLimit > 0 ? spendingLimit.toString() : '';
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao inicializar ExpenseData: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    if (expenseData != null) {
      setState(() {
        isLoading = true;
      });
      
      await expenseData!.prepareData();
      expenseData!.refreshData();
      
      setState(() {
        isLoading = false;
      });
    }
  }

  
  Future<void> _saveSpendingLimit(double limit) async {
    await settingsBox.put('spendingLimit', limit);
  }

  @override
  void dispose() {
    _limitController.dispose();
    expenseData?.close();
    settingsBox.close();
    super.dispose();
  }

  
  Map<String, double> getMonthlyExpenses() {
    if (expenseData == null) return {};
    
    final now = DateTime.now();
    final Map<String, double> monthlyTotals = {};
    
    
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey = '${_shortMonthName(monthDate.month)}/${monthDate.year.toString().substring(2)}';
      monthlyTotals[monthKey] = 0.0;
    }
    
   
    for (var expense in expenseData!.getAllExpenseList()) {
      final monthKey = '${_shortMonthName(expense.date.month)}/${expense.date.year.toString().substring(2)}';
      
      if (monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + 
                                 (double.tryParse(expense.amount) ?? 0);
      }
    }
    
    return monthlyTotals;
  }

  double getTotalSpentCurrentMonth() {
    if (expenseData == null) return 0.0;
    
    final now = DateTime.now();
    final expensesThisMonth = expenseData!.getAllExpenseList().where((expense) {
      return expense.date.month == now.month && expense.date.year == now.year;
    });

    return expensesThisMonth.fold<double>(
        0, (total, e) => total + (double.tryParse(e.amount) ?? 0));
  }

  String _fullMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  String _shortMonthName(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }

  String _getDayNameInPortuguese(DateTime date) {
    const dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
    return dayNames[date.weekday % 7];
  }

  List<BarChartGroupData> _buildMonthlyBarGroups() {
    final monthlyData = getMonthlyExpenses();
    if (monthlyData.isEmpty) return [];
    
    
    final maxDataValue = monthlyData.values.isEmpty
        ? 100.0
        : monthlyData.values.reduce((a, b) => a > b ? a : b);
    
    
    final maxY = (maxDataValue * 1.2).clamp(100.0, double.infinity);

    int index = 0;
    return monthlyData.entries.map((entry) {
      final amount = entry.value;

      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: Colors.deepPurple,
            width: 25,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY, // Usar o maxY calculado
              color: Colors.grey[300]!,
            ),
          ),
        ],
      );
    }).toList();
  }

 
  double _calculateMaxY() {
    final monthlyData = getMonthlyExpenses();
    if (monthlyData.isEmpty) return 100.0;
    
    final maxValue = monthlyData.values.reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).clamp(100.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minhas Finanças'),
          backgroundColor: Colors.purple,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (expenseData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minhas Finanças'),
          backgroundColor: Colors.purple,
        ),
        body: const Center(
          child: Text('Erro ao carregar dados'),
        ),
      );
    }

    final allExpenses = expenseData!.getAllExpenseList();
    final now = DateTime.now();
    final monthName = _fullMonthName(now.month);
    final year = now.year;
    final totalSpent = getTotalSpentCurrentMonth();
    final barGroups = _buildMonthlyBarGroups();
    final monthlyData = getMonthlyExpenses();
    final maxY = _calculateMaxY(); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Finanças'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar dados',
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Criar Compra',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateExpensePage(expenseData: expenseData!),
                ),
              );
              
              if (result == true) {
                await _refreshData();
              } else {
                await _refreshData();
              }
            },
          ),
        ],
      ),
      drawer: const Sidebar(), 
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text(
                'Olá, seja bem-vindo!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 8),
              Text('Mês atual: $monthName', style: const TextStyle(fontSize: 16)),
              Text('Ano: $year', style: const TextStyle(fontSize: 16)),
              
              const SizedBox(height: 16),
              Text(
                'Total gasto no mês: R\$ ${totalSpent.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _limitController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Defina o limite de gastos',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      onChanged: (value) {
                        final newLimit = double.tryParse(value) ?? 0.0;
                        setState(() {
                          spendingLimit = newLimit;
                        });
                        _saveSpendingLimit(newLimit); 
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Limite: R\$ ${spendingLimit.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              if (spendingLimit > 0 && totalSpent > spendingLimit)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    'Você ultrapassou o limite de gastos!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 16),
              const Text(
                'Gastos por mês (últimos 6 meses):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    minY: 0, // Garantir que o mínimo seja 0
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final monthlyEntries = monthlyData.entries.toList();
                            if (value.toInt() < monthlyEntries.length) {
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  monthlyEntries[value.toInt()].key,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          interval: (maxY / 5).clamp(20, double.infinity), // Melhor intervalo
                          getTitlesWidget: (value, meta) {
                            return Text(
                              'R\$${value.toInt()}',
                              style: const TextStyle(fontSize: 9),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false, // Remover linhas verticais
                      horizontalInterval: (maxY / 5).clamp(20, double.infinity),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                        left: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final monthlyEntries = monthlyData.entries.toList();
                          if (group.x < monthlyEntries.length) {
                            return BarTooltipItem(
                              '${monthlyEntries[group.x].key}\nR\$ ${rod.toY.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white, fontSize: 12),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 400),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'Todas as compras (${allExpenses.length} itens):',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              SizedBox(
                height: 300,
                child: allExpenses.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma compra encontrada.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allExpenses.length,
                        itemBuilder: (context, index) {
                          final item = allExpenses[index];
                          final formattedDate =
                              '${item.date.day.toString().padLeft(2, '0')}/'
                              '${item.date.month.toString().padLeft(2, '0')}/'
                              '${item.date.year}';
                          final dayName = _getDayNameInPortuguese(item.date);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('$formattedDate - $dayName'),
                              trailing: Text(
                                'R\$ ${item.amount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      )
    ));
  }
}