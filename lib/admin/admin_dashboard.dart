import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        OrdersAndRevenueSection(),
        PendingAppointmentsSection(),
        CustomersSection(),
      ],
    );
  }
}

/* ===================== ORDERS + MONTHLY REVENUE ===================== */

class OrdersAndRevenueSection extends StatelessWidget {
  const OrdersAndRevenueSection({super.key});

  @override
  Widget build(BuildContext context) {
    final startOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading orders');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        double totalRevenue = 0.0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalRevenue += (data['total'] as num?)?.toDouble() ?? 0.0;
        }

        return Column(
          children: [
            StatCard(
              title: 'Total Orders (This Month)',
              value: docs.length.toString(),
              trend: 'Real-time data',
              icon: Icons.shopping_cart,
              iconColor: Colors.blue,
            ),
            StatCard(
              title: 'Monthly Revenue',
              value: 'RM ${totalRevenue.toStringAsFixed(2)}',
              trend: 'Current month',
              icon: Icons.attach_money,
              iconColor: Colors.green,
            ),
          ],
        );
      },
    );
  }
}

/* ===================== PENDING APPOINTMENTS ===================== */

class PendingAppointmentsSection extends StatelessWidget {
  const PendingAppointmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading appointments');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StatCard(
          title: 'Pending Appointments',
          value: snapshot.data!.docs.length.toString(),
          trend: 'Action required',
          icon: Icons.access_time_filled,
          iconColor: Colors.orange,
        );
      },
    );
  }
}

/* ===================== CUSTOMERS ===================== */

class CustomersSection extends StatelessWidget {
  const CustomersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading customers');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StatCard(
          title: 'Active Customers',
          value: snapshot.data!.docs.length.toString(),
          trend: 'Registered users',
          icon: Icons.group,
          iconColor: Colors.purple,
        );
      },
    );
  }
}

/* ===================== STAT CARD ===================== */

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                trend,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: iconColor, size: 30),
          ),
        ],
      ),
    );
  }
}
