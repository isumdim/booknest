import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../models/app_user.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<AppUser>>(
      stream: firestoreService.usersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.plum));
        final users = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final user = users[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.plum,
                  foregroundColor: AppColors.white,
                  child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: DropdownButton<String>(
                  value: user.role,
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (newRole) {
                    if (newRole != null) firestoreService.updateUserRole(user.uid, newRole);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}