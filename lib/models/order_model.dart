import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final String status; // "pending", "fulfilled"
  final DateTime createdAt;
  final String deliveryName;
  final String deliveryAddress;
  final String deliveryPhone;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.deliveryName = '',
    this.deliveryAddress = '',
    this.deliveryPhone = '',
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      deliveryName: map['deliveryName'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      deliveryPhone: map['deliveryPhone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'deliveryName': deliveryName,
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
    };
  }
}