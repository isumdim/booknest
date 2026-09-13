import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/book.dart';
import '../../services/firestore_service.dart';

class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      body: StreamBuilder<List<Book>>(
        stream: firestoreService.booksStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.plum));
          final books = snapshot.data!;
          if (books.isEmpty) {
            return const Center(child: Text('No books yet. Tap + to add one.', style: TextStyle(color: AppColors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: books.length,
            itemBuilder: (context, i) {
              final book = books[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: SizedBox(
                    width: 44,
                    height: 60,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: book.imageUrl.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              book.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.menu_book, color: AppColors.plum),
                            ),
                          )
                              : const Icon(Icons.menu_book, color: AppColors.plum),
                        ),
                        if (book.featured)
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(Icons.star, size: 14, color: AppColors.lightPurple),
                          ),
                      ],
                    ),
                  ),
                  title: Text(book.title),
                  subtitle: Text('${book.author} • Rs. ${book.price.toStringAsFixed(2)} • Stock: ${book.stock} • ${book.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: AppColors.plum), onPressed: () => _showBookDialog(context, book: book)),
                      IconButton(icon: const Icon(Icons.delete, color: AppColors.lightPurple), onPressed: () => firestoreService.deleteBook(book.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.plum,
        foregroundColor: AppColors.white,
        onPressed: () => _showBookDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBookDialog(BuildContext context, {Book? book}) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: book?.title ?? '');
    final authorCtrl = TextEditingController(text: book?.author ?? '');
    final priceCtrl = TextEditingController(text: book?.price.toString() ?? '');
    final descCtrl = TextEditingController(text: book?.description ?? '');
    final stockCtrl = TextEditingController(text: book?.stock.toString() ?? '');
    final categoryCtrl = TextEditingController(text: book?.category ?? 'General');
    final imageUrlCtrl = TextEditingController(text: book?.imageUrl ?? '');
    final firestoreService = FirestoreService();
    bool isFeatured = book?.featured ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.lavender,
              title: Text(book == null ? 'Add Book' : 'Edit Book'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: authorCtrl,
                        decoration: const InputDecoration(labelText: 'Author'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final parsed = double.tryParse(v);
                          if (parsed == null || parsed < 0) return 'Enter a valid price';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: stockCtrl,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final parsed = int.tryParse(v);
                          if (parsed == null || parsed < 0) return 'Enter a valid stock number';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: categoryCtrl,
                        decoration: const InputDecoration(labelText: 'Category (e.g. Fiction, Romance)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: imageUrlCtrl,
                        decoration: const InputDecoration(labelText: 'Cover Image URL (optional)'),
                        keyboardType: TextInputType.url,
                      ),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show in Featured / Popular'),
                        value: isFeatured,
                        activeThumbColor: AppColors.plum,
                        onChanged: (value) => setDialogState(() => isFeatured = value),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final newBook = Book(
                      id: book?.id ?? '',
                      title: titleCtrl.text.trim(),
                      author: authorCtrl.text.trim(),
                      price: double.parse(priceCtrl.text),
                      description: descCtrl.text.trim(),
                      stock: int.parse(stockCtrl.text),
                      category: categoryCtrl.text.trim(),
                      imageUrl: imageUrlCtrl.text.trim(),
                      featured: isFeatured,
                    );
                    if (book == null) {
                      await firestoreService.addBook(newBook);
                    } else {
                      await firestoreService.updateBook(newBook);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}