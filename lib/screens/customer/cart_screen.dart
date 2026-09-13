import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/cart_item.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please log in.'));

    return StreamBuilder<List<CartItem>>(
      stream: firestoreService.cartStream(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.plum));
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(child: Text('Your cart is empty.', style: TextStyle(color: AppColors.grey)));
        }

        final total = items.fold<double>(0, (sum, i) => sum + i.subtotal);

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Rs. ${item.price.toStringAsFixed(2)} each'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.plum),
                            onPressed: () =>
                                firestoreService.updateCartQuantity(uid, item.bookId, item.quantity - 1),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.plum),
                            onPressed: () =>
                                firestoreService.updateCartQuantity(uid, item.bookId, item.quantity + 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.lightPurple),
                            onPressed: () => firestoreService.removeFromCart(uid, item.bookId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total: Rs. ${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(uid: uid, items: items),
                        ),
                      );
                    },
                    child: const Text('PROCEED TO CHECKOUT'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}