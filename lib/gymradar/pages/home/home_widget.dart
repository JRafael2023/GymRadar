import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
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

  // Índice del tab activo del BottomNav
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 700));
      safeSetState(() => _model.isLoading = false);
    });

    _model.searchController?.addListener(() {
      safeSetState(
          () => _model.searchQuery = _model.searchController?.text ?? '');
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
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        // ── AppBar ──────────────────────────────────────────────────
        appBar: _buildAppBar(context, theme),
        body: Column(
          children: [
            // ── Buscador + toggle mapa ───────────────────────────────
            _buildSearchRow(context, theme),

            // ── Filtros por distrito ─────────────────────────────────
            _buildDistrictFilters(context, theme),

            // ── Divider sutil ────────────────────────────────────────
            Divider(height: 1.0, color: theme.dividerColor),

            // ── Contenido principal ──────────────────────────────────
            Expanded(
              child: _model.isLoading
                  ? _buildSkeletonList(context, theme)
                  : _model.showMap
                      ? _buildMapSection(context, theme)
                      : _buildGymList(context, theme),
            ),
          ],
        ),
        // ── BottomNav ───────────────────────────────────────────────
        bottomNavigationBar: _buildBottomNav(context, theme),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // APP BAR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PreferredSizeWidget _buildAppBar(
      BuildContext context, FlutterFlowTheme theme) {
    final isGuest = FFAppState().isGuest;

    return AppBar(
      backgroundColor: theme.secondaryBackground,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      titleSpacing: 20.0,
      title: Row(
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gym Radar',
                style: theme.titleSmall.override(
                  fontFamily: 'Inter Tight',
                  fontWeight: FontWeight.w800,
                  fontSize: 15.0,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: theme.primary, size: 13.0),
                    const SizedBox(width: 3.0),
                    Text(
                      FFAppState().userDistrict,
                      style: theme.labelSmall.override(
                        fontFamily: 'Inter',
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.0,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: theme.primary, size: 13.0),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Badge invitado
        if (isGuest)
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: theme.chipBackground,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Invitado',
              style: theme.labelSmall.override(
                fontFamily: 'Inter',
                color: theme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        // Avatar usuario
        GestureDetector(
          onTap: () {
            if (isGuest) context.goNamed('Login');
          },
          child: Container(
            margin: const EdgeInsets.only(right: 20.0),
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: isGuest ? theme.tagBackground : theme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
              color: isGuest ? theme.secondaryText : Colors.white,
              size: 22.0,
            ),
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SEARCH ROW
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSearchRow(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      color: theme.secondaryBackground,
      padding:
          const EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 12.0),
      child: Row(
        children: [
          // ── Buscador ──────────────────────────────────────────────
          Expanded(
            child: Container(
              height: 46.0,
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: theme.inputBorder, width: 1.5),
              ),
              child: TextField(
                controller: _model.searchController,
                focusNode: _model.searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Buscar gym, dirección...',
                  hintStyle: theme.bodyMedium
                      .override(fontFamily: 'Inter', color: theme.hintText),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: theme.hintText, size: 20.0),
                  suffixIcon: _model.searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _model.searchController?.clear();
                            safeSetState(() => _model.searchQuery = '');
                          },
                          child: Icon(Icons.close_rounded,
                              color: theme.hintText, size: 18.0),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13.0),
                ),
                style: theme.bodyMedium,
              ),
            ),
          ),

          const SizedBox(width: 10.0),

          // ── Toggle mapa / lista ────────────────────────────────────
          GestureDetector(
            onTap: () => safeSetState(
                () => _model.showMap = !_model.showMap),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46.0,
              height: 46.0,
              decoration: BoxDecoration(
                color: _model.showMap ? theme.primary : theme.tagBackground,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color:
                      _model.showMap ? theme.primary : theme.inputBorder,
                  width: 1.5,
                ),
              ),
              child: Icon(
                _model.showMap
                    ? Icons.map_rounded
                    : Icons.view_list_rounded,
                color: _model.showMap ? Colors.white : theme.secondaryText,
                size: 22.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FILTROS DISTRITOS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildDistrictFilters(
      BuildContext context, FlutterFlowTheme theme) {
    return Container(
      height: 44.0,
      color: theme.secondaryBackground,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        itemCount: _model.districts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final district = _model.districts[index];
          final selected = _model.selectedDistrict == district;

          return GestureDetector(
            onTap: () =>
                safeSetState(() => _model.selectedDistrict = district),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: selected ? theme.primary : theme.tagBackground,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: selected
                      ? theme.primary
                      : theme.dividerColor,
                  width: 1.0,
                ),
              ),
              child: Text(
                district,
                style: theme.labelMedium.override(
                  fontFamily: 'Inter',
                  color: selected ? Colors.white : theme.secondaryText,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MAPA
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildMapSection(BuildContext context, FlutterFlowTheme theme) {
    final gyms = _model.filteredGyms;

    return Stack(
      children: [
        // ── Placeholder mapa ─────────────────────────────────────────
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFE8EEF4),
          child: Stack(
            children: [
              // Grid de calles simulado
              CustomPaint(
                painter: _MapGridPainter(),
                size: Size.infinite,
              ),

              // Marcadores de gyms
              ...gyms.map((gym) => _buildMapMarker(context, theme, gym)),

              // Mi ubicación
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18.0,
                      height: 18.0,
                      decoration: BoxDecoration(
                        color: theme.info,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: theme.info.withValues(alpha: 0.4),
                            blurRadius: 12.0,
                            spreadRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),

        // ── Cards horizontales sobre el mapa (parte inferior) ─────────
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: _buildMapBottomCards(context, theme, gyms),
        ),
      ],
    );
  }

  Widget _buildMapMarker(BuildContext context, FlutterFlowTheme theme,
      Map<String, dynamic> gym) {
    // Posición simulada — en producción usar lat/lng reales
    final index = _model.filteredGyms.indexOf(gym);
    final positions = [
      const Offset(0.25, 0.3),
      const Offset(0.6, 0.25),
      const Offset(0.4, 0.55),
      const Offset(0.7, 0.6),
      const Offset(0.2, 0.65),
      const Offset(0.55, 0.4),
    ];
    final pos = index < positions.length
        ? positions[index]
        : Offset(0.3 + index * 0.1, 0.4);

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                left: constraints.maxWidth * pos.dx,
                top: constraints.maxHeight * pos.dy,
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Precio bubble
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: gym['isOpen'] == true
                              ? theme.primary
                              : theme.secondaryText,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'S/${gym['priceMin']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter Tight',
                          ),
                        ),
                      ),
                      // Pin
                      Container(
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: gym['isOpen'] == true
                              ? theme.primary
                              : theme.secondaryText,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapBottomCards(BuildContext context, FlutterFlowTheme theme,
      List<Map<String, dynamic>> gyms) {
    if (gyms.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 160.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.primaryBackground.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 12.0),
        itemCount: gyms.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10.0),
        itemBuilder: (context, index) =>
            _buildMiniCard(context, theme, gyms[index]),
      ),
    );
  }

  Widget _buildMiniCard(BuildContext context, FlutterFlowTheme theme,
      Map<String, dynamic> gym) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 220.0,
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                bottomLeft: Radius.circular(12.0),
              ),
              child: Image.network(
                gym['imageUrl'] as String,
                width: 80.0,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80.0,
                  color: theme.tagBackground,
                  child: Icon(Icons.fitness_center_rounded,
                      color: theme.hintText, size: 28.0),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      gym['name'] as String,
                      style: theme.titleSmall.override(
                        fontFamily: 'Inter Tight',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: theme.ratingColor, size: 12.0),
                        const SizedBox(width: 2.0),
                        Text('${gym['rating']}',
                            style: theme.labelSmall.override(
                              fontFamily: 'Inter',
                              color: theme.primaryText,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(width: 4.0),
                        Container(
                          width: 4.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                              color: theme.hintText,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4.0),
                        Text(gym['distance'] as String,
                            style: theme.labelSmall
                                .override(fontFamily: 'Inter')),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'S/ ${gym['priceMin']}/mes',
                      style: theme.labelSmall.override(
                        fontFamily: 'Inter',
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LISTA GYMS (vista catálogo)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildGymList(BuildContext context, FlutterFlowTheme theme) {
    final gyms = _model.filteredGyms;

    if (gyms.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 56.0, color: theme.hintText),
            const SizedBox(height: 12.0),
            Text(
              'Sin resultados',
              style: theme.headlineSmall.override(
                  fontFamily: 'Inter Tight',
                  color: theme.secondaryText),
            ),
            const SizedBox(height: 4.0),
            Text(
              _model.selectedDistrict != 'Todos'
                  ? 'No hay gyms en ${_model.selectedDistrict} con esa búsqueda'
                  : 'Intenta otro término de búsqueda',
              style: theme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
      itemCount: gyms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12.0),
      itemBuilder: (context, index) =>
          _buildGymCard(context, theme, gyms[index]),
    );
  }

  Widget _buildGymCard(BuildContext context, FlutterFlowTheme theme,
      Map<String, dynamic> gym) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Stack(
                children: [
                  Image.network(
                    gym['imageUrl'] as String,
                    width: double.infinity,
                    height: 155.0,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 155.0,
                      color: theme.tagBackground,
                      child: Icon(Icons.fitness_center_rounded,
                          size: 44.0, color: theme.hintText),
                    ),
                  ),
                  // Badge abierto/cerrado
                  Positioned(
                    top: 10.0,
                    left: 10.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: gym['isOpen'] == true
                            ? theme.openColor
                            : theme.closedColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            gym['isOpen'] == true ? 'Abierto' : 'Cerrado',
                            style: theme.labelSmall.override(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Badge distrito
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        gym['district'] as String,
                        style: theme.labelSmall.override(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  14.0, 12.0, 14.0, 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          gym['name'] as String,
                          style: theme.titleSmall.override(
                            fontFamily: 'Inter Tight',
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: theme.ratingColor, size: 15.0),
                          const SizedBox(width: 2.0),
                          Text(
                            '${gym['rating']}',
                            style: theme.labelMedium.override(
                              fontFamily: 'Inter',
                              color: theme.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            '(${gym['reviewCount']})',
                            style: theme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 5.0),

                  // Dirección + distancia
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14.0, color: theme.distanceColor),
                      const SizedBox(width: 3.0),
                      Expanded(
                        child: Text(
                          gym['address'] as String,
                          style: theme.labelSmall.override(
                            fontFamily: 'Inter',
                            color: theme.distanceColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: theme.chipBackground,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.directions_walk_rounded,
                                size: 12.0, color: theme.chipText),
                            const SizedBox(width: 2.0),
                            Text(
                              gym['distance'] as String,
                              style: theme.labelSmall.override(
                                fontFamily: 'Inter',
                                color: theme.chipText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10.0),

                  // Tags
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: (gym['tags'] as List<String>).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: theme.tagBackground,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          tag,
                          style: theme.labelSmall.override(
                            fontFamily: 'Inter',
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12.0),

                  // Precio + botón contactar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Membresía desde',
                            style: theme.labelSmall.override(
                                fontFamily: 'Inter',
                                color: theme.secondaryText),
                          ),
                          Text(
                            'S/ ${gym['priceMin']} / mes',
                            style: theme.titleSmall.override(
                              fontFamily: 'Inter Tight',
                              color: theme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SKELETON LOADER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSkeletonList(BuildContext context, FlutterFlowTheme theme) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12.0),
      itemBuilder: (_, __) => _buildSkeletonCard(theme),
    );
  }

  Widget _buildSkeletonCard(FlutterFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(color: theme.shadowColor, blurRadius: 12.0,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 155.0,
            decoration: BoxDecoration(
              color: theme.tagBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(theme, width: 200, height: 14),
                const SizedBox(height: 8.0),
                _skeletonBox(theme, width: double.infinity, height: 10),
                const SizedBox(height: 6.0),
                _skeletonBox(theme, width: 140, height: 10),
                const SizedBox(height: 12.0),
                Row(children: [
                  _skeletonBox(theme, width: 60, height: 22),
                  const SizedBox(width: 6.0),
                  _skeletonBox(theme, width: 60, height: 22),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox(FlutterFlowTheme theme,
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.tagBackground,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BOTTOM NAV
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBottomNav(BuildContext context, FlutterFlowTheme theme) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Inicio'),
      _NavItem(icon: Icons.search_rounded, label: 'Buscar'),
      _NavItem(icon: Icons.map_rounded, label: 'Mapa'),
      _NavItem(icon: Icons.person_rounded, label: 'Perfil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.navBackground,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 20.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final selected = _navIndex == i;
              return GestureDetector(
                onTap: () {
                  safeSetState(() => _navIndex = i);
                  if (i == 2) {
                    safeSetState(() => _model.showMap = true);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 24.0,
                        color: selected
                            ? theme.navSelected
                            : theme.navUnselected,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        item.label,
                        style: theme.labelSmall.override(
                          fontFamily: 'Inter',
                          color: selected
                              ? theme.navSelected
                              : theme.navUnselected,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Helper classes ─────────────────────────────────────────────────────
class _NavItem {
  _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Cuadrícula de calles del mapa
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCDD8E3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Líneas horizontales
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Líneas verticales
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
