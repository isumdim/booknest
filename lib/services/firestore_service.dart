import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- BOOKS ----------------

  Stream<List<Book>> booksStream() {
    return _db.collection('books').orderBy('title').snapshots().map(
            (snap) => snap.docs.map((d) => Book.fromMap(d.id, d.data())).toList());
  }

  Future<void> addBook(Book book) async {
    await _db.collection('books').add(book.toMap());
  }

  Future<void> updateBook(Book book) async {
    await _db.collection('books').doc(book.id).update(book.toMap());
  }

  Future<void> deleteBook(String bookId) async {
    await _db.collection('books').doc(bookId).delete();
  }

  // ---------------- CART ----------------

  Stream<List<CartItem>> cartStream(String uid) {
    return _db.collection('users').doc(uid).collection('cart').snapshots().map(
            (snap) => snap.docs.map((d) => CartItem.fromMap(d.data())).toList());
  }

  Future<void> addToCart(String uid, CartItem item) async {
    final ref = _db.collection('users').doc(uid).collection('cart').doc(item.bookId);
    final existing = await ref.get();
    if (existing.exists) {
      final currentQty = existing.data()!['quantity'] ?? 1;
      await ref.update({'quantity': currentQty + item.quantity});
    } else {
      await ref.set(item.toMap());
    }
  }

  Future<void> updateCartQuantity(String uid, String bookId, int qty) async {
    if (qty <= 0) {
      await removeFromCart(uid, bookId);
      return;
    }
    await _db.collection('users').doc(uid).collection('cart').doc(bookId).update({'quantity': qty});
  }

  Future<void> removeFromCart(String uid, String bookId) async {
    await _db.collection('users').doc(uid).collection('cart').doc(bookId).delete();
  }

  Future<void> clearCart(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('cart').get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ---------------- ORDERS ----------------

  Future<void> placeOrder(
      String uid,
      List<CartItem> items, {
        required String deliveryName,
        required String deliveryAddress,
        required String deliveryPhone,
      }) async {
    if (items.isEmpty) {
      throw Exception('Cannot place an order with an empty cart.');
    }
    final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final order = OrderModel(
      id: '',
      userId: uid,
      items: items,
      total: total,
      status: 'pending',
      createdAt: DateTime.now(),
      deliveryName: deliveryName,
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
    );
    await _db.collection('orders').add(order.toMap());
    await clearCart(uid);
  }

  Stream<List<OrderModel>> myOrdersStream(String uid) {
    return _db.collection('orders').where('userId', isEqualTo: uid).snapshots().map(
            (snap) => snap.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<OrderModel>> allOrdersStream() {
    return _db.collection('orders').snapshots().map(
            (snap) => snap.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }

  // ---------------- USERS (admin) ----------------

  Stream<List<AppUser>> usersStream() {
    return _db.collection('users').snapshots().map(
            (snap) => snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
  }
}