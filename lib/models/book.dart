class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final String description;
  final int stock;
  final String category;
  final String imageUrl;
  final bool featured;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.description,
    required this.stock,
    this.category = 'General',
    this.imageUrl = '',
    this.featured = false,
  });

  factory Book.fromMap(String id, Map<String, dynamic> map) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      stock: map['stock'] ?? 0,
      category: map['category'] ?? 'General',
      imageUrl: map['imageUrl'] ?? '',
      featured: map['featured'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'price': price,
      'description': description,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'featured': featured,
    };
  }
}