// COMPLETE INTEGRATED SKY MAP PAGE
// Copy file ini untuk replace sky_map_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tenkiro/services/star_catalog_services.dart';
import 'dart:async';
import 'models/sky_coordinates.dart';
import 'models/celestial-object.dart';
import 'services/sensor_service.dart';
import 'services/astronomy_engine.dart';
import 'services/solar_calculator.dart';
import 'services/lunar_calculator.dart';
import 'services/planetary_calculator.dart';

import 'painters/sky_background_painter.dart';
import 'painters/celestial_objects_painter.dart';
import 'painters/simple_compass_painter.dart';
import 'services/zoom_controller.dart';
import 'services/time_controller.dart';

class SkyMapPage extends StatefulWidget {
  const SkyMapPage({super.key});

  @override
  State<SkyMapPage> createState() => _SkyMapPageState();
}

class _SkyMapPageState extends State<SkyMapPage> {
  final _sensorService = SensorService();
  final _starCatalog = StarCatalogService();
  late ZoomController _zoomController;
  late TimeController _timeController;
  
  DeviceOrientation _deviceOrientation = const DeviceOrientation(azimuth: 0, pitch: 0, roll: 0);
  GeographicCoordinates _location = const GeographicCoordinates(latitude: -6.2088, longitude: 106.8456);
  DateTime _currentTime = DateTime.now();
  List<PositionedCelestialObject> _visibleObjects = [];
  
  bool _isLoading = true;
  bool _sensorsAvailable = false;
  bool _showLabels = true;
  bool _showPlanets = true;
  bool _showCompass = true;
  double _sunAltitude = 0;
  
  Timer? _updateTimer;
  StreamSubscription? _orientationSubscription;
  FieldOfView get _fieldOfView => _zoomController.fieldOfView;
  
  @override
  void initState() {
    super.initState();
    _zoomController = ZoomController();
    _timeController = TimeController(
      onTimeChanged: () {
        setState(() {
          _currentTime = _timeController.currentTime;
          _updateCelestialObjects();
        });
      },
    );
    _initialize();
  }
  
  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    _sensorsAvailable = await SensorService.areSensorsAvailable();
    await _getLocation();
    await _starCatalog.loadCatalog();
    
    if (_sensorsAvailable) {
      await _sensorService.startListening();
      _orientationSubscription = _sensorService.orientationStream.listen((orientation) {
        setState(() => _deviceOrientation = orientation);
      });
    }
    
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeController.isRealTime) _updateCelestialObjects();
    });
    
    _updateCelestialObjects();
    setState(() => _isLoading = false);
  }
  
  Future<void> _getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) await Geolocator.requestPermission();
      final position = await Geolocator.getCurrentPosition();
      setState(() => _location = GeographicCoordinates(latitude: position.latitude, longitude: position.longitude, elevation: position.altitude));
    } catch (e) {}
  }
  
  void _updateCelestialObjects() {
    _currentTime = _timeController.currentTime;
    final lst = AstronomyEngine.calculateLST(_currentTime, _location.longitude);
    final objects = <PositionedCelestialObject>[];
    
    final sun = SolarCalculator.calculateSun(_currentTime);
    final sunH = AstronomyEngine.equatorialToHorizontal(
      rightAscension: sun.equatorial.rightAscension, declination: sun.equatorial.declination,
      latitude: _location.latitude, localSiderealTime: lst);
    _sunAltitude = sunH.altitude;
    objects.add(PositionedCelestialObject(object: sun, horizontal: sunH, calculatedAt: _currentTime));
    
    final moon = LunarCalculator.calculateMoon(_currentTime);
    final moonH = AstronomyEngine.equatorialToHorizontal(
      rightAscension: moon.equatorial.rightAscension, declination: moon.equatorial.declination,
      latitude: _location.latitude, localSiderealTime: lst);
    objects.add(PositionedCelestialObject(object: moon, horizontal: moonH, calculatedAt: _currentTime));
    
    if (_showPlanets) {
      final planets = PlanetaryCalculator.getVisiblePlanets(dateTime: _currentTime, latitude: _location.latitude, longitude: _location.longitude, includeOuterPlanets: false);
      for (final planet in planets) {
        final h = AstronomyEngine.equatorialToHorizontal(
          rightAscension: planet.equatorial.rightAscension, declination: planet.equatorial.declination,
          latitude: _location.latitude, localSiderealTime: lst);
        objects.add(PositionedCelestialObject(object: planet, horizontal: h, calculatedAt: _currentTime));
      }
    }
    
    if (_sunAltitude < -6) {
      final brightStars = _starCatalog.getBrightestStars(200);
      for (final star in brightStars) {
        final h = AstronomyEngine.equatorialToHorizontal(
          rightAscension: star.ra, declination: star.dec,
          latitude: _location.latitude, localSiderealTime: lst);
        if (h.altitude > 0) {
          objects.add(PositionedCelestialObject(
        object: Star(id: star.id, name: star.name,
              equatorial: EquatorialCoordinates(rightAscension: star.ra, declination: star.dec),
          magnitude: star.magnitude,
          spectralType: star.spectralType, constellation: star.constellation),
            horizontal: h, calculatedAt: _currentTime));
        }
      }
    }
    setState(() => _visibleObjects = objects);
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(backgroundColor: Colors.black, body: const Center(child: CircularProgressIndicator(color: Colors.white)));
    if (!_sensorsAvailable) return _buildNoSensorsScreen();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onScaleUpdate: (d) { if (d.scale != 1.0) setState(() => _zoomController.handlePinch(d.scale)); },
        child: Stack(
          children: [
            CustomPaint(painter: SkyBackgroundPainter(sunAltitude: _sunAltitude, currentTime: _currentTime), child: Container()),
            CustomPaint(painter: CelestialObjectsPainter(objects: _visibleObjects, deviceOrientation: _deviceOrientation, fieldOfView: _fieldOfView, showLabels: _showLabels), child: Container()),
            if (_showCompass) CustomPaint(painter: SimpleCompassPainter(deviceAzimuth: _deviceOrientation.azimuth), child: Container()),
            SafeArea(child: Column(children: [
              _buildTopBar(), const Spacer(),
              Padding(padding: const EdgeInsets.all(16), child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildHamburgerMenu(),
                  ZoomControls(controller: _zoomController,
                    onZoomIn: () => setState(() => _zoomController.zoomIn()),
                    onZoomOut: () => setState(() => _zoomController.zoomOut()),
                    onReset: () => setState(() => _zoomController.reset())),
                ])),
              const SizedBox(height: 16), _buildInfoPanel(), const SizedBox(height: 16),
            ])),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoSensorsScreen() => Scaffold(
    backgroundColor: Colors.black,
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.sensors_off, size: 64, color: Colors.white54),
        const SizedBox(height: 16),
        const Text('Sensor Tidak Tersedia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Perangkat Anda tidak memiliki sensor yang diperlukan', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali')),
      ],
    ))),
  );
  
  Widget _buildTopBar() => Container(padding: const EdgeInsets.all(16), child: Row(children: [
    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
    const SizedBox(width: 8),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Peta Langit 3D', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
      Text('${_visibleObjects.length} objek terlihat', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
    ])),
    IconButton(icon: Icon(_showLabels ? Icons.label : Icons.label_off, color: Colors.white), onPressed: () => setState(() => _showLabels = !_showLabels)),
    IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _updateCelestialObjects),
  ]));
  
  Widget _buildHamburgerMenu() => Material(color: Colors.transparent, child: InkWell(
    onTap: _showMenuOptions, borderRadius: BorderRadius.circular(12),
    child: Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white30)),
      child: const Icon(Icons.menu, color: Colors.white, size: 28))));
  
  void _showMenuOptions() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (c) => Container(
      decoration: const BoxDecoration(color: Color(0xFF1A2332), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top: 12, bottom: 20), width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8), child: Row(children: [
          Icon(Icons.settings, color: Colors.white, size: 24), SizedBox(width: 12),
          Text('Pengaturan Peta Langit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))])),
        const Divider(color: Colors.white30, height: 32),
        _buildMenuItem(icon: Icons.access_time, title: 'Kontrol Waktu',
          subtitle: _timeController.isRealTime ? 'Real-time • ${_timeController.formattedTime}' : 'Simulasi • ${_timeController.formattedTime}',
          color: Colors.cyan, onTap: () { Navigator.pop(c); _showTimeControl(); }),
        const Divider(color: Colors.white10, height: 1, indent: 80, endIndent: 24),
        _buildMenuItem(icon: _showCompass ? Icons.explore : Icons.explore_off, title: 'Kompas',
          subtitle: _showCompass ? 'Tampilkan' : 'Sembunyikan', color: Colors.green,
          onTap: () { Navigator.pop(c); setState(() => _showCompass = !_showCompass); }),
        const Divider(color: Colors.white10, height: 1, indent: 80, endIndent: 24),
        _buildMenuItem(icon: _showPlanets ? Icons.public : Icons.public_off, title: 'Planet',
          subtitle: _showPlanets ? 'Tampilkan' : 'Sembunyikan', color: Colors.orange,
          onTap: () { Navigator.pop(c); setState(() { _showPlanets = !_showPlanets; _updateCelestialObjects(); }); }),
        const Divider(color: Colors.white10, height: 1, indent: 80, endIndent: 24),
        _buildMenuItem(icon: Icons.zoom_in, title: 'Zoom',
          subtitle: '${_zoomController.zoomText} • ${_zoomController.fovDescription}',
          color: Colors.purple, onTap: () => Navigator.pop(c)),
        const SizedBox(height: 24),
      ])));
  }
  
  Widget _buildMenuItem({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) => InkWell(
    onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
      ])),
      Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
    ])));
  
  void _showTimeControl() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (c) => TimeControlPanel(controller: _timeController, onUpdate: () => setState(() => _updateCelestialObjects())));
  }
  
  Widget _buildInfoPanel() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _buildInfoItem('Arah', '${_deviceOrientation.azimuth.toStringAsFixed(0)}°'),
        _buildInfoItem('Ketinggian', '${_deviceOrientation.pitch.toStringAsFixed(0)}°'),
        _buildInfoItem('Zoom', _zoomController.zoomText),
      ]),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _buildInfoItem('Waktu', _timeController.timeOfDayDescription),
        _buildInfoItem('Objek', '${_visibleObjects.length}'),
        _buildInfoItem('FOV', '${_fieldOfView.horizontal.toStringAsFixed(0)}°'),
      ]),
    ]));
  
  Widget _buildInfoItem(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
  ]);
  
  @override
  void dispose() {
    _sensorService.dispose();
    _updateTimer?.cancel();
    _orientationSubscription?.cancel();
    _timeController.dispose();
    super.dispose();
  }
}