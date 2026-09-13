import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavender,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(color: AppColors.plum, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: AppColors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Placed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for shopping with Novelle.\nYou can track your order in My Orders.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('CONTINUE SHOPPING'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}