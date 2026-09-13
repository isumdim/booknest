import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/order_status.dart';
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
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Order #${order.id.substring(0, 6)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        Text('Rs. ${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${order.items.length} item(s)', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    const SizedBox(height: 12),
                    _StatusTracker(status: order.status),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusTracker extends StatelessWidget {
  final String status;
  const _StatusTracker({required this.status});

  @override
  Widget build(BuildContext context) {
    final currentIndex = orderStatusStages.indexOf(status);

    return Row(
      children: List.generate(orderStatusStages.length, (i) {
        final stage = orderStatusStages[i];
        final isReached = i <= currentIndex;
        final isLast = i == orderStatusStages.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    orderStatusIcon(stage),
                    size: 18,
                    color: isReached ? orderStatusColor(stage == 'delivered' ? stage : status) : AppColors.line,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i < currentIndex ? AppColors.plum : AppColors.line,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                orderStatusLabel(stage),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isReached ? FontWeight.w700 : FontWeight.w400,
                  color: isReached ? AppColors.black : AppColors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}