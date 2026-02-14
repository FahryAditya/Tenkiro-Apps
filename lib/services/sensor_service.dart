import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sky_coordinates.dart';

/// Sensor service for device orientation
/// Combines magnetometer, accelerometer, and gyroscope
class SensorService {
  // Streams
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  
  // Output stream
  final _orientationController = StreamController<DeviceOrientation>.broadcast();
  Stream<DeviceOrientation> get orientationStream => _orientationController.stream;
  
  // Filtered values (low-pass filter)
  double _filteredAzimuth = 0;
  double _filteredPitch = 0;
  double _filteredRoll = 0;
  
  // Latest raw values
  double _rawAzimuth = 0;
  double _rawPitch = 0;
  double _rawRoll = 0;
  
  // Magnetometer values
  double _magX = 0;
  double _magY = 0;
  double _magZ = 0;
  
  // Accelerometer values
  double _accelX = 0;
  double _accelY = 0;
  double _accelZ = 0;
  
  // Gyroscope integration
  double _gyroAzimuth = 0;
  DateTime _lastGyroUpdate = DateTime.now();
  
  // Filter parameter (0-1, lower = smoother but slower)
  double _alpha = 0.1;
  
  // Calibration offset
  double _azimuthOffset = 0;
  
  bool _isListening = false;
  
  /// Start listening to sensors
  Future<void> startListening() async {
    if (_isListening) return;
    
    _isListening = true;
    
    // Subscribe to magnetometer (compass)
    _magnetometerSubscription = magnetometerEvents.listen((event) {
      _magX = event.x;
      _magY = event.y;
      _magZ = event.z;
      _updateOrientation();
    });
    
    // Subscribe to accelerometer (tilt)
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      _accelX = event.x;
      _accelY = event.y;
      _accelZ = event.z;
      _updateOrientation();
    });
    
    // Subscribe to gyroscope (smooth rotation)
    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      final now = DateTime.now();
      final dt = now.difference(_lastGyroUpdate).inMicroseconds / 1e6;
      _lastGyroUpdate = now;
      
      // Integrate gyroscope z-axis for azimuth
      _gyroAzimuth += event.z * dt * 180 / math.pi;
      _gyroAzimuth = _gyroAzimuth % 360;
      if (_gyroAzimuth < 0) _gyroAzimuth += 360;
    });
  }
  
  /// Stop listening to sensors
  void stopListening() {
    _magnetometerSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _isListening = false;
  }
  
  /// Update orientation from sensor data
  void _updateOrientation() {
    // Calculate azimuth from magnetometer
    _rawAzimuth = _calculateAzimuth(_magX, _magY, _magZ, _accelX, _accelY, _accelZ);
    
    // Calculate pitch and roll from accelerometer
    _rawPitch = _calculatePitch(_accelX, _accelY, _accelZ);
    _rawRoll = _calculateRoll(_accelX, _accelY, _accelZ);
    
    // Apply low-pass filter
    _filteredAzimuth = _applyFilter(_filteredAzimuth, _rawAzimuth);
    _filteredPitch = _applyFilter(_filteredPitch, _rawPitch);
    _filteredRoll = _applyFilter(_filteredRoll, _rawRoll);
    
    // Emit orientation
    _orientationController.add(DeviceOrientation(
      azimuth: (_filteredAzimuth + _azimuthOffset) % 360,
      pitch: _filteredPitch,
      roll: _filteredRoll,
    ));
  }
  
  /// Calculate azimuth (compass direction) from magnetometer
  /// Compensated for device tilt using accelerometer
  double _calculateAzimuth(
    double magX, double magY, double magZ,
    double accelX, double accelY, double accelZ,
  ) {
    // Normalize accelerometer
    final norm = math.sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
    if (norm == 0) return 0;
    
    final ax = accelX / norm;
    final ay = accelY / norm;
    final az = accelZ / norm;
    
    // Calculate pitch and roll
    final pitch = math.asin(-ax);
    final roll = math.atan2(ay, az);
    
    // Tilt compensation
    final magXComp = magX * math.cos(pitch) + 
                     magZ * math.sin(pitch);
    final magYComp = magX * math.sin(roll) * math.sin(pitch) +
                     magY * math.cos(roll) -
                     magZ * math.sin(roll) * math.cos(pitch);
    
    // Calculate azimuth
    var azimuth = math.atan2(magYComp, magXComp) * 180 / math.pi;
    
    // Normalize to 0-360
    azimuth = (azimuth + 360) % 360;
    
    return azimuth;
  }
  
  /// Calculate pitch (up/down tilt) from accelerometer
  double _calculatePitch(double x, double y, double z) {
    // Pitch = arctan(-x / sqrt(y^2 + z^2))
    final pitch = math.atan2(
      -x,
      math.sqrt(y * y + z * z)
    ) * 180 / math.pi;
    
    return pitch;
  }
  
  /// Calculate roll (left/right tilt) from accelerometer
  double _calculateRoll(double x, double y, double z) {
    // Roll = arctan(y / z)
    final roll = math.atan2(y, z) * 180 / math.pi;
    
    return roll;
  }
  
  /// Apply low-pass filter for smooth values
  double _applyFilter(double oldValue, double newValue) {
    return _alpha * newValue + (1 - _alpha) * oldValue;
  }
  
  /// Set filter strength (0-1)
  /// 0 = very smooth but slow
  /// 1 = very responsive but jittery
  void setFilterStrength(double alpha) {
    _alpha = alpha.clamp(0.0, 1.0);
  }
  
  /// Calibrate compass
  /// Call this when device is pointing North
  void calibrateNorth() {
    _azimuthOffset = -_filteredAzimuth;
  }
  
  /// Reset calibration
  void resetCalibration() {
    _azimuthOffset = 0;
  }
  
  /// Get current orientation (latest value)
  DeviceOrientation get currentOrientation {
    return DeviceOrientation(
      azimuth: (_filteredAzimuth + _azimuthOffset) % 360,
      pitch: _filteredPitch,
      roll: _filteredRoll,
    );
  }
  
  /// Check if sensors are available
  static Future<bool> areSensorsAvailable() async {
    try {
      // Try to read from each sensor
      await magnetometerEvents.first.timeout(const Duration(seconds: 1));
      await accelerometerEvents.first.timeout(const Duration(seconds: 1));
      await gyroscopeEvents.first.timeout(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose resources
  void dispose() {
    stopListening();
    _orientationController.close();
  }
}

/// Sensor calibration helper
class SensorCalibration {
  /// Guide user through figure-8 calibration
  static String getCalibrationInstructions() {
    return '''
Kalibrasi Kompas:
1. Pegang HP horizontal (layar menghadap atas)
2. Gerakkan HP membentuk angka 8 di udara
3. Ulangi 3-4 kali
4. Arahkan HP ke Utara dan tekan "Kalibrasi"

Tips:
- Jauh dari benda logam/magnet
- Di area terbuka
- Gerakan halus dan perlahan
''';
  }
  
  /// Check if calibration is needed
  static bool needsCalibration(List<double> recentReadings) {
    if (recentReadings.length < 10) return false;
    
    // Calculate variance
    final mean = recentReadings.reduce((a, b) => a + b) / recentReadings.length;
    final variance = recentReadings
        .map((x) => (x - mean) * (x - mean))
        .reduce((a, b) => a + b) / recentReadings.length;
    
    // High variance indicates poor calibration
    return variance > 1000;
  }
}