import 'package:flutter/material.dart';
import 'package:my_finance/pages/homepage.dart';
import 'package:my_finance/pages/trips_page.dart';



class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.purple),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
           ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Gastos'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Homepage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Investimentos'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/investments');
            },
          ),
           ListTile(
            leading: const Icon(Icons.airplane_ticket_outlined),
            title: const Text('Viagens'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TripsPage()),
              );
            }
           )
        ],
      ),
    );
  }
}
