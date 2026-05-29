import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/gymradar/components/bottom_nav/bottom_nav_widget.dart';
import '/gymradar/services/places_service.dart';
import 'home_model.dart';
export 'home_model.dart';

const LatLng _limaDefault = LatLng(-12.1550, -77.0100);

// Colores de marcadores por estado (abierto / cerrado / seleccionado)
const Color _kOpenColor = Color(0xFF22C55E); // verde: abierto
const Color _kClosedColor = Color(0xFF94A3B8); // gris: cerrado
const Color _kSelectedColor = Color(0xFFFF7A1A); // ámbar: seleccionado

// Google Maps Night Mode style
const String _kDarkMapStyle =
    '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},'
    '{"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},'
    '{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},'
    '{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},'
    '{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},'
    '{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},'
    '{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},'
    '{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},'
    '{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},'
    '{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},'
    '{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},'
    '{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},'
    '{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},'
    '{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},'
    '{"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},'
    '{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},'
    '{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},'
    '{"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}]';

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
  GoogleMapController? _googleMapController;

  LatLng? _userPosition;
  bool _locationGranted = false;
  bool _isLoading = true;
  StreamSubscription<Position>? _positionStream;

  Map<String, dynamic>? _selectedGym;
  double _searchRadiusKm = 1.0;

  static const List<int> _radiusOptions = [1, 2, 3, 5];
  static const double _maxRadiusKm = 5.0;

  // Iconos de marcador custom (pesa) por estado
  BitmapDescriptor? _mkOpen;
  BitmapDescriptor? _mkClosed;
  BitmapDescriptor? _mkSelected;

  // Overlays cacheados (evita recalcular en cada rebuild → mapa más fluido)
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  // Carga de gimnasios reales (Google Places)
  bool _loadingPlaces = false;
  Timer? _fetchDebounce;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _buildMarkerIcons();
      _initLocation();
    });
  }

  @override
  void dispose() {
    _fetchDebounce?.cancel();
    _positionStream?.cancel();
    _googleMapController?.dispose();
    _model.dispose();
    super.dispose();
  }

  // ── Location ───────────────────────────────────────────────────

  Future<void> _initLocation() async {
    // Muestra el mapa de Lima inmediatamente
    setState(() => _isLoading = false);
    _updateDistances(_limaDefault);

    // Sin GPS aún: intenta traer gyms reales alrededor de Lima por defecto.
    _scheduleFetchPlaces();

    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      _locationGranted = true;
      await _fetchPosition();
      _startStream();
    } else {
      setState(() => _locationGranted = false);
    }
  }

  // ── Gimnasios reales (Google Places) ───────────────────────────

  void _scheduleFetchPlaces() {
    _fetchDebounce?.cancel();
    _fetchDebounce =
        Timer(const Duration(milliseconds: 450), _fetchPlaces);
  }

  Future<void> _fetchPlaces() async {
    final center = _userPosition ?? _limaDefault;
    if (mounted) setState(() => _loadingPlaces = true);
    try {
      final gyms = await PlacesService.nearbyGyms(
        lat: center.latitude,
        lng: center.longitude,
        radiusMeters: _searchRadiusKm * 1000,
      );
      FFAppState().setAllGyms(gyms);
      _updateDistances(center); // recalcula distancias + overlays
    } catch (_) {
      // Falla de red o Places no habilitado: se mantiene el catálogo actual.
    } finally {
      if (mounted) setState(() => _loadingPlaces = false);
    }
  }

  Future<void> _fetchPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _applyPosition(pos);
    } catch (_) {
      _updateDistances(_limaDefault);
    }
  }

  void _startStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen(_applyPosition);
  }

  void _applyPosition(Position pos) {
    final latlng = LatLng(pos.latitude, pos.longitude);
    FFAppState().update(() {
      FFAppState().userLat = pos.latitude;
      FFAppState().userLng = pos.longitude;
    });
    final firstFix = _userPosition == null;
    setState(() => _userPosition = latlng);
    _updateDistances(latlng);
    // Pan to user only on first GPS fix
    if (firstFix) {
      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: latlng, zoom: _zoomForRadius(_searchRadiusKm)),
        ),
      );
      // Ya tenemos ubicación real: trae gyms alrededor del usuario.
      _scheduleFetchPlaces();
    }
  }

  void _updateDistances(LatLng from) {
    final gyms = FFAppState().allGyms;
    for (final gym in gyms) {
      final d = _haversineKm(
        from.latitude,
        from.longitude,
        gym['lat'] as double,
        gym['lng'] as double,
      );
      gym['distance'] = '${d.toStringAsFixed(1)} km';
    }
    gyms.sort((a, b) {
      final da = _haversineKm(from.latitude, from.longitude,
          a['lat'] as double, a['lng'] as double);
      final db = _haversineKm(from.latitude, from.longitude,
          b['lat'] as double, b['lng'] as double);
      return da.compareTo(db);
    });
    _rebuildOverlays();
  }

  // Recalcula marcadores y círculo una sola vez por cambio relevante.
  void _rebuildOverlays() {
    _markers = _buildMarkers(FFAppState().allGyms);
    _circles = _buildRadiusCircle();
    if (mounted) setState(() {});
  }

  void _selectGym(Map<String, dynamic>? gym) {
    _selectedGym = gym;
    _rebuildOverlays();
  }

  // Distancia (km) al gimnasio más cercano, o null si no hay datos/GPS.
  double? _nearestKm() {
    final from = _userPosition;
    final gyms = FFAppState().allGyms;
    if (from == null || gyms.isEmpty) return null;
    double best = double.infinity;
    for (final g in gyms) {
      final d = _haversineKm(
          from.latitude, from.longitude, g['lat'] as double, g['lng'] as double);
      if (d < best) best = d;
    }
    return best;
  }

  int _countInRadius(List<dynamic> gyms) {
    final from = _userPosition;
    if (from == null) return gyms.length;
    return gyms.where((g) {
      final d = _haversineKm(
          from.latitude, from.longitude, g['lat'] as double, g['lng'] as double);
      return d <= _searchRadiusKm;
    }).length;
  }

  // Zoom nivel calle ajustado al radio (mayor radio → un poco más lejos).
  double _zoomForRadius(double r) => 15.8 - (math.log(r) / math.ln2);

  void _onRadiusChanged(double newRadius) {
    _searchRadiusKm = newRadius;
    _rebuildOverlays();
    _scheduleFetchPlaces(); // re-busca gyms en el nuevo radio
    final target = _userPosition ?? _limaDefault;
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: _zoomForRadius(newRadius)),
      ),
    );
  }

  void _recenter() {
    final target = _userPosition ?? _limaDefault;
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: target, zoom: _zoomForRadius(_searchRadiusKm)),
      ),
    );
  }

  double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double d) => d * math.pi / 180;

  // Genera los bitmaps de marcador (pin con pesa) una sola vez.
  Future<void> _buildMarkerIcons() async {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final open = await _pinBitmap(_kOpenColor, dpr);
    final closed = await _pinBitmap(_kClosedColor, dpr);
    final selected = await _pinBitmap(_kSelectedColor, dpr, scale: 1.25);
    if (!mounted) return;
    _mkOpen = open;
    _mkClosed = closed;
    _mkSelected = selected;
    _rebuildOverlays();
  }

  // Dibuja un pin tipo gota con un glifo de pesa centrado.
  Future<BitmapDescriptor> _pinBitmap(Color color, double dpr,
      {double scale = 1.0}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = 44.0 * dpr * scale;
    final h = 56.0 * dpr * scale;
    final cx = w / 2;
    final r = 18.0 * dpr * scale;
    final cy = r + 3 * dpr;

    // Sombra
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.30)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * dpr);
    canvas.drawCircle(Offset(cx, cy + 2 * dpr), r, shadow);

    // Cuerpo (gota): círculo + puntero inferior
    final body = Paint()..color = color;
    final tip = Path()
      ..moveTo(cx - r * 0.55, cy + r * 0.55)
      ..lineTo(cx, h)
      ..lineTo(cx + r * 0.55, cy + r * 0.55)
      ..close();
    canvas.drawPath(tip, body);
    canvas.drawCircle(Offset(cx, cy), r, body);

    // Borde blanco
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * dpr
      ..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r, border);

    // Glifo de pesa
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);
    tp.text = TextSpan(
      text: String.fromCharCode(Icons.fitness_center.codePoint),
      style: TextStyle(
        fontSize: 20 * dpr * scale,
        fontFamily: Icons.fitness_center.fontFamily,
        package: Icons.fitness_center.fontPackage,
        color: Colors.white,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    final img = await recorder.endRecording().toImage(w.ceil(), h.ceil());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Set<Marker> _buildMarkers(List<dynamic> gyms) {
    final from = _userPosition;
    // Sin GPS: muestra todos los gyms para que el usuario vea algo
    final filtered = from == null
        ? gyms
        : gyms.where((gym) {
            final d = _haversineKm(
              from.latitude, from.longitude,
              gym['lat'] as double, gym['lng'] as double,
            );
            return d <= _searchRadiusKm;
          }).toList();
    return filtered.map((gym) {
      final open = gym['isOpen'] as bool;
      final isSelected =
          _selectedGym != null && _selectedGym!['id'] == gym['id'];
      final icon = isSelected
          ? _mkSelected
          : open
              ? _mkOpen
              : _mkClosed;
      return Marker(
        markerId: MarkerId(gym['id'] as String),
        position: LatLng(gym['lat'] as double, gym['lng'] as double),
        // Punta del pin sobre la coordenada
        anchor: const Offset(0.5, 1.0),
        zIndexInt: isSelected ? 2 : (open ? 1 : 0),
        icon: icon ??
            BitmapDescriptor.defaultMarkerWithHue(open
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow.noText,
        onTap: () => _selectGym(gym),
      );
    }).toSet();
  }

  Set<Circle> _buildRadiusCircle() {
    // Muestra el círculo solo cuando tenemos GPS real
    if (_userPosition == null) return {};
    final center = _userPosition!;
    return {
      Circle(
        circleId: const CircleId('search_radius'),
        center: center,
        radius: _searchRadiusKm * 1000,
        fillColor: Colors.blue.withOpacity(0.07),
        strokeColor: Colors.blue.withOpacity(0.45),
        strokeWidth: 2,
      ),
    };
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final cs = Theme.of(context).colorScheme;
    final gyms = FFAppState().allGyms;
    final center = _userPosition ?? _limaDefault;
    final inRadius = _countInRadius(gyms);
    final hasSelection = _selectedGym != null;
    final showEmptyHint = !hasSelection && _locationGranted && inRadius == 0;

    return Scaffold(
      key: scaffoldKey,
      drawer: _AppDrawer(),
      body: _isLoading
          ? Container(
              color: const Color(0xFF121212),
              child: const Center(child: CircularProgressIndicator()),
            )
          : Stack(
              children: [
                // ── Google Maps ─────────────────────────────────
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: _zoomForRadius(_searchRadiusKm),
                  ),
                  myLocationEnabled: _locationGranted,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  padding: EdgeInsets.only(
                      bottom: hasSelection
                          ? 340
                          : showEmptyHint
                              ? 96
                              : 80),
                  style: _kDarkMapStyle,
                  markers: _markers,
                  circles: _circles,
                  onMapCreated: (controller) =>
                      _googleMapController = controller,
                  onTap: (_) => _selectGym(null),
                ),

                // ── Cabecera: búsqueda + radio ───────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Barra de búsqueda flotante
                          _SearchHeader(
                            onMenu: () =>
                                scaffoldKey.currentState?.openDrawer(),
                            onSearch: () => context.go('/search'),
                          ),
                          const SizedBox(height: 10),
                          // Selector de radio + conteo
                          _RadiusSelector(
                            value: _searchRadiusKm,
                            count: inRadius,
                            loading: _loadingPlaces,
                            onChanged: _onRadiusChanged,
                          ),
                          // Banner sin permiso
                          if (!_locationGranted) ...[
                            const SizedBox(height: 8),
                            _LocationBanner(onEnable: () => openAppSettings()),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Botones zoom + recenter ──────────────────────
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  right: 16,
                  bottom: hasSelection
                      ? 360
                      : showEmptyHint
                          ? 96
                          : 24,
                  child: Column(
                    children: [
                      if (_locationGranted) ...[
                        _MapButton(
                          icon: Icons.my_location_rounded,
                          color: cs.primary,
                          tooltip: 'Centrar en mi ubicación',
                          onTap: _recenter,
                        ),
                        const SizedBox(height: 10),
                      ],
                      _MapButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Acercar',
                        onTap: () => _googleMapController
                            ?.animateCamera(CameraUpdate.zoomIn()),
                      ),
                      const SizedBox(height: 6),
                      _MapButton(
                        icon: Icons.remove_rounded,
                        tooltip: 'Alejar',
                        onTap: () => _googleMapController
                            ?.animateCamera(CameraUpdate.zoomOut()),
                      ),
                    ],
                  ),
                ),

                // ── Pista de radio vacío ─────────────────────────
                if (showEmptyHint)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _EmptyRadiusHint(
                      nearestKm: _nearestKm(),
                      maxRadiusKm: _maxRadiusKm,
                      onExpand: () {
                        final n = _nearestKm();
                        if (n == null) return;
                        final next = _radiusOptions
                            .map((e) => e.toDouble())
                            .firstWhere((r) => r >= n,
                                orElse: () => _maxRadiusKm);
                        _onRadiusChanged(next);
                      },
                    ),
                  ),

                // ── Quick card gym seleccionado ──────────────────
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: hasSelection
                        ? _GymQuickCard(
                            key: ValueKey(_selectedGym!['id']),
                            gym: _selectedGym!,
                            onClose: () => _selectGym(null),
                            onOpen: () =>
                                context.go('/gym/${_selectedGym!['id']}'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavWidget(current: 0),
    );
  }
}

// ── Cabecera de búsqueda ────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.onMenu, required this.onSearch});
  final VoidCallback onMenu;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _FloatingIconButton(
          icon: Icons.menu_rounded,
          tooltip: 'Menú',
          onPressed: onMenu,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            button: true,
            label: 'Buscar gimnasios',
            child: Material(
              color: cs.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(26),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.3),
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: onSearch,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(Icons.radar_rounded,
                          color: cs.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Buscar gimnasios, distritos…',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.search_rounded,
                          color: cs.onSurfaceVariant, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Selector de radio ───────────────────────────────────────────

class _RadiusSelector extends StatelessWidget {
  const _RadiusSelector({
    required this.value,
    required this.count,
    required this.loading,
    required this.onChanged,
  });
  final double value;
  final int count;
  final bool loading;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _HomeWidgetState._radiusOptions.map((km) {
                final selected = value == km.toDouble();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: 'Radio $km kilómetros',
                    child: GestureDetector(
                      onTap: () => onChanged(km.toDouble()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 36,
                        alignment: Alignment.center,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: selected
                              ? cs.primary
                              : cs.surface.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          border: selected
                              ? null
                              : Border.all(
                                  color: cs.outline.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Text(
                          '$km km',
                          style: TextStyle(
                            color:
                                selected ? Colors.white : cs.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Conteo de resultados dentro del radio
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outline.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: cs.primary),
                )
              else ...[
                Icon(Icons.place_rounded, size: 15, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Banner de ubicación ─────────────────────────────────────────

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.onEnable});
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade800.withOpacity(0.96),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Ubicación desactivada. Mostrando Lima.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: onEnable,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text('Activar',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ── Pista de radio vacío ────────────────────────────────────────

class _EmptyRadiusHint extends StatelessWidget {
  const _EmptyRadiusHint({
    required this.nearestKm,
    required this.maxRadiusKm,
    required this.onExpand,
  });
  final double? nearestKm;
  final double maxRadiusKm;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final n = nearestKm;
    final reachable = n != null && n <= maxRadiusKm;

    final String message;
    if (n == null) {
      message = 'No hay gimnasios en este radio.';
    } else if (reachable) {
      message = 'El más cercano está a ${n.toStringAsFixed(1)} km.';
    } else {
      message =
          'Sin gimnasios cerca (máx ${maxRadiusKm.toStringAsFixed(0)} km).';
    }

    return Material(
      color: cs.surface.withOpacity(0.96),
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Icon(Icons.search_off_rounded,
                color: cs.onSurfaceVariant, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            if (reachable)
              TextButton(
                onPressed: onExpand,
                child: const Text('Ampliar',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────

class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton(
      {required this.icon, required this.onPressed, this.tooltip});
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: cs.onSurface, size: 24),
          ),
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton(
      {required this.icon, required this.onTap, this.color, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface.withOpacity(0.96),
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 24, color: color ?? cs.onSurface),
          ),
        ),
      ),
    );
  }
}

// ── Drawer ──────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = FFAppState();
    final isGuest = s.isGuest;
    final name =
        isGuest ? 'Invitado' : (s.userName.isEmpty ? 'Usuario' : s.userName);
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
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
                            Text('GymRadar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: Icon(
                          isGuest ? Icons.person_outline : Icons.person,
                          color: Colors.white,
                          size: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(email,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context),
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
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${s.compareIds.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
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
                  fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              if (!isGuest) FFAppState().logout();
              context.go('/login');
            },
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('GymRadar v1.0',
                  style:
                      TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Card ──────────────────────────────────────────────────

class _GymQuickCard extends StatelessWidget {
  const _GymQuickCard({
    super.key,
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8))
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
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              // Hero
              Stack(
                children: [
                  Image.network(
                    gym['imageUrl'] as String,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        height: 130,
                        color: cs.surfaceContainerHighest,
                        child: const Icon(Icons.fitness_center, size: 48)),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.75)
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
                        color:
                            (open ? Colors.green : Colors.red).withOpacity(0.9),
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
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(open ? 'Abierto' : 'Cerrado',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
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
                              Shadow(blurRadius: 6, color: Colors.black54)
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
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                          label: (gym['priceMin'] == 0 &&
                                  gym['priceMax'] == 0)
                              ? 'Consultar'
                              : 'S/. ${gym['priceMin']}-${gym['priceMax']}',
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(tags[i],
                              style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
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
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
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
