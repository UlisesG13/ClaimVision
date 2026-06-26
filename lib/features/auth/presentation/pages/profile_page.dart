import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/claim_vision_bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.blueprint,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined, color: AppColors.blueprint),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            ProfileHeader(),
            const Gap(AppSpacing.xl),
            MenuOptionsSection(),
            const Gap(AppSpacing.lg),
            LogoutButton(),
          ],
        ),
      ),
      bottomNavigationBar: ClaimVisionBottomNav(currentIndex: 2),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.blueprint,
                child: Text(
                  'JP',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, size: 14, color: AppColors.white),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Text('Juan Pérez', style: theme.textTheme.headlineLarge),
          const Gap(AppSpacing.xs),
          Text(
            'juan.perez@email.com',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Gap(AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.blueprint.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Cliente',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.blueprint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuOptionsSection extends StatelessWidget {
  const MenuOptionsSection({super.key});

  final List<Map<String, dynamic>> menuItems = const [
    {'icon': Icons.person_outlined, 'title': 'Datos personales'},
    {'icon': Icons.description_outlined, 'title': 'Mis pólizas'},
    {'icon': Icons.history_outlined, 'title': 'Historial de siniestros'},
    {'icon': Icons.notifications_outlined, 'title': 'Notificaciones'},
    {'icon': Icons.payment_outlined, 'title': 'Métodos de pago'},
    {'icon': Icons.help_outline, 'title': 'Ayuda y soporte'},
    {'icon': Icons.info_outline, 'title': 'Acerca de'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.map((item) {
          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: AppColors.blueprint,
            ),
            title: Text(
              item['title'] as String,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
            ),
            onTap: () {},
          );
        }).toList(),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_outlined),
        label: const Text('Cerrar sesión'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.alert,
          side: BorderSide(color: AppColors.alert.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
