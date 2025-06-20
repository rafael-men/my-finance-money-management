import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/pages/create_trip_page.dart';
import 'package:my_finance/pages/trip_detail_page.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/widgets/sidebar.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final TravelData travelData = TravelData();


  Future<void> _deleteTripWithConfirmation(BuildContext context, int tripKey, String tripDestination) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta viagem e todos os seus gastos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), 
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), 
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm) {
      await travelData.deleteTrip(tripKey);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Viagem "$tripDestination" excluída')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: const Sidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTrip(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: travelData.tripBox.listenable(),
          builder: (context, Box<TripItem> box, _) {
            if (box.isEmpty) {
              return const Center(
                child: Text('Nenhuma viagem cadastrada ainda'),
              );
            }
            
            final trips = box.values.toList()..sort((a, b) => b.startDate.compareTo(a.startDate));

            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                final key = trip.key as int;
                final totalExpenses = travelData.getTotalExpensesForTrip(key.toString());

                return Card( // O Card não precisa mais do Dismissible se você só quer um botão
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.deepPurple[50],
                  child: ListTile(
                    title: Text(
                      trip.destination,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}'),
                        Text(
                          'Total gasto: ${trip.currency} ${totalExpenses.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTripWithConfirmation(context, key, trip.destination),
                        ),
                        const Icon(Icons.chevron_right), 
                      ],
                    ),
                    onTap: () => _navigateToTripDetail(context, trip, key.toString()),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToCreateTrip(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripPage()),
    );
  }

  void _navigateToTripDetail(BuildContext context, TripItem trip, String tripId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailPage(trip: trip, tripId: tripId),
      ),
    );
  }
}