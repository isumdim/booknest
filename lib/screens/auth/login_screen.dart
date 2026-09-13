import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/novelle_logo.dart';
import '../../services/auth_service.dart';
import '../customer/customer_home_screen.dart';
import '../staff/staff_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }

    final appUser = await _authService.getCurrentAppUser();
    setState(() => _isLoading = false);
    if (!mounted) return;

    if (appUser == null) {
      setState(() => _errorMessage = 'Could not load your profile.');
      return;
    }

    Widget destination;
    switch (appUser.role) {
      case 'admin':
        destination = const AdminHomeScreen();
        break;
      case 'staff':
        destination = const StaffHomeScreen();
        break;
      default:
        destination = const CustomerHomeScreen();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.plumDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: NovelleLogo(size: 72)),
                  const SizedBox(height: 20),
                  Text(
                    'Novelle',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 46,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stories worth keeping.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.lightPurple,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lavender,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Please enter your email';
                            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your password';
                            if (value.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                          ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                              : const Text('LOG IN'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text("Don't have an account? Register"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}