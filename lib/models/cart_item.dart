class CartItem {
  final String bookId;
  final String title;
  final double price;
  int quantity;

  CartItem({
    required this.bookId,
    required this.title,
    required this.price,
    this.quantity = 1,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      bookId: map['bookId'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'price': price,
      'quantity': quantity,
    };
  }

  double get subtotal => price * quantity;
}