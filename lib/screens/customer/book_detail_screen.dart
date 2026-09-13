import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/book.dart';
import '../../models/cart_item.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.lavender,
      appBar: AppBar(title: const Text('')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 150,
                height: 210,
                decoration: BoxDecoration(color: AppColors.plum, borderRadius: BorderRadius.circular(10)),
                clipBehavior: Clip.antiAlias,
                child: book.imageUrl.isNotEmpty
                    ? Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.menu_book_rounded, size: 56, color: AppColors.lightPurple),
                )
                    : const Icon(Icons.menu_book_rounded, size: 56, color: AppColors.lightPurple),
              ),
            ),
            const SizedBox(height: 24),
            Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.black)),
            const SizedBox(height: 4),
            Text('by ${book.author}',
                style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: AppColors.grey)),
            const SizedBox(height: 14),
            Text('Rs. ${book.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.black)),
            const SizedBox(height: 18),
            Text(book.description, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.black)),
            const SizedBox(height: 10),
            Text(
              book.stock > 0 ? 'In stock: ${book.stock}' : 'Out of stock',
              style: TextStyle(color: book.stock > 0 ? Colors.green.shade700 : Colors.red),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('ADD TO CART'),
                onPressed: book.stock <= 0
                    ? null
                    : () async {
                  final uid = authService.currentUser?.uid;
                  if (uid == null) return;
                  await firestoreService.addToCart(
                    uid,
                    CartItem(bookId: book.id, title: book.title, price: book.price, quantity: 1),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}