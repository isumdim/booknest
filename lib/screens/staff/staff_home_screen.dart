import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'manage_books_screen.dart';
import 'staff_orders_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});
  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _index = 0;
  final _authService = AuthService();

  final _screens = const [
    ManageBooksScreen(),
    StaffOrdersScreen(),
  ];

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Manage Books', 'Orders'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff • ${titles[_index]}'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.library_books_outlined), label: 'Books'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Orders'),
        ],
      ),
    );
  }
}