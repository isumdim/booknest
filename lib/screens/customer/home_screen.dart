import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/novelle_logo.dart';
import '../../services/firestore_service.dart';
import '../../models/book.dart';
import 'book_detail_screen.dart';
import 'browse_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.lavender,
      body: Column(
        children: [
          // ---- Purple header strip ----
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
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
                        const Text('Welcome back',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.cream)),
                      ],
                    ),
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
                child: StreamBuilder<List<Book>>(
                  stream: firestoreService.booksStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.plum));

                    final books = snapshot.data!;
                    Book? bookOfMonth;
                    for (final b in books) {
                      if (b.isBookOfMonth) {
                        bookOfMonth = b;
                        break;
                      }
                    }
                    final bestSellers = books.where((b) => b.isBestSeller).take(6).toList();
                    final categories = {for (final b in books) b.category}.toList()..sort();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      children: [
                        if (bookOfMonth != null) ...[
                          const Text('Book of the Month',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.black)),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: bookOfMonth!))),
                            child: Container(
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.plum,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Stack(
                                children: [
                                  if (bookOfMonth.imageUrl.isNotEmpty)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Opacity(
                                          opacity: 0.35,
                                          child: Image.network(bookOfMonth.imageUrl, fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text('\u2605 BOOK OF THE MONTH',
                                            style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: AppColors.lightPurple)),
                                        const SizedBox(height: 8),
                                        Text(bookOfMonth.title,
                                            maxLines: 2, overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, color: AppColors.cream)),
                                        const SizedBox(height: 4),
                                        Text('by ${bookOfMonth.author}', style: TextStyle(fontSize: 13, color: AppColors.cream.withOpacity(0.8))),
                                        const SizedBox(height: 4),
                                        Text('Rs. ${bookOfMonth.price.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.cream)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        if (bestSellers.isNotEmpty) ...[
                          const Text('Best Sellers',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.black)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 190,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: bestSellers.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final book = bestSellers[i];
                                return GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
                                  child: SizedBox(
                                    width: 120,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(color: AppColors.plum, borderRadius: BorderRadius.circular(10)),
                                            child: book.imageUrl.isNotEmpty
                                                ? ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                book.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.menu_book_rounded, color: AppColors.lightPurple)),
                                              ),
                                            )
                                                : const Center(child: Icon(Icons.menu_book_rounded, color: AppColors.lightPurple)),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                        Text('Rs. ${book.price.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        if (categories.isNotEmpty) ...[
                          const Text('Categories',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.black)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: categories.map((cat) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => BrowseScreen(initialCategory: cat)),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        if (bookOfMonth == null && bestSellers.isEmpty && categories.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: Text('No books available yet.', style: TextStyle(color: AppColors.grey))),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}