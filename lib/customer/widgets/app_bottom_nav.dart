import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Define the route names for each tab
    final tabRoutes = [
      '/products',           // index 0
      '/ai',                 // index 1
      '/appointments_menu',  // index 2
      '/orderhistory',       // index 3
    ];

    // When switching tabs, remove everything above Home
    Navigator.pushNamedAndRemoveUntil(
      context,
      tabRoutes[index],
      (route) => route.settings.name == '/home', // keep Home in stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome),
          label: 'AI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping),
          label: 'Orders',
        ),
      ],
    );
  }
}
