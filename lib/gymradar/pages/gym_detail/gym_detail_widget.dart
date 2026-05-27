import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/gymradar/components/bottom_nav/bottom_nav_widget.dart';
import 'gym_detail_model.dart';
export 'gym_detail_model.dart';

class GymDetailWidget extends StatefulWidget {
  const GymDetailWidget({super.key, required this.gymId});

  static String routeName = 'GymDetail';
  static String routePath = '/gym/:id';

  final String gymId;

  @override
  State<GymDetailWidget> createState() => _GymDetailWidgetState();
}

class _GymDetailWidgetState extends State<GymDetailWidget> {
  late GymDetailModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GymDetailModel());
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
    final gym = FFAppState().gymById(widget.gymId);

    if (gym == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Gym no encontrado')),
        bottomNavigationBar: const BottomNavWidget(current: 1),
      );
    }

    final inCompare = FFAppState().isInCompare(gym['id'] as String);
    final tags = (gym['tags'] as List).cast<String>();

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: cs.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.black.withOpacity(0.5),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/search');
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.arrow_back,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.favorite_border,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.share_outlined,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    gym['imageUrl'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: cs.surfaceContainerHighest,
                      child: const Icon(Icons.fitness_center, size: 64),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ((gym['isOpen'] as bool)
                                        ? Colors.green
                                        : Colors.red)
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
                                  const SizedBox(width: 6),
                                  Text(
                                    (gym['isOpen'] as bool)
                                        ? 'Abierto ahora'
                                        : 'Cerrado',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star,
                                      size: 13, color: Colors.amber),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${gym['rating']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gym['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                  blurRadius: 8, color: Colors.black54)
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.place,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                '${gym['district']} · ${gym['distance']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
            sliver: SliverList.list(
              children: [
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        iconColor: Colors.amber,
                        value: '${gym['rating']}',
                        label: '${gym['reviewCount']} reseñas',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.attach_money,
                        iconColor: cs.primary,
                        value: 'S/. ${gym['priceMin']}',
                        label: 'desde / mes',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.directions_walk,
                        iconColor: Colors.teal,
                        value: '${gym['distance']}',
                        label: 'distancia',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.phone,
                        label: 'Llamar',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.directions,
                        label: 'Cómo llegar',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.share_outlined,
                        label: 'Compartir',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle('Dirección'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.place, color: cs.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(gym['address'] as String,
                          style: const TextStyle(height: 1.4)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionTitle('Servicios'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: cs.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                _SectionTitle('Acerca del gym'),
                Text(
                  'Gimnasio moderno en ${gym['district']}. Equipamiento completo, '
                  'instructores certificados y horarios flexibles. Cuenta con '
                  '${tags.join(", ").toLowerCase()} y otros servicios de calidad '
                  'para todos los niveles de entrenamiento.',
                  style: TextStyle(
                      color: cs.onSurface.withOpacity(0.85),
                      height: 1.5,
                      fontSize: 14),
                ),
                const SizedBox(height: 24),
                _SectionTitle('Horarios'),
                _ScheduleRow(day: 'Lun - Vie', hours: '5:00 — 23:00'),
                _ScheduleRow(day: 'Sábado', hours: '6:00 — 22:00'),
                _ScheduleRow(day: 'Domingo', hours: '7:00 — 20:00'),
                const SizedBox(height: 24),
                _SectionTitle('Contacto'),
                Row(
                  children: [
                    Icon(Icons.phone, color: cs.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('+${gym['phone']}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: inCompare ? Colors.grey : cs.primary,
        foregroundColor: Colors.white,
        icon: Icon(inCompare ? Icons.check : Icons.add),
        label: Text(inCompare ? 'En comparación' : 'Agregar a comparación'),
        onPressed: () {
          if (inCompare) {
            FFAppState().removeFromCompare(gym['id'] as String);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quitado de la comparación')),
            );
          } else {
            FFAppState().addToCompare(gym['id'] as String);
            final n = FFAppState().compareIds.length;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Agregado ($n/2). ${n == 2 ? "Listo para comparar" : ""}'),
                action: n >= 1
                    ? SnackBarAction(
                        label: 'Ver',
                        onPressed: () => context.go('/compare'),
                      )
                    : null,
              ),
            );
          }
          setState(() {});
        },
      ),
      bottomNavigationBar: const BottomNavWidget(current: 1),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800)),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.day, required this.hours});
  final String day;
  final String hours;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day,
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontSize: 13)),
          Text(hours,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
