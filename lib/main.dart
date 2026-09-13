import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/staff/staff_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lavender,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.plum,
        surface: AppColors.lavender,
        primary: AppColors.plum,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lavender,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.plum,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.plum),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.line, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.lightPurple, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.grey),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lavender,
        indicatorColor: AppColors.lightPurple.withOpacity(0.5),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, color: AppColors.black),
        ),
      ),
    );

    return MaterialApp(
      title: 'Novelle',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.apply(bodyColor: AppColors.black, displayColor: AppColors.black),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.lavender,
            body: Center(child: CircularProgressIndicator(color: AppColors.plum)),
          );
        }
        if (!snapshot.hasData) return const LoginScreen();

        return FutureBuilder(
          future: AuthService().getCurrentAppUser(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.lavender,
                body: Center(child: CircularProgressIndicator(color: AppColors.plum)),
              );
            }
            final appUser = roleSnapshot.data;
            if (appUser == null) return const LoginScreen();

            switch (appUser.role) {
              case 'admin':
                return const AdminHomeScreen();
              case 'staff':
                return const StaffHomeScreen();
              default:
                return const CustomerHomeScreen();
            }
          },
        );
      },
    );
  }
}