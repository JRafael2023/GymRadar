import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/gymradar/components/bottom_nav/bottom_nav_widget.dart';
import 'home_model.dart';
export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late HomeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? _selectedGym;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) safeSetState(() => _model.isLoading = false);
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final cs = Theme.of(context).colorScheme;
    final gyms = FFAppState().allGyms;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: cs.surface,
      drawer: _AppDrawer(),
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('GymRadar',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _MapPlaceholder(
                  gyms: gyms,
                  onTapGym: (g) => setState(() => _selectedGym = g),
                ),
                if (_selectedGym != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _GymQuickCard(
                      gym: _selectedGym!,
                      onClose: () => setState(() => _selectedGym = null),
                      onOpen: () =>
                          context.go('/gym/${_selectedGym!['id']}'),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: const BottomNavWidget(current: 0),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.gyms, required this.onTapGym});

  final List<Map<String, dynamic>> gyms;
  final void Function(Map<String, dynamic>) onTapGym;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.surfaceContainerHighest, cs.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Grid lines (mapa fake)
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(color: cs.outlineVariant.withOpacity(0.4)),
          ),
          // Pin del usuario (centro)
          const Center(
            child: Icon(Icons.my_location, size: 28, color: Colors.blue),
          ),
          // Pins de gyms (distribuidos)
          ...List.generate(gyms.length, (i) {
            final g = gyms[i];
            final dx = 0.15 + (i % 3) * 0.3;
            final dy = 0.2 + (i ~/ 3) * 0.25;
            return Align(
              alignment: Alignment(dx * 2 - 1, dy * 2 - 1),
              child: _GymPin(
                gym: g,
                onTap: () => onTapGym(g),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GymPin extends StatelessWidget {
  const _GymPin({required this.gym, required this.onTap});
  final Map<String, dynamic> gym;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final open = gym['isOpen'] as bool;
    final rating = gym['rating'] as num;
    final color = open ? const Color(0xFFE53935) : const Color(0xFF6B7280);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.85)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fitness_center,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 11, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Pico del pin
          Transform.translate(
            offset: const Offset(0, -2),
            child: CustomPaint(
              size: const Size(10, 6),
              painter: _PinTipPainter(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinTipPainter extends CustomPainter {
  _PinTipPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = FFAppState();
    final isGuest = s.isGuest;
    final name = isGuest
        ? 'Invitado'
        : (s.userName.isEmpty ? 'Usuario' : s.userName);
    final email = s.userEmail.isEmpty ? '—' : s.userEmail;

    return Drawer(
      backgroundColor: cs.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary,
                  cs.primary.withOpacity(0.7),
                  const Color(0xFF1B3A6B),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fitness_center,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'GymRadar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2),
                      ),
                      child: Icon(
                        isGuest ? Icons.person_outline : Icons.person,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: const Text('Buscar gyms'),
              onTap: () {
                Navigator.pop(context);
                context.go('/search');
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows_rounded),
              title: const Text('Comparar'),
              trailing: s.compareIds.isEmpty
                  ? null
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${s.compareIds.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
              onTap: () {
                Navigator.pop(context);
                context.go('/compare');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                context.go('/profile');
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                isGuest ? Icons.login : Icons.logout,
                color: isGuest ? cs.primary : Colors.redAccent,
              ),
              title: Text(
                isGuest ? 'Iniciar sesión' : 'Cerrar sesión',
                style: TextStyle(
                  color: isGuest ? cs.primary : Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (!isGuest) FFAppState().logout();
                context.go('/login');
              },
            ),
            const SizedBox(height: 8),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('GymRadar v1.0',
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant)),
              ),
            ),
          ],
        ),
    );
  }
}

class _GymQuickCard extends StatelessWidget {
  const _GymQuickCard({
    required this.gym,
    required this.onClose,
    required this.onOpen,
  });

  final Map<String, dynamic> gym;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tags = (gym['tags'] as List).cast<String>();
    final open = gym['isOpen'] as bool;
    return Material(
      color: Colors.transparent,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: Offset.zero,
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              onTap: onOpen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Hero image
                  Stack(
                    children: [
                      Image.network(
                        gym['imageUrl'] as String,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: cs.surfaceContainerHighest,
                          child: const Icon(Icons.fitness_center, size: 48),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.75),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.black.withOpacity(0.45),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onClose,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (open ? Colors.green : Colors.red)
                                .withOpacity(0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                open ? 'Abierto' : 'Cerrado',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gym['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                      blurRadius: 6,
                                      color: Colors.black54),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.place,
                                    size: 13, color: Colors.white70),
                                const SizedBox(width: 2),
                                Text(
                                  '${gym['district']} · ${gym['distance']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _MetricChip(
                              icon: Icons.star,
                              iconColor: Colors.amber,
                              label: '${gym['rating']}',
                              sub: '(${gym['reviewCount']})',
                            ),
                            const SizedBox(width: 8),
                            _MetricChip(
                              icon: Icons.attach_money,
                              iconColor: cs.primary,
                              label:
                                  'S/. ${gym['priceMin']}-${gym['priceMax']}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 26,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: tags.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 6),
                            itemBuilder: (_, i) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.12),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Text(
                                tags[i],
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: onOpen,
                            icon: const Icon(Icons.arrow_forward_rounded,
                                size: 18),
                            label: const Text('Ver detalles'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                            ),
                          ),
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.sub,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            if (sub != null) ...[
              const SizedBox(width: 4),
              Text(sub!,
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}
