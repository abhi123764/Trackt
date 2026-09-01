import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../../auth/login_screen.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  void _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final initial = (currentUser != null && currentUser.fName.isNotEmpty)
        ? currentUser.fName[0].toUpperCase()
        : null;

    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: AppColors.tealPrimary),
        ),
        const Spacer(),
        const Text(
          'Owners Deck',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.tealPrimary,
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.tealPrimary,
              ),
            ),
            Positioned(
              right: 6,
              top: 5,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              _handleLogout(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                currentUser != null
                    ? '${currentUser.fName} ${currentUser.lName}'
                    : 'Account',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: AppColors.danger),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.tealPrimary,
            child: initial != null
                ? Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
        ),
      ],
    );
  }
}
