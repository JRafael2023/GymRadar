import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key, required this.current});

  /// 0=Inicio 1=Buscar 2=Comparar 3=Perfil
  final int current;

  static const _routes = ['/home', '/search', '/compare', '/profile'];

  void _go(BuildContext context, int i) {
    if (i == current) return;
    context.go(_routes[i]);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  active: current == 0,
                  onTap: () => _go(context, 0),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Buscar',
                  active: current == 1,
                  onTap: () => _go(context, 1),
                ),
                _NavItem(
                  icon: Icons.compare_arrows_rounded,
                  label: 'Comparar',
                  active: current == 2,
                  onTap: () => _go(context, 2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  active: current == 3,
                  onTap: () => _go(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inactiveColor = cs.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: active ? 16 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: active ? cs.primary.withOpacity(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: active ? cs.primary : inactiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: active ? cs.primary : inactiveColor,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
