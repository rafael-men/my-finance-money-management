import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/models/travel_expense.dart';
import 'package:my_finance/pages/add_travel_expense_page.dart';
import 'package:my_finance/data/travel_data.dart';

class TripDetailPage extends StatefulWidget {
  final TripItem trip;
  final String tripId;

  const TripDetailPage({
    super.key,
    required this.trip,
    required this.tripId,
  });

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late TravelData travelData;

  @override
  void initState() {
    super.initState();
    travelData = TravelData();
    travelData.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.destination),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.deepPurple[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total gasto na viagem:',
                      style: TextStyle(
                        color: Colors.deepPurple[800],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder(
                      valueListenable: Hive.box<TravelExpense>('travel_expenses').listenable(),
                      builder: (context, Box<TravelExpense> box, _) {
                        final total = travelData.getTotalExpensesForTrip(widget.tripId);
                        return Text(
                          '${widget.trip.currency} ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.deepPurple[900],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gastos da viagem:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<TravelExpense>('travel_expenses').listenable(),
                builder: (context, Box<TravelExpense> box, _) {
                  final expenses = travelData.getExpensesForTrip(widget.tripId);
                  
                  if (expenses.isEmpty) {
                    return const Center(
                      child: Text('Nenhum gasto registrado ainda'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(expense.description),
                          subtitle: Text('${expense.date.day}/${expense.date.month}/${expense.date.year}'),
                          trailing: Text(
                            '${widget.trip.currency} ${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTravelExpensePage(tripId: widget.tripId),
      ),
    );
    setState(() {});
  }
}