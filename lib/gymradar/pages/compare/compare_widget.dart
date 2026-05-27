import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/gymradar/components/bottom_nav/bottom_nav_widget.dart';
import 'compare_model.dart';
export 'compare_model.dart';

class CompareWidget extends StatefulWidget {
  const CompareWidget({super.key});

  static String routeName = 'Compare';
  static String routePath = '/compare';

  @override
  State<CompareWidget> createState() => _CompareWidgetState();
}

class _CompareWidgetState extends State<CompareWidget> {
  late CompareModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompareModel());
    _model.searchController?.addListener(() {
      safeSetState(
          () => _model.query = _model.searchController?.text ?? '');
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _searchResults() {
    final all = FFAppState().allGyms;
    final ids = FFAppState().compareIds;
    final q = _model.query.trim().toLowerCase();
    final pool = all.where((g) => !ids.contains(g['id'])).toList();
    if (q.isEmpty) return pool;
    return pool.where((g) {
      final n = (g['name'] as String).toLowerCase();
      final a = (g['address'] as String).toLowerCase();
      return n.contains(q) || a.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final cs = Theme.of(context).colorScheme;
    final selected = FFAppState().compareGyms;
    final canCompare = selected.length == 2;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: const Text('Comparar',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (selected.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Limpiar',
              onPressed: () => FFAppState().clearCompare(),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Selecciona 2 gyms para comparar',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
            _SelectedSlots(gyms: selected),
            const SizedBox(height: 12),
            if (canCompare)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/compare/form'),
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Comparar ahora'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _model.searchController,
                focusNode: _model.searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Buscar gym para agregar',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _searchResults().length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final g = _searchResults()[i];
                  return _AddCard(
                    gym: g,
                    onAdd: () {
                      FFAppState().addToCompare(g['id'] as String);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(current: 2),
    );
  }
}

class _SelectedSlots extends StatelessWidget {
  const _SelectedSlots({required this.gyms});
  final List<Map<String, dynamic>> gyms;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                  child: _Slot(
                      gym: gyms.isNotEmpty ? gyms[0] : null,
                      label: 'Gym 1')),
              const SizedBox(width: 12),
              Expanded(
                  child: _Slot(
                      gym: gyms.length > 1 ? gyms[1] : null,
                      label: 'Gym 2')),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
              border: Border.all(color: cs.surface, width: 3),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'VS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.gym, required this.label});
  final Map<String, dynamic>? gym;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (gym == null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outlineVariant,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add,
                    size: 24, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Selecciona abajo',
                  style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 10)),
            ],
          ),
        ),
      );
    }
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              gym!['imageUrl'] as String,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: cs.surfaceContainerHighest,
                child: const Icon(Icons.fitness_center, size: 36),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black.withOpacity(0.55),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => FFAppState()
                      .removeFromCompare(gym!['id'] as String),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gym!['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black54),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('${gym!['rating']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'S/. ${gym!['priceMin']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
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
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({required this.gym, required this.onAdd});
  final Map<String, dynamic> gym;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onAdd,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  gym['imageUrl'] as String,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: cs.surface,
                    child: const Icon(Icons.fitness_center, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gym['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(gym['district'] as String,
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.add_circle, color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }
}
