import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin_dashboard.dart';
import 'admin_orders_page.dart';
import 'admin_product_catalogue_page.dart';
import 'customers_page.dart';
import 'appointments_page.dart';
import 'bottom_nav.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      DashboardPage(),
      AdminOrdersPage(),
      AdminProductCataloguePage(),
      CustomersPage(),
      AppointmentsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFFF9800);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: themeColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Orders';
      case 2:
        return 'Products';
      case 3:
        return 'Customers';
      case 4:
        return 'Appointments';
      default:
        return 'Admin';
    }
  }
}
