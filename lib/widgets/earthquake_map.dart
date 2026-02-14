import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/earthquake.dart';
import 'dart:math' as math;

class EarthquakeMap extends StatefulWidget {
  final Earthquake earthquake;
  final double height;

  const EarthquakeMap({
    super.key,
    required this.earthquake,
    this.height = 300,
  });

  @override
  State<EarthquakeMap> createState() => _EarthquakeMapState();
}

class _EarthquakeMapState extends State<EarthquakeMap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final epicenterLocation = LatLng(
      widget.earthquake.epicenter.latitude,
      widget.earthquake.epicenter.longitude,
    );

    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: epicenterLocation,
          initialZoom: _calculateZoomLevel(),
          minZoom: 5,
          maxZoom: 18,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          // OpenStreetMap tile layer
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tenkiro.app',
            maxZoom: 19,
            tileProvider: NetworkTileProvider(),
          ),
          
          // Impact radius circles
          CircleLayer(
            circles: [
              // Inner circle (strong impact)
              CircleMarker(
                point: epicenterLocation,
                color: widget.earthquake.alertColor.withOpacity(0.3),
                borderColor: widget.earthquake.alertColor,
                borderStrokeWidth: 2,
                radius: _getRadiusInMeters(widget.earthquake.impactRadius) / 2,
                useRadiusInMeter: true,
              ),
              // Outer circle (felt area)
              CircleMarker(
                point: epicenterLocation,
                color: widget.earthquake.alertColor.withOpacity(0.15),
                borderColor: widget.earthquake.alertColor.withOpacity(0.5),
                borderStrokeWidth: 1,
                radius: _getRadiusInMeters(widget.earthquake.impactRadius),
                useRadiusInMeter: true,
              ),
            ],
          ),
          
          // Epicenter marker
          MarkerLayer(
            markers: [
              Marker(
                point: epicenterLocation,
                width: 80,
                height: 80,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing effect
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.earthquake.alertColor.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Main marker
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: widget.earthquake.alertColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // Magnitude label
                    Positioned(
                      bottom: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: widget.earthquake.alertColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'M${widget.earthquake.magnitude.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: widget.earthquake.alertColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Attribution
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomRight,
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateZoomLevel() {
    final magnitude = widget.earthquake.magnitude;
    if (magnitude >= 7.0) return 7.0;
    if (magnitude >= 6.0) return 8.0;
    if (magnitude >= 5.0) return 9.0;
    return 10.0;
  }

  double _getRadiusInMeters(double radiusKm) {
    return radiusKm * 1000; // Convert km to meters
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

// Custom network tile provider with error handling
class NetworkTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = options.urlTemplate!
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString());

    return NetworkImage(url);
  }
}