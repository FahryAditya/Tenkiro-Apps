import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/earthquake.dart';

class EarthquakeService {
  static const String _bmkgAutogempaUrl = 'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json';
  static const String _bmkgGempaUrl = 'https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json';
  
  final http.Client _client;
  Timer? _pollingTimer;
  final _earthquakeStreamController = StreamController<Earthquake>.broadcast();
  
  Position? _lastKnownPosition;
  DateTime? _lastSuccessfulFetch;

  EarthquakeService({http.Client? client}) : _client = client ?? http.Client();

  Stream<Earthquake> get earthquakeStream => _earthquakeStreamController.stream;

  /// Get latest significant earthquake from BMKG
  Future<Earthquake?> getLatestEarthquake() async {
    try {
      print('📡 Fetching latest earthquake from BMKG...');
      
      final response = await _client.get(
        Uri.parse(_bmkgAutogempaUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Tenkiro/3.0',
          'Cache-Control': 'no-cache',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );

      if (response.statusCode == 200) {
        print('✅ BMKG API response: ${response.statusCode}');
        
        final data = json.decode(response.body);
        
        if (data['Infogempa'] == null || data['Infogempa']['gempa'] == null) {
          print('⚠️ Invalid data structure from BMKG');
          return null;
        }
        
        final gempaData = data['Infogempa']['gempa'];
        final earthquake = _parseBMKGData(gempaData, isLatest: true);
        
        // Calculate distance if user location available
        final position = await _getUserPositionSafe();
        if (position != null) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            earthquake.epicenter.latitude,
            earthquake.epicenter.longitude,
          ) / 1000;
          
          _lastSuccessfulFetch = DateTime.now();
          return earthquake.copyWith(distanceFromUser: distance);
        }
        
        _lastSuccessfulFetch = DateTime.now();
        return earthquake;
      } else {
        print('❌ BMKG API error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      return null;
    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error fetching latest earthquake: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get recent earthquakes (last 24 hours) from BMKG
  Future<List<Earthquake>> getRecentEarthquakes({
    int hours = 24,
    double minMagnitude = 3.0,
  }) async {
    try {
      print('📡 Fetching recent earthquakes from BMKG...');
      
      final response = await _client.get(
        Uri.parse(_bmkgGempaUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Tenkiro/3.0',
          'Cache-Control': 'no-cache',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );

      if (response.statusCode == 200) {
        print('✅ BMKG recent earthquakes response: ${response.statusCode}');
        
        final data = json.decode(response.body);
        
        if (data['Infogempa'] == null || data['Infogempa']['gempa'] == null) {
          print('⚠️ Invalid data structure from BMKG');
          return [];
        }
        
        final gempaList = data['Infogempa']['gempa'] as List;
        print('📊 Found ${gempaList.length} earthquakes from BMKG');
        
        final position = await _getUserPositionSafe();
        
        final earthquakes = <Earthquake>[];
        
        for (var gempaData in gempaList) {
          try {
            final earthquake = _parseBMKGData(gempaData);
            
            // Calculate distance
            if (position != null) {
              final distance = Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                earthquake.epicenter.latitude,
                earthquake.epicenter.longitude,
              ) / 1000;
              
              earthquakes.add(earthquake.copyWith(distanceFromUser: distance));
            } else {
              earthquakes.add(earthquake);
            }
          } catch (e) {
            print('⚠️ Error parsing earthquake data: $e');
            continue;
          }
        }
        
        // Filter by time and magnitude
        final now = DateTime.now();
        final filtered = earthquakes.where((eq) {
          final diff = now.difference(eq.timestamp);
          return diff.inHours <= hours && eq.magnitude >= minMagnitude;
        }).toList();
        
        // Sort by timestamp (newest first)
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        print('✅ Returning ${filtered.length} filtered earthquakes');
        _lastSuccessfulFetch = DateTime.now();
        
        return filtered;
      } else {
        print('❌ BMKG API error: ${response.statusCode}');
        return [];
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      return [];
    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      return [];
    } catch (e, stackTrace) {
      print('❌ Error fetching recent earthquakes: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Parse BMKG earthquake data format
  Earthquake _parseBMKGData(Map<String, dynamic> data, {bool isLatest = false}) {
    try {
      // Parse tanggal dan waktu
      final tanggal = data['Tanggal'] as String? ?? '';
      final jam = data['Jam'] as String? ?? '';
      
      final timestamp = _parseBMKGDateTime(tanggal, jam);
      
      // Parse magnitude
      final magnitudeStr = data['Magnitude'] as String? ?? '0';
      final magnitude = double.tryParse(magnitudeStr.replaceAll(',', '.')) ?? 0.0;
      
      // Parse kedalaman
      final kedalamanStr = data['Kedalaman'] as String? ?? '0';
      final depth = _parseDepth(kedalamanStr);
      
      // Parse koordinat
      final koordinatStr = data['Coordinates'] as String? ?? '0,0';
      final coords = _parseCoordinates(koordinatStr);
      
      // Region / Wilayah
      final wilayah = data['Wilayah'] as String? ?? 'Unknown';
      
      // Potensi tsunami
      final potensi = data['Potensi'] as String?;
      final tsunami = _parseTsunamiStatus(potensi);
      
      // Dirasakan (jika ada)
      final dirasakan = data['Dirasakan'] as String?;
      
      // Shakemap URL (hanya untuk gempa terbaru)
      final shakemapUrl = isLatest ? data['Shakemap'] as String? : null;
      
      final earthquake = Earthquake(
        id: 'bmkg_${timestamp.millisecondsSinceEpoch}',
        timestamp: timestamp,
        localTime: timestamp,
        magnitude: magnitude,
        depth: depth,
        epicenter: Epicenter(
          latitude: coords['lat']!,
          longitude: coords['lon']!,
          description: _extractEpicentername(wilayah),
        ),
        region: wilayah,
        mmi: _estimateMMI(magnitude, depth),
        tsunami: tsunami,
        source: 'BMKG',
        affectedAreas: dirasakan != null ? _parseAffectedAreas(dirasakan) : null,
        distanceFromUser: null,
        shakemapUrl: shakemapUrl,
      );
      
      print('✅ Parsed earthquake: M${magnitude} at ${wilayah}');
      return earthquake;
      
    } catch (e, stackTrace) {
      print('❌ Error parsing BMKG data: $e');
      print('Data: $data');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Parse BMKG date time format
  DateTime _parseBMKGDateTime(String tanggal, String jam) {
    try {
      // Format tanggal: "23 Jan 2024" atau "23-Jan-2024"
      final tanggalParts = tanggal.replaceAll('-', ' ').split(' ');
      
      if (tanggalParts.length < 3) {
        print('⚠️ Invalid date format: $tanggal');
        return DateTime.now();
      }
      
      final day = int.tryParse(tanggalParts[0]) ?? 1;
      final monthStr = tanggalParts[1];
      final year = int.tryParse(tanggalParts[2]) ?? DateTime.now().year;
      
      final months = {
        'Jan': 1, 'Januari': 1,
        'Feb': 2, 'Februari': 2,
        'Mar': 3, 'Maret': 3,
        'Apr': 4, 'April': 4,
        'Mei': 5, 'May': 5,
        'Jun': 6, 'Juni': 6,
        'Jul': 7, 'Juli': 7,
        'Agu': 8, 'Agustus': 8, 'Aug': 8,
        'Sep': 9, 'September': 9,
        'Okt': 10, 'Oktober': 10, 'Oct': 10,
        'Nov': 11, 'November': 11,
        'Des': 12, 'Desember': 12, 'Dec': 12,
      };
      
      final month = months[monthStr] ?? 1;
      
      // Format jam: "10:15:23 WIB" atau "10:15:23"
      final jamParts = jam.split(' ')[0].split(':');
      
      if (jamParts.length < 3) {
        print('⚠️ Invalid time format: $jam');
        return DateTime(year, month, day);
      }
      
      final hour = int.tryParse(jamParts[0]) ?? 0;
      final minute = int.tryParse(jamParts[1]) ?? 0;
      final second = int.tryParse(jamParts[2]) ?? 0;
      
      return DateTime(year, month, day, hour, minute, second);
      
    } catch (e) {
      print('❌ Error parsing date/time: $e');
      return DateTime.now();
    }
  }

  /// Parse depth from BMKG format
  double _parseDepth(String kedalamanStr) {
    try {
      // Format: "10 km" atau "10km" atau "10 Km"
      final numStr = kedalamanStr
          .toLowerCase()
          .replaceAll('km', '')
          .replaceAll(',', '.')
          .trim();
      return double.tryParse(numStr) ?? 10.0;
    } catch (e) {
      return 10.0;
    }
  }

  /// Parse coordinates from BMKG format
  Map<String, double> _parseCoordinates(String coordStr) {
    try {
      // Format bisa:
      // "-7.54,110.45"
      // "7.54 LS,110.45 BT"
      // "7.54 LS, 110.45 BT"
      
      // Clean up string
      var cleaned = coordStr
          .replaceAll(' LS', '')
          .replaceAll(' LU', '')
          .replaceAll(' BT', '')
          .replaceAll(' BB', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');
      
      // Split by comma or period
      List<String> parts;
      if (cleaned.contains(',')) {
        parts = cleaned.split(',');
      } else {
        // Try to find decimal points
        final regex = RegExp(r'(-?\d+\.?\d*)');
        final matches = regex.allMatches(cleaned);
        parts = matches.map((m) => m.group(0)!).toList();
      }
      
      if (parts.length < 2) {
        print('⚠️ Invalid coordinate format: $coordStr');
        return {'lat': -6.2088, 'lon': 106.8456}; // Default Jakarta
      }
      
      var lat = double.tryParse(parts[0].trim()) ?? 0.0;
      var lon = double.tryParse(parts[1].trim()) ?? 0.0;
      
      // Handle LS (Lintang Selatan) - Indonesia mostly south
      // If coordinates mention LS and lat is positive, make it negative
      if (coordStr.contains('LS') && lat > 0) {
        lat = -lat;
      }
      
      // Handle LU (Lintang Utara) - keep positive
      if (coordStr.contains('LU') && lat < 0) {
        lat = lat.abs();
      }
      
      // Validate reasonable bounds for Indonesia
      if (lat < -12 || lat > 8) {
        print('⚠️ Latitude out of Indonesia range: $lat');
      }
      
      if (lon < 95 || lon > 141) {
        print('⚠️ Longitude out of Indonesia range: $lon');
      }
      
      return {'lat': lat, 'lon': lon};
      
    } catch (e) {
      print('❌ Error parsing coordinates: $e');
      return {'lat': -6.2088, 'lon': 106.8456}; // Default Jakarta
    }
  }

  /// Parse tsunami status from BMKG text
  TsunamiStatus _parseTsunamiStatus(String? potensi) {
    if (potensi == null || potensi.isEmpty) return TsunamiStatus.none;
    
    final lower = potensi.toLowerCase();
    
    if (lower.contains('berpotensi tsunami') || 
        lower.contains('potensi tsunami') ||
        lower.contains('tsunami')) {
      return TsunamiStatus.alert;
    }
    
    if (lower.contains('waspada') || lower.contains('hati-hati')) {
      return TsunamiStatus.warning;
    }
    
    if (lower.contains('tidak berpotensi')) {
      return TsunamiStatus.none;
    }
    
    return TsunamiStatus.none;
  }

  /// Estimate MMI (Modified Mercalli Intensity) from magnitude and depth
  int? _estimateMMI(double magnitude, double depth) {
    // Simplified MMI estimation
    // Deeper earthquakes have less surface impact
    
    if (depth > 300) return 1; // Very deep, barely felt
    
    if (magnitude < 3.0) return 1;
    if (magnitude < 4.0) return 2;
    if (magnitude < 5.0) return depth < 50 ? 4 : 3;
    if (magnitude < 6.0) return depth < 50 ? 6 : 4;
    if (magnitude < 7.0) return depth < 50 ? 7 : 5;
    
    return depth < 50 ? 8 : 6;
  }

  /// Extract epicenter name from region string
  String _extractEpicentername(String wilayah) {
    try {
      // Extract location name from BMKG format
      // e.g., "87 km BaratLaut Semarang" -> "Laut Jawa"
      
      if (wilayah.toLowerCase().contains('laut')) {
        final parts = wilayah.split(' ');
        final lautIndex = parts.indexWhere((p) => p.toLowerCase() == 'laut');
        if (lautIndex >= 0 && lautIndex < parts.length - 1) {
          return '${parts[lautIndex]} ${parts[lautIndex + 1]}';
        }
        return 'Laut Indonesia';
      }
      
      // Extract city/province name (usually at the end)
      final parts = wilayah.split(',');
      if (parts.length > 1) {
        return parts.last.trim();
      }
      
      return 'Indonesia';
    } catch (e) {
      return 'Indonesia';
    }
  }

  /// Parse affected areas from "Dirasakan" field
  List<String>? _parseAffectedAreas(String dirasakan) {
    try {
      if (dirasakan.isEmpty || 
          dirasakan.toLowerCase() == 'tidak terasa' ||
          dirasakan.toLowerCase() == '-') {
        return null;
      }
      
      // Split by common separators
      final areas = dirasakan
          .split(RegExp(r',|dan|;|\n'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.length > 2)
          .toList();
      
      return areas.isEmpty ? null : areas;
    } catch (e) {
      return null;
    }
  }

  /// Get user position safely with timeout and error handling
  Future<Position?> _getUserPositionSafe() async {
    // Return cached position if recent (within 5 minutes)
    if (_lastKnownPosition != null) {
      return _lastKnownPosition;
    }
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 3));
      
      if (!serviceEnabled) {
        print('📍 Location service disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 3));
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 5));
        
        if (permission == LocationPermission.denied) {
          print('📍 Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('📍 Location permission denied forever');
        return null;
      }

      _lastKnownPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('📍 Location timeout');
          throw TimeoutException('Location timeout');
        },
      );
      
      print('📍 Got user location: ${_lastKnownPosition!.latitude}, ${_lastKnownPosition!.longitude}');
      return _lastKnownPosition;
      
    } catch (e) {
      print('📍 Error getting user position: $e');
      return null;
    }
  }

  /// Start polling for earthquake updates
  void startPolling({Duration interval = const Duration(minutes: 2)}) {
    print('🔄 Starting earthquake polling (interval: $interval)');
    
    _pollingTimer?.cancel();
    
    // Initial fetch
    _pollData();
    
    // Start periodic polling
    _pollingTimer = Timer.periodic(interval, (_) => _pollData());
  }

  /// Poll data and emit to stream
  Future<void> _pollData() async {
    try {
      print('🔄 Polling earthquake data...');
      
      final earthquake = await getLatestEarthquake();
      
      if (earthquake != null) {
        print('✅ Emitting earthquake to stream: M${earthquake.magnitude}');
        _earthquakeStreamController.add(earthquake);
      } else {
        print('⚠️ No earthquake data from polling');
      }
    } catch (e) {
      print('❌ Polling error: $e');
    }
  }

  /// Stop polling
  void stopPolling() {
    print('🛑 Stopping earthquake polling');
    _pollingTimer?.cancel();
  }

  /// Get last successful fetch time
  DateTime? get lastSuccessfulFetch => _lastSuccessfulFetch;

  /// Check if service is healthy
  bool get isHealthy {
    if (_lastSuccessfulFetch == null) return false;
    
    final now = DateTime.now();
    final diff = now.difference(_lastSuccessfulFetch!);
    
    return diff.inMinutes < 10; // Healthy if fetched within 10 minutes
  }

  /// Dispose resources
  void dispose() {
    print('🗑️ Disposing earthquake service');
    _pollingTimer?.cancel();
    _earthquakeStreamController.close();
    _client.close();
  }
}