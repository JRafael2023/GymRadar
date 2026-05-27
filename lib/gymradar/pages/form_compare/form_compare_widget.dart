import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/gymradar/components/bottom_nav/bottom_nav_widget.dart';
import 'form_compare_model.dart';
export 'form_compare_model.dart';

class FormCompareWidget extends StatefulWidget {
  const FormCompareWidget({super.key});

  static String routeName = 'FormCompare';
  static String routePath = '/compare/form';

  @override
  State<FormCompareWidget> createState() => _FormCompareWidgetState();
}

class _FormCompareWidgetState extends State<FormCompareWidget> {
  late FormCompareModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormCompareModel());
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
    final gyms = FFAppState().compareGyms;

    if (gyms.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Comparar')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.compare_arrows, size: 64),
              const SizedBox(height: 12),
              const Text('Necesitas 2 gyms para comparar'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/compare'),
                child: const Text('Agregar gyms'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavWidget(current: 2),
      );
    }

    final a = gyms[0];
    final b = gyms[1];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: const Text('Comparación',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/compare'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _GymHeader(gym: a)),
                    const SizedBox(width: 8),
                    Expanded(child: _GymHeader(gym: b)),
                  ],
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CompareRow(
              label: 'Distrito',
              a: a['district'] as String,
              b: b['district'] as String,
            ),
            _CompareRow(
              label: 'Distancia',
              a: a['distance'] as String,
              b: b['distance'] as String,
            ),
            _CompareRow(
              label: 'Rating',
              a: '${a['rating']} ★ (${a['reviewCount']})',
              b: '${b['rating']} ★ (${b['reviewCount']})',
              betterA: (a['rating'] as num) >= (b['rating'] as num),
              betterB: (b['rating'] as num) >= (a['rating'] as num),
            ),
            _CompareRow(
              label: 'Precio mín.',
              a: 'S/. ${a['priceMin']}',
              b: 'S/. ${b['priceMin']}',
              betterA: (a['priceMin'] as num) <= (b['priceMin'] as num),
              betterB: (b['priceMin'] as num) <= (a['priceMin'] as num),
            ),
            _CompareRow(
              label: 'Precio máx.',
              a: 'S/. ${a['priceMax']}',
              b: 'S/. ${b['priceMax']}',
              betterA: (a['priceMax'] as num) <= (b['priceMax'] as num),
              betterB: (b['priceMax'] as num) <= (a['priceMax'] as num),
            ),
            _CompareRow(
              label: 'Estado',
              a: (a['isOpen'] as bool) ? 'Abierto' : 'Cerrado',
              b: (b['isOpen'] as bool) ? 'Abierto' : 'Cerrado',
            ),
            const SizedBox(height: 12),
            _SectionTitle('Servicios'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _TagsCol(tags: (a['tags'] as List).cast<String>())),
                const SizedBox(width: 8),
                Expanded(child: _TagsCol(tags: (b['tags'] as List).cast<String>())),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/gym/${a['id']}'),
                    child: const Text('Ver Gym 1'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/gym/${b['id']}'),
                    child: const Text('Ver Gym 2'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(current: 2),
    );
  }
}

class _GymHeader extends StatelessWidget {
  const _GymHeader({required this.gym});
  final Map<String, dynamic> gym;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  gym['imageUrl'] as String,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: cs.surface,
                    child: const Icon(Icons.fitness_center, size: 36),
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
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 8,
                  right: 8,
                  child: Text(
                    gym['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black54),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 13, color: Colors.amber),
                  const SizedBox(width: 3),
                  Text('${gym['rating']}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text(
                    'S/. ${gym['priceMin']}',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.a,
    required this.b,
    this.betterA = false,
    this.betterB = false,
  });
  final String label;
  final String a;
  final String b;
  final bool betterA;
  final bool betterB;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _Cell(
                    text: a, highlight: betterA && !betterB ? cs.primary : null),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Cell(
                    text: b, highlight: betterB && !betterA ? cs.primary : null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.text, this.highlight});
  final String text;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: highlight?.withOpacity(0.18) ?? cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: highlight != null
            ? Border.all(color: highlight!, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    highlight != null ? FontWeight.w800 : FontWeight.w500,
                color: highlight ?? cs.onSurface,
              ),
            ),
          ),
          if (highlight != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.emoji_events_rounded,
                size: 16, color: highlight),
          ],
        ],
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
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}

class _TagsCol extends StatelessWidget {
  const _TagsCol({required this.tags});
  final List<String> tags;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .map((t) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(t, style: const TextStyle(fontSize: 11)),
              ))
          .toList(),
    );
  }
}
