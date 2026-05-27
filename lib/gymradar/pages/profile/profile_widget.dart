import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/gymradar/components/bottom_nav/bottom_nav_widget.dart';
import 'profile_model.dart';
export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'Profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _logout() {
    FFAppState().logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final cs = Theme.of(context).colorScheme;
    final s = FFAppState();
    final isGuest = s.isGuest;
    final email = s.userEmail.isEmpty ? '—' : s.userEmail;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: const Text('Perfil',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: cs.primary.withOpacity(0.15),
                  child: Icon(
                    isGuest ? Icons.person_outline : Icons.person,
                    size: 44,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isGuest ? 'Invitado' : (s.userName.isEmpty ? 'Usuario' : s.userName),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _Tile(
            icon: Icons.compare_arrows,
            title: 'Mis comparaciones',
            subtitle: '${s.compareIds.length} gym(s) en comparación',
            onTap: () => context.go('/compare'),
          ),
          _Tile(
            icon: Icons.search,
            title: 'Buscar gyms',
            onTap: () => context.go('/search'),
          ),
          _Tile(
            icon: Icons.map_outlined,
            title: 'Ver mapa',
            onTap: () => context.go('/home'),
          ),
          const SizedBox(height: 16),
          if (isGuest)
            FilledButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesión'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: Text('GymRadar v1.0',
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 12)),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(current: 3),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: cs.primary),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
