import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
  String selectedDay = '';
  final List<String> weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
  bool isLoading = true;

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

  @override
  void dispose() {
    _limitController.dispose();
    expenseData?.close();
    super.dispose();
  }

  List<ExpenseItem> getFilteredExpenses() {
    if (expenseData == null) return [];
    
    if (selectedDay.isEmpty) {
      return expenseData!.getAllExpenseList();
    }
    
    // Mapear os dias em português para inglês que o ExpenseData usa
    final dayMapping = {
      'Dom': 'Sun',
      'Seg': 'Mon', 
      'Ter': 'Tue',
      'Qua': 'Wed',
      'Qui': 'Thu',
      'Sex': 'Fri',
      'Sab': 'Sat'
    };
    
    final englishDay = dayMapping[selectedDay];
    if (englishDay == null) return expenseData!.getAllExpenseList();
    
    return expenseData!.getExpensesForWeekday(englishDay);
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

  List<BarChartGroupData> _buildWeeklyBarGroups() {
    if (expenseData == null) return [];
    
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Mapear gastos por semana do mês
    final Map<int, double> weeklyTotals = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0};
    
    for (var expense in expenseData!.getAllExpenseList()) {
      if (expense.date.month == now.month && expense.date.year == now.year) {
        final weekOfMonth = _getWeekOfMonth(expense.date, firstDayOfMonth);
        weeklyTotals[weekOfMonth] = (weeklyTotals[weekOfMonth] ?? 0) + 
                                   (double.tryParse(expense.amount) ?? 0);
      }
    }

    final maxYValue = (weeklyTotals.values.isEmpty
            ? 100.0
            : weeklyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2)
        .clamp(100.0, double.infinity);

    return weeklyTotals.entries.map((entry) {
      final week = entry.key;
      final amount = entry.value;

      return BarChartGroupData(
        x: week,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: Colors.deepPurple,
            width: 25,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxYValue,
              color: Colors.grey[300]!,
            ),
          ),
        ],
      );
    }).toList();
  }

  int _getWeekOfMonth(DateTime date, DateTime firstDayOfMonth) {
    final difference = date.difference(firstDayOfMonth).inDays;
    return (difference / 7).floor() + 1;
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

    final expenses = getFilteredExpenses();
    final now = DateTime.now();
    final monthName = _fullMonthName(now.month);
    final year = now.year;
    final totalSpent = getTotalSpentCurrentMonth();
    final barGroups = _buildWeeklyBarGroups();
    final maxY = barGroups.isEmpty
        ? 100.0
        : barGroups
                .map((g) => g.barRods[0].toY)
                .reduce((value, element) => value > element ? value : element) *
            1.2;

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
                        setState(() {
                          spendingLimit = double.tryParse(value) ?? 0.0;
                        });
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
                'Gastos por semana do mês:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '${value.toInt()}ª Sem',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          interval: (maxY / 5).clamp(50, double.infinity),
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
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${group.x}ª Semana\nR\$ ${rod.toY.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 400),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                selectedDay.isEmpty 
                    ? 'Filtrar por dia da semana:' 
                    : 'Filtrado por: $selectedDay',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekDays.length,
                  itemBuilder: (context, index) {
                    final day = weekDays[index];
                    final isSelected = day == selectedDay;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(day),
                        selected: isSelected,
                        selectedColor: Colors.deepPurple.shade300,
                        onSelected: (_) {
                          setState(() {
                            selectedDay = isSelected ? '' : day;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
              Text(
                selectedDay.isEmpty 
                    ? 'Todas as despesas:' 
                    : 'Despesas de $selectedDay:',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              SizedBox(
                height: 300,
                child: expenses.isEmpty
                    ? Center(
                        child: Text(
                          selectedDay.isEmpty 
                              ? 'Nenhuma despesa encontrada.' 
                              : 'Nenhuma despesa encontrada para $selectedDay.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final item = expenses[index];
                          final formattedDate =
                              '${item.date.day.toString().padLeft(2, '0')}/'
                              '${item.date.month.toString().padLeft(2, '0')}/'
                              '${item.date.year}';
                          final dayMapping = {
                            'Sun': 'Dom',
                            'Mon': 'Seg', 
                            'Tue': 'Ter',
                            'Wed': 'Qua',
                            'Thu': 'Qui',
                            'Fri': 'Sex',
                            'Sat': 'Sab'
                          };
                          final dayName = dayMapping[expenseData!.getDayName(item.date)] ?? 'N/A';

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