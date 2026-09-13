import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'home_screen.dart';
import 'browse_screen.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});
  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _index = 0;
  final _authService = AuthService();

  final _screens = const [
    HomeScreen(),
    BrowseScreen(),
    CartScreen(),
    MyOrdersScreen(),
  ];

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['', '', 'My Cart', 'My Orders'];
    final hasOwnHeader = _index == 0 || _index == 1;

    return Scaffold(
      backgroundColor: AppColors.lavender,
      appBar: hasOwnHeader
          ? null
          : AppBar(
        title: Text(titles[_index]),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Logout')],
      ),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        ],
      ),
    );
  }
}