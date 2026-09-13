import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/order_model.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please log in.'));

    return StreamBuilder<List<OrderModel>>(
      stream: firestoreService.myOrdersStream(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.plum));
        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return const Center(child: Text('You have no orders yet.', style: TextStyle(color: AppColors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('Order #${order.id.substring(0, 6)}'),
                subtitle: Text(
                  '${order.items.length} item(s) • Rs. ${order.total.toStringAsFixed(2)}\nStatus: ${order.status}',
                ),
                isThreeLine: true,
                trailing: Icon(
                  order.status == 'fulfilled' ? Icons.check_circle : Icons.hourglass_empty,
                  color: order.status == 'fulfilled' ? Colors.green : AppColors.lightPurple,
                ),
              ),
            );
          },
        );
      },
    );
  }
}