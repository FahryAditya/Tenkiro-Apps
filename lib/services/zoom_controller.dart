import 'package:flutter/material.dart';
import '../models/sky_coordinates.dart';

/// Zoom controller for Sky Map
/// Manages field of view (FOV) adjustments
class ZoomController {
  // FOV limits (in degrees)
  static const double minFOV = 20.0;  // Max zoom in
  static const double maxFOV = 120.0; // Max zoom out
  static const double defaultFOV = 60.0;
  
  // Current FOV
  double _horizontalFOV = defaultFOV;
  double _verticalFOV = defaultFOV * 0.75; // 4:3 aspect ratio
  
  // Zoom level (1.0 = default, 2.0 = 2x zoom, 0.5 = wide angle)
  double get zoomLevel => defaultFOV / _horizontalFOV;
  
  // Current FOV
  double get horizontalFOV => _horizontalFOV;
  double get verticalFOV => _verticalFOV;
  
  FieldOfView get fieldOfView => FieldOfView(
    horizontal: _horizontalFOV,
    vertical: _verticalFOV,
  );
  
  /// Set FOV directly
  void setFOV(double fov) {
    _horizontalFOV = fov.clamp(minFOV, maxFOV);
    _verticalFOV = _horizontalFOV * 0.75;
  }
  
  /// Zoom in (decrease FOV)
  void zoomIn({double step = 5.0}) {
    setFOV(_horizontalFOV - step);
  }
  
  /// Zoom out (increase FOV)
  void zoomOut({double step = 5.0}) {
    setFOV(_horizontalFOV + step);
  }
  
  /// Handle pinch gesture
  void handlePinch(double scale) {
    // Invert scale (pinch in = zoom in = smaller FOV)
    final newFOV = _horizontalFOV / scale;
    setFOV(newFOV);
  }
  
  /// Reset to default
  void reset() {
    setFOV(defaultFOV);
  }
  
  /// Get zoom level text
  String get zoomText {
    if (zoomLevel >= 2.0) return '${zoomLevel.toStringAsFixed(1)}x';
    if (zoomLevel >= 1.5) return '${zoomLevel.toStringAsFixed(1)}x';
    if (zoomLevel <= 0.5) return 'Wide';
    return '1.0x';
  }
  
  /// Get FOV description
  String get fovDescription {
    if (_horizontalFOV <= 30) return 'Telephoto';
    if (_horizontalFOV <= 50) return 'Normal';
    if (_horizontalFOV <= 80) return 'Wide';
    return 'Ultra Wide';
  }
}

/// Zoom controls widget
class ZoomControls extends StatelessWidget {
  final ZoomController controller;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;
  
  const ZoomControls({
    super.key,
    required this.controller,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.zoomText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Zoom in button
          _buildZoomButton(
            icon: Icons.add,
            onPressed: onZoomIn,
            tooltip: 'Zoom In',
          ),
          
          const SizedBox(height: 4),
          
          // Reset button
          _buildZoomButton(
            icon: Icons.my_location,
            onPressed: onReset,
            tooltip: 'Reset Zoom',
            size: 20,
          ),
          
          const SizedBox(height: 4),
          
          // Zoom out button
          _buildZoomButton(
            icon: Icons.remove,
            onPressed: onZoomOut,
            tooltip: 'Zoom Out',
          ),
        ],
      ),
    );
  }
  
  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    double size = 24,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: size,
          ),
        ),
      ),
    );
  }
}