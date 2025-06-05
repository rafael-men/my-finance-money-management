import 'package:flutter/material.dart';


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
            leading: const Icon(Icons.trending_up),
            title: const Text('Investimentos'),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Cartão Inter'),
          ),
        ],
      ),
    );
  }
}
