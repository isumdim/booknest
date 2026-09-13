import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/novelle_logo.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/book.dart';
import 'book_detail_screen.dart';
import '../auth/login_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _firestoreService = FirestoreService();
  String _query = '';
  String _selectedCategory = 'All';

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
            child: Row(
              children: [
                const NovelleLogo(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Novelle',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightPurple,
                        ),
                      ),
                      const Text('Find your next read',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.cream)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.cream),
                  onPressed: () => _logout(context),
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              color: AppColors.lavender,
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

                  final featuredBooks = allBooks.where((b) => b.featured).toList();
                  final featured = featuredBooks.isNotEmpty ? featuredBooks.first : null;
                  final popular = featuredBooks;

                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      if (featured != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: featured))),
                              child: Container(
                                height: 160,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.plum,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: -20,
                                      top: -20,
                                      child: Icon(Icons.auto_stories, size: 120, color: AppColors.lightPurple.withOpacity(0.2)),
                                    ),
                                    if (featured.imageUrl.isNotEmpty)
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        bottom: 10,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            featured.imageUrl,
                                            width: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.only(right: featured.imageUrl.isNotEmpty ? 90 : 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text('FEATURED PICK',
                                              style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: AppColors.lightPurple)),
                                          const SizedBox(height: 8),
                                          Text(featured.title,
                                              maxLines: 2, overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, color: AppColors.cream)),
                                          const SizedBox(height: 4),
                                          Text('by ${featured.author}',
                                              style: TextStyle(fontSize: 13, color: AppColors.cream.withOpacity(0.7))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search books or authors...',
                              prefixIcon: Icon(Icons.search, color: AppColors.grey),
                            ),
                            onChanged: (value) => setState(() => _query = value.toLowerCase()),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
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
                      ),
                      if (_query.isEmpty && _selectedCategory == 'All' && popular.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                            child: Text('Popular', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.black)),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 140,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: popular.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final book = popular[i];
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                      context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
                                  child: Container(
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: AppColors.plum,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned.fill(
                                          child: book.imageUrl.isNotEmpty
                                              ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              book.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                              const Center(child: Icon(Icons.menu_book_rounded, color: AppColors.lightPurple, size: 32)),
                                            ),
                                          )
                                              : const Center(child: Icon(Icons.menu_book_rounded, color: AppColors.lightPurple, size: 32)),
                                        ),
                                        if (book.imageUrl.isEmpty)
                                          Positioned(
                                            left: 6,
                                            right: 6,
                                            bottom: 8,
                                            child: Text(
                                              book.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.cream),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      ],
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          child: Text(
                            _selectedCategory == 'All' ? 'All Books' : _selectedCategory,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.black),
                          ),
                        ),
                      ),
                      if (books.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(child: Text('No books found.', style: TextStyle(color: AppColors.grey))),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 18,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.6,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, i) => _BookCard(book: books[i]),
                              childCount: books.length,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
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