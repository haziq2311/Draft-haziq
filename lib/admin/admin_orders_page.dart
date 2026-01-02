import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order['items'] as List<dynamic>;
              final total = order['total'];
              final timestamp = order['timestamp']?.toDate() ?? DateTime.now();
              final customerId = order['userId'] ?? 'Unknown';
              final status = order['status'] ?? 'Pending';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: FutureBuilder<List<String>>(
                    future: Future.wait(
                      items.map((item) {
                        return FirebaseFirestore.instance
                            .collection('products')
                            .doc(item['productId'])
                            .get()
                            .then((doc) {
                          return (doc.data()?['name'] ?? item['productId'])
                              as String;
                        }).catchError((e) {
                          return item['productId'] as String;
                        });
                      }).toList(),
                    ),
                    builder: (context, snapshot) {
                      final productNames = snapshot.hasData
                          ? snapshot.data!.join(', ')
                          : 'Loading...';

                      return RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          children: [
                            TextSpan(text: "$productNames - RM "),
                            TextSpan(text: total.toString()),
                          ],
                        ),
                      );
                    },
                  ),
                  subtitle: Text(
                      "Customer: $customerId\nStatus: $status\nDate: ${timestamp.toString().split('.')[0]}"),
                  children: items.map((item) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('products')
                          .doc(item['productId'])
                          .get(),
                      builder: (context, productSnapshot) {
                        final productName = productSnapshot.hasData &&
                                productSnapshot.data!.data() != null
                            ? productSnapshot.data!['name'] ?? item['productId']
                            : item['productId'];

                        return ListTile(
                          title: Text(productName),
                          subtitle: Text(
                              "Color: ${item['selectedColor']} x${item['quantity']}"),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
