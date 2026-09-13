import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/order_status.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';

class StaffOrdersScreen extends StatelessWidget {
  const StaffOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<OrderModel>>(
      stream: firestoreService.allOrdersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.plum));
        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return const Center(child: Text('No orders yet.', style: TextStyle(color: AppColors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: Icon(orderStatusIcon(order.status), color: orderStatusColor(order.status)),
                title: Text('Order #${order.id.substring(0, 6)} • Rs. ${order.total.toStringAsFixed(2)}'),
                subtitle: Text('${order.items.length} item(s) • ${orderStatusLabel(order.status)}'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.black)),
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(icon: Icons.person_outline, value: order.deliveryName),
                  _DetailRow(icon: Icons.location_on_outlined, value: order.deliveryAddress),
                  _DetailRow(icon: Icons.phone_outlined, value: order.deliveryPhone),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Items', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.black)),
                  ),
                  const SizedBox(height: 8),
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(child: Text('${item.title} x${item.quantity}', style: const TextStyle(fontSize: 13))),
                          Text('Rs. ${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Update Status', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.black)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: orderStatusStages.contains(order.status) ? order.status : orderStatusStages.first,
                    decoration: const InputDecoration(isDense: true),
                    items: orderStatusStages
                        .map((s) => DropdownMenuItem(value: s, child: Text(orderStatusLabel(s))))
                        .toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        firestoreService.updateOrderStatus(order.id, newStatus);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _DetailRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.plum),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 13, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}