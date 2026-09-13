import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../models/cart_item.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String uid;
  final List<CartItem> items;

  const CheckoutScreen({super.key, required this.uid, required this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.fold<double>(0, (sum, i) => sum + i.subtotal);

    return Scaffold(
      backgroundColor: AppColors.lavender,
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Delivery Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.black)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Delivery Address'),
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your delivery address' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
                      final digitsOnly = v.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digitsOnly.length < 9) return 'Please enter a valid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Order Summary',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.black)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          for (final item in widget.items)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text('${item.title} x${item.quantity}',
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                  Text('Rs. ${item.subtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              Text('Rs. ${total.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.plum)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.local_shipping_outlined, color: AppColors.plum),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('Standard delivery • Estimated 3-5 business days',
                                style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : _confirmOrder,
                  child: _isPlacingOrder
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  )
                      : const Text('CONFIRM ORDER'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);
    try {
      await _firestoreService.placeOrder(
        widget.uid,
        widget.items,
        deliveryName: _nameController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        deliveryPhone: _phoneController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
      );
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}