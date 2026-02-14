import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/earthquake.dart';
import '../models/earthquake_settings.dart';
import '../services/earthquake_service.dart';
import '../services/earthquake_notification_service.dart';

// ✅ FIXED: Proper SharedPreferences provider initialization
// This will be overridden in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Return a dummy instance that will be overridden
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in ProviderScope');
});

final earthquakeServiceProvider = Provider((ref) {
  final service = EarthquakeService();

  // Auto start polling when service is created
  service.startPolling(interval: const Duration(minutes: 2));

  // Stop polling when disposed
  ref.onDispose(() {
    service.stopPolling();
    service.dispose();
  });

  return service;
});

final notificationServiceProvider = Provider((ref) {
  final service = EarthquakeNotificationService();
  service.initialize();
  return service;
});

// Latest earthquake with auto-refresh
final latestEarthquakeProvider = StreamProvider<Earthquake?>((ref) async* {
  final service = ref.watch(earthquakeServiceProvider);

  // Emit initial value
  try {
    final initial = await service.getLatestEarthquake();
    if (initial != null) {
      yield initial;
    }
  } catch (e) {
    print('Error loading initial earthquake: $e');
  }

  // Listen to stream updates
  await for (final earthquake in service.earthquakeStream) {
    yield earthquake;

    // Trigger notification
    try {
      final settings = ref.read(earthquakeSettingsProvider);
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.showEarthquakeNotification(
          earthquake, settings);
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
});

// Recent earthquakes with periodic refresh
final recentEarthquakesProvider =
    StreamProvider<List<Earthquake>>((ref) async* {
  final service = ref.watch(earthquakeServiceProvider);

  // Initial fetch
  try {
    final initial = await service.getRecentEarthquakes();
    yield initial;
  } catch (e) {
    print('Error loading initial earthquakes: $e');
    yield [];
  }

  // Refresh every 2 minutes
  final timer = Timer.periodic(const Duration(minutes: 2), (_) async {
    try {
      final earthquakes = await service.getRecentEarthquakes();      // This will trigger a rebuild
      ref.invalidateSelf();
    } catch (e) {
      print('Error refreshing earthquakes: $e');
    }
  });

  ref.onDispose(() => timer.cancel());

  // Keep yielding updates
  while (true) {
    await Future.delayed(const Duration(minutes: 2));
    try {
      final earthquakes = await service.getRecentEarthquakes();
      yield earthquakes;
    } catch (e) {
      print('Error fetching earthquakes: $e');
      yield [];
    }
  }
});

// ✅ FIXED: Safe settings provider with fallback
final earthquakeSettingsProvider =
    StateNotifierProvider<EarthquakeSettingsNotifier, EarthquakeSettings>(
        (ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return EarthquakeSettingsNotifier(prefs);
  } catch (e) {
    // Fallback if SharedPreferences not available
    print('Warning: SharedPreferences not available, using in-memory settings');
    return EarthquakeSettingsNotifier(null);
  }
});

class EarthquakeSettingsNotifier extends StateNotifier<EarthquakeSettings> {
  final SharedPreferences? _prefs;
  static const String _key = 'earthquake_settings';

  EarthquakeSettingsNotifier(this._prefs) : super(_loadSettings(_prefs));

  static EarthquakeSettings _loadSettings(SharedPreferences? prefs) {
    if (prefs == null) {
      return const EarthquakeSettings();
    }

    try {
      final json = prefs.getString(_key);
      if (json != null) {
        return EarthquakeSettings.fromJson(jsonDecode(json));
      }
    } catch (e) {
      print('Error loading settings: $e');
    }

    return const EarthquakeSettings();
  }

  Future<void> _saveSettings() async {
    if (_prefs == null) {
      print('Warning: Cannot save settings, SharedPreferences not available');
      return;
    }

    try {
      await _prefs!.setString(_key, jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setMinimumMagnitude(double magnitude) async {
    state = state.copyWith(minimumMagnitude: magnitude);
    await _saveSettings();
  }

  Future<void> setTsunamiAlertsOnly(bool enabled) async {
    state = state.copyWith(tsunamiAlertsOnly: enabled);
    await _saveSettings();
  }

  Future<void> setMaxDistance(int distance) async {
    state = state.copyWith(maxDistanceKm: distance);
    await _saveSettings();
  }

  Future<void> setVibrate(bool enabled) async {
    state = state.copyWith(vibrate: enabled);
    await _saveSettings();
  }

  Future<void> setSound(bool enabled) async {
    state = state.copyWith(sound: enabled);
    await _saveSettings();
  }
}

// Live status provider
final isLiveProvider = Provider<bool>((ref) {
  final latestAsync = ref.watch(latestEarthquakeProvider);
  final recentAsync = ref.watch(recentEarthquakesProvider);

  // Check if either stream has data
  return latestAsync.hasValue || recentAsync.hasValue;
});

final selectedEarthquakeProvider = StateProvider<Earthquake?>((ref) => null);

// Manual refresh provider
final manualRefreshProvider = Provider((ref) {
  return () {
    ref.invalidate(latestEarthquakeProvider);
    ref.invalidate(recentEarthquakesProvider);
  };
});
