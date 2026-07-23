import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Barra de navegación inferior del cliente (Inicio / Historial / Perfil).
/// Compartida entre pantallas del flujo del cliente.
class ClaimVisionBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const ClaimVisionBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(top: false, child: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: context.cardColor,
      selectedItemColor: AppColors.amber,
      unselectedItemColor: context.textHintColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    ));
  }
}
