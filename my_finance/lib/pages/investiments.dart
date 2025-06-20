import 'package:flutter/material.dart';
import 'package:my_finance/data/investiment_data.dart';
import 'package:my_finance/models/investiment_item.dart';
import 'package:my_finance/pages/create_investiment_page.dart';
import 'package:my_finance/widgets/sidebar.dart';
import '../main.dart';


class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({super.key});

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  late InvestmentData investmentData;
  int? selectedWeekday;
  String? selectedType;
  String? selectedBroker;

  @override
  void initState() {
    super.initState();
    investmentData = InvestmentData(investmentBox);
  }


  Future<void> _showDeleteConfirmationDialog(InvestmentItem investment) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você tem certeza de que deseja excluir o investimento "${investment.name}"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                investmentData.deleteInvestment(investment.key);
                Navigator.of(context).pop();
                setState(() {}); 
              },
            ),
          ],
        );
      },
    );
  }


  Map<int, double> _getWeeklyInvestments() {
  final now = DateTime.now();
  final firstDayOfMonth = DateTime(now.year, now.month, 1);
  final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);


  final weeklyTotals = <int, double>{};


  final investments = investmentData.getAllInvestments().where((investment) {
    return investment.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
           investment.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
  }).toList();


  for (final investment in investments) {
    final weekNumber = ((investment.date.day - 1) ~/ 7) + 1;
    final amount = double.tryParse(investment.amount) ?? 0;

    weeklyTotals.update(
      weekNumber,
      (total) => total + amount,
      ifAbsent: () => amount,
    );
  }


  for (int week = 1; week <= 5; week++) {
    weeklyTotals.putIfAbsent(week, () => 0);
  }

  return weeklyTotals;
}

  List<InvestmentItem> getFilteredInvestments() {
    var investments = investmentData.getAllInvestments();

    if (selectedWeekday != null) {
      investments = investments.where((i) => i.date.weekday == selectedWeekday).toList();
    }

    if (selectedType != null) {
      investments = investments.where((i) => i.type == selectedType).toList();
    }

    if (selectedBroker != null) {
      investments = investments.where((i) => i.broker == selectedBroker).toList();
    }

    return investments;
  }

  @override
  Widget build(BuildContext context) {
    final filteredInvestments = getFilteredInvestments();
    final totalInvested = investmentData.getTotalInvestedCurrentMonth();
    final byType = investmentData.getTotalInvestedByType();
    final byBroker = investmentData.getTotalInvestedByBroker();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Investimentos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateInvestmentPage(),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Investido este Mês',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'R\$ ${totalInvested.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFiltersSection(byType.keys.toList(), byBroker.keys.toList()),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredInvestments.length,
                itemBuilder: (context, index) {
                  final investment = filteredInvestments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(investment.name),
                      subtitle: Text(
                        '${investment.type} • ${investment.broker}\n'
                        '${investment.date.day}/${investment.date.month}/${investment.date.year}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'R\$ ${investment.amount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              _showDeleteConfirmationDialog(investment);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFiltersSection(List<String> types, List<String> brokers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filtrar Investimentos:', style: TextStyle(fontWeight: FontWeight.bold)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todos dias'),
                selected: selectedWeekday == null,
                onSelected: (selected) => setState(() => selectedWeekday = null),
              ),
              ...List.generate(7, (index) {
                final weekday = index + 1;
                // Corrigindo a ordem para começar com Domingo (Dom)
                final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
                final displayDay = days[weekday -1];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(displayDay),
                    selected: selectedWeekday == weekday,
                    onSelected: (selected) => setState(() => selectedWeekday = selected ? weekday : null),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}