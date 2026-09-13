import 'package:flutter/material.dart';
import 'app_colors.dart';

// Canonical list of order stages, in the order they progress through.
const List<String> orderStatusStages = ['received', 'packaging', 'dispatched', 'delivered'];

String orderStatusLabel(String status) {
  switch (status) {
    case 'received':
      return 'Order Received';
    case 'packaging':
      return 'Packaging';
    case 'dispatched':
      return 'Dispatched';
    case 'delivered':
      return 'Delivered';
    default:
      return status;
  }
}

IconData orderStatusIcon(String status) {
  switch (status) {
    case 'received':
      return Icons.receipt_long_outlined;
    case 'packaging':
      return Icons.inventory_2_outlined;
    case 'dispatched':
      return Icons.local_shipping_outlined;
    case 'delivered':
      return Icons.check_circle;
    default:
      return Icons.help_outline;
  }
}

Color orderStatusColor(String status) {
  switch (status) {
    case 'delivered':
      return Colors.green;
    case 'dispatched':
      return AppColors.plum;
    case 'packaging':
      return AppColors.lightPurple;
    default:
      return AppColors.grey;
  }
}