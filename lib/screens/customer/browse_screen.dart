import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/novelle_logo.dart';
import '../../services/firestore_service.dart';
import '../../models/book.dart';
import 'book_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  final String? initialCategory;
  const BrowseScreen({super.key, this.initialCategory});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _firestoreService = FirestoreService();
  String _query = '';
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: AppColors.lavender,
      body: Column(
        children: [
          // ---- Purple header strip ----
          SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.plumDark,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  if (canPop)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.cream),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(left: 4, right: 8),
                      child: NovelleLogo(size: 32),
                    ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Browse Books',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.cream)),
                  ),
                ],
              ),
            ),
          ),

          // ---- Rounded cream body ----
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Container(
                color: AppColors.lavender,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search books or authors...',
                          prefixIcon: Icon(Icons.search, color: AppColors.grey),
                        ),
                        onChanged: (value) => setState(() => _query = value.toLowerCase()),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Book>>(
                        stream: _firestoreService.booksStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.plum));
                          }

                          final allBooks = snapshot.data!;
                          final categories = ['All', ...{for (final b in allBooks) b.category}];

                          var books = allBooks;
                          if (_selectedCategory != 'All') {
                            books = books.where((b) => b.category == _selectedCategory).toList();
                          }
                          if (_query.isNotEmpty) {
                            books = books
                                .where((b) =>
                            b.title.toLowerCase().contains(_query) ||
                                b.author.toLowerCase().contains(_query))
                                .toList();
                          }

                          return Column(
                            children: [
                              SizedBox(
                                height: 40,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: categories.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, i) {
                                    final cat = categories[i];
                                    final isSelected = cat == _selectedCategory;
                                    return ChoiceChip(
                                      label: Text(cat),
                                      selected: isSelected,
                                      onSelected: (_) => setState(() => _selectedCategory = cat),
                                      selectedColor: AppColors.plum,
                                      backgroundColor: AppColors.white,
                                      labelStyle: TextStyle(
                                        color: isSelected ? AppColors.cream : AppColors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(color: AppColors.line),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: books.isEmpty
                                    ? const Center(child: Text('No books found.', style: TextStyle(color: AppColors.grey)))
                                    : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 18,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.6,
                                  ),
                                  itemCount: books.length,
                                  itemBuilder: (context, i) => _BookCard(book: books[i]),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.plum,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: book.imageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        book.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.menu_book_rounded, color: AppColors.lightPurple, size: 40)),
                      ),
                    )
                        : const Center(child: Icon(Icons.menu_book_rounded, color: AppColors.lightPurple, size: 40)),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.lightPurple, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        book.stock > 0 ? book.category.toUpperCase() : 'OUT OF STOCK',
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(book.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.black)),
          Text(book.author,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          const SizedBox(height: 2),
          Text('Rs. ${book.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black)),
        ],
      ),
    );
  }
}