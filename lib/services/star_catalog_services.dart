import 'dart:convert';
import 'package:flutter/services.dart';

/// Star data model
class StarData {
  final String id;
  final String name;
  final double ra;
  final double dec;
  final double magnitude;
  final String spectralType;
  final String? constellation;
  
  StarData({
    required this.id,
    required this.name,
    required this.ra,
    required this.dec,
    required this.magnitude,
    required this.spectralType,
    this.constellation,
  });
  
  factory StarData.fromJson(Map<String, dynamic> json) {
    return StarData(
      id: json['id'] as String,
      name: json['name'] as String,
      ra: (json['ra'] as num).toDouble(),
      dec: (json['dec'] as num).toDouble(),
      magnitude: (json['mag'] as num).toDouble(),
      spectralType: json['spectral_type'] as String? ?? 'G',
      constellation: json['constellation'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ra': ra,
    'dec': dec,
    'mag': magnitude,
    'spectral_type': spectralType,
    'constellation': constellation,
  };
}

/// Star catalog service
/// Manages star data loading and querying
class StarCatalogService {
  static final StarCatalogService _instance = StarCatalogService._internal();
  factory StarCatalogService() => _instance;
  StarCatalogService._internal();
  
  List<StarData>? _stars;
  bool _isLoaded = false;
  
  /// Load star catalog from JSON
  Future<void> loadCatalog() async {
    if (_isLoaded && _stars != null) return;
    
    try {
      // Try to load from assets
      final jsonString = await rootBundle.loadString(
        'assets/data/star_catalog_bright.json'
      );
      
      final List<dynamic> jsonData = json.decode(jsonString);
      
      _stars = jsonData.map((json) => StarData.fromJson(json)).toList();
      _isLoaded = true;
      
      print('✅ Loaded ${_stars!.length} stars from catalog');
    } catch (e) {
      print('⚠️ Error loading star catalog: $e');
      print('Using fallback star data...');
      
      // Fallback to hardcoded stars
      _stars = _getDefaultStars();
      _isLoaded = true;
    }
  }
  
  /// Get all stars
  List<StarData> getAllStars() {
    if (!_isLoaded || _stars == null) {
      return _getDefaultStars();
    }
    return _stars!;
  }
  
  /// Get stars brighter than magnitude limit
  List<StarData> getStarsByMagnitude(double maxMagnitude) {
    return getAllStars()
        .where((star) => star.magnitude <= maxMagnitude)
        .toList();
  }
  
  /// Get stars in constellation
  List<StarData> getStarsByConstellation(String constellation) {
    return getAllStars()
        .where((star) => star.constellation == constellation)
        .toList();
  }
  
  /// Get brightest N stars
  List<StarData> getBrightestStars(int count) {
    final stars = getAllStars()
      ..sort((a, b) => a.magnitude.compareTo(b.magnitude));
    return stars.take(count).toList();
  }
  
  /// Search star by name
  StarData? findStarByName(String name) {
    try {
      return getAllStars().firstWhere(
        (star) => star.name.toLowerCase().contains(name.toLowerCase())
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Check if catalog is loaded
  bool get isLoaded => _isLoaded;
  
  /// Get star count
  int get starCount => _stars?.length ?? 0;
  
  /// Default fallback stars (20 brightest)
  List<StarData> _getDefaultStars() {
    return [
      StarData(
        id: 'HIP32349',
        name: 'Sirius',
        ra: 101.28715,
        dec: -16.71611,
        magnitude: -1.46,
        spectralType: 'A1V',
        constellation: 'CMa',
      ),
      StarData(
        id: 'HIP30438',
        name: 'Canopus',
        ra: 95.98795,
        dec: -52.69566,
        magnitude: -0.74,
        spectralType: 'A9II',
        constellation: 'Car',
      ),
      StarData(
        id: 'HIP71683',
        name: 'Arcturus',
        ra: 213.91530,
        dec: 19.18241,
        magnitude: -0.05,
        spectralType: 'K1.5III',
        constellation: 'Boo',
      ),
      StarData(
        id: 'HIP69673',
        name: 'Rigel Kentaurus',
        ra: 219.90205,
        dec: -60.83399,
        magnitude: -0.01,
        spectralType: 'G2V',
        constellation: 'Cen',
      ),
      StarData(
        id: 'HIP91262',
        name: 'Vega',
        ra: 279.23473,
        dec: 38.78369,
        magnitude: 0.03,
        spectralType: 'A0Va',
        constellation: 'Lyr',
      ),
      StarData(
        id: 'HIP24608',
        name: 'Capella',
        ra: 79.17232,
        dec: 45.99799,
        magnitude: 0.08,
        spectralType: 'G5IIIe',
        constellation: 'Aur',
      ),
      StarData(
        id: 'HIP24436',
        name: 'Rigel',
        ra: 78.63446,
        dec: -8.20164,
        magnitude: 0.13,
        spectralType: 'B8Ia',
        constellation: 'Ori',
      ),
      StarData(
        id: 'HIP27989',
        name: 'Procyon',
        ra: 114.82576,
        dec: 5.22499,
        magnitude: 0.38,
        spectralType: 'F5IV-V',
        constellation: 'CMi',
      ),
      StarData(
        id: 'HIP21421',
        name: 'Achernar',
        ra: 24.42852,
        dec: -57.23668,
        magnitude: 0.46,
        spectralType: 'B3Vpe',
        constellation: 'Eri',
      ),
      StarData(
        id: 'HIP29038',
        name: 'Betelgeuse',
        ra: 88.79293,
        dec: 7.40704,
        magnitude: 0.50,
        spectralType: 'M1-2Ia-Iab',
        constellation: 'Ori',
      ),
      StarData(
        id: 'HIP80763',
        name: 'Altair',
        ra: 297.69582,
        dec: 8.86832,
        magnitude: 0.77,
        spectralType: 'A7V',
        constellation: 'Aql',
      ),
      StarData(
        id: 'HIP25336',
        name: 'Aldebaran',
        ra: 68.98016,
        dec: 16.50930,
        magnitude: 0.85,
        spectralType: 'K5+III',
        constellation: 'Tau',
      ),
      StarData(
        id: 'HIP37279',
        name: 'Spica',
        ra: 201.29825,
        dec: -11.16132,
        magnitude: 1.04,
        spectralType: 'B1III-IV',
        constellation: 'Vir',
      ),
      StarData(
        id: 'HIP11767',
        name: 'Polaris',
        ra: 37.95456,
        dec: 89.26411,
        magnitude: 1.98,
        spectralType: 'F7Ib',
        constellation: 'UMi',
      ),
      StarData(
        id: 'HIP49669',
        name: 'Regulus',
        ra: 152.09298,
        dec: 11.96721,
        magnitude: 1.35,
        spectralType: 'B7V',
        constellation: 'Leo',
      ),
      StarData(
        id: 'HIP62434',
        name: 'Acrux',
        ra: 186.64963,
        dec: -63.09909,
        magnitude: 0.77,
        spectralType: 'B0.5IV',
        constellation: 'Cru',
      ),
      StarData(
        id: 'HIP68702',
        name: 'Hadar',
        ra: 210.95592,
        dec: -60.37303,
        magnitude: 0.61,
        spectralType: 'B1III',
        constellation: 'Cen',
      ),
      StarData(
        id: 'HIP97649',
        name: 'Deneb',
        ra: 310.35798,
        dec: 45.28034,
        magnitude: 1.25,
        spectralType: 'A2Ia',
        constellation: 'Cyg',
      ),
      StarData(
        id: 'HIP113368',
        name: 'Fomalhaut',
        ra: 344.41269,
        dec: -29.62223,
        magnitude: 1.16,
        spectralType: 'A3V',
        constellation: 'PsA',
      ),
      StarData(
        id: 'HIP54061',
        name: 'Mimosa',
        ra: 191.93026,
        dec: -59.68877,
        magnitude: 1.25,
        spectralType: 'B0.5III',
        constellation: 'Cru',
      ),
    ];
  }
  
  /// Clear cached data
  void clearCache() {
    _stars = null;
    _isLoaded = false;
  }
  
  /// Reload catalog
  Future<void> reload() async {
    clearCache();
    await loadCatalog();
  }
}