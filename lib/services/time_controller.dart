import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Time controller for Sky Map
/// Allows time manipulation like Stellarium
class TimeController {
  DateTime _currentTime;
  bool _isRealTime = true;
  Timer? _updateTimer;
  
  // Callbacks
  final VoidCallback? onTimeChanged;
  
  TimeController({
    DateTime? initialTime,
    this.onTimeChanged,
  }) : _currentTime = initialTime ?? DateTime.now();
  
  /// Current simulated time
  DateTime get currentTime => _currentTime;
  
  /// Is using real-time
  bool get isRealTime => _isRealTime;
  
  /// Set to real-time mode
  void setRealTime() {
    _isRealTime = true;
    _currentTime = DateTime.now();
    _startRealTimeUpdate();
    onTimeChanged?.call();
  }
  
  /// Set to custom time
  void setCustomTime(DateTime time) {
    _isRealTime = false;
    _currentTime = time;
    _stopRealTimeUpdate();
    onTimeChanged?.call();
  }
  
  /// Add hours
  void addHours(int hours) {
    _isRealTime = false;
    _currentTime = _currentTime.add(Duration(hours: hours));
    _stopRealTimeUpdate();
    onTimeChanged?.call();
  }
  
  /// Add days
  void addDays(int days) {
    _isRealTime = false;
    _currentTime = _currentTime.add(Duration(days: days));
    _stopRealTimeUpdate();
    onTimeChanged?.call();
  }
  
  /// Set specific hour (0-23)
  void setHour(int hour) {
    _isRealTime = false;
    _currentTime = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
      hour,
      _currentTime.minute,
    );
    _stopRealTimeUpdate();
    onTimeChanged?.call();
  }
  
  /// Set specific date
  void setDate(DateTime date) {
    _isRealTime = false;
    _currentTime = DateTime(
      date.year,
      date.month,
      date.day,
      _currentTime.hour,
      _currentTime.minute,
    );
    _stopRealTimeUpdate();
    onTimeChanged?.call();
  }
  
  /// Quick time presets
  void setTimeOfDay(TimeOfDay timeOfDay) {
    final hour = switch (timeOfDay) {
      TimeOfDay.dawn => 6,
      TimeOfDay.morning => 9,
      TimeOfDay.noon => 12,
      TimeOfDay.afternoon => 15,
      TimeOfDay.evening => 18,
      TimeOfDay.night => 21,
      TimeOfDay.midnight => 0,
    };
    
    setHour(hour);
  }
  
  /// Start real-time updates
  void _startRealTimeUpdate() {
    _stopRealTimeUpdate();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRealTime) {
        _currentTime = DateTime.now();
        onTimeChanged?.call();
      }
    });
  }
  
  /// Stop real-time updates
  void _stopRealTimeUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
  
  /// Format time for display
  String get formattedTime => DateFormat('HH:mm').format(_currentTime);
  String get formattedDate => DateFormat('EEE, d MMM yyyy', 'id_ID').format(_currentTime);
  String get formattedDateTime => DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(_currentTime);
  
  /// Get time of day description
  String get timeOfDayDescription {
    final hour = _currentTime.hour;
    if (hour >= 5 && hour < 7) return 'Fajar';
    if (hour >= 7 && hour < 12) return 'Pagi';
    if (hour >= 12 && hour < 15) return 'Siang';
    if (hour >= 15 && hour < 18) return 'Sore';
    if (hour >= 18 && hour < 21) return 'Petang';
    return 'Malam';
  }
  
  /// Dispose
  void dispose() {
    _stopRealTimeUpdate();
  }
}

enum TimeOfDay {
  dawn,      // 06:00
  morning,   // 09:00
  noon,      // 12:00
  afternoon, // 15:00
  evening,   // 18:00
  night,     // 21:00
  midnight,  // 00:00
}

/// Time control panel widget
class TimeControlPanel extends StatelessWidget {
  final TimeController controller;
  final VoidCallback onUpdate;
  
  const TimeControlPanel({
    super.key,
    required this.controller,
    required this.onUpdate,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Kontrol Waktu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const Divider(color: Colors.white30),
          
          // Current time display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.formattedTime,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.timeOfDayDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.cyan.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Real-time toggle
          Row(
            children: [
              Switch(
                value: controller.isRealTime,
                onChanged: (value) {
                  if (value) {
                    controller.setRealTime();
                  } else {
                    controller.setCustomTime(controller.currentTime);
                  }
                  onUpdate();
                },
                activeColor: Colors.cyan,
              ),
              const SizedBox(width: 8),
              Text(
                controller.isRealTime ? 'Waktu Real-time' : 'Waktu Simulasi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick time presets
          const Text(
            'Preset Waktu:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetButton('Fajar', () {
                controller.setTimeOfDay(TimeOfDay.dawn);
                onUpdate();
              }),
              _buildPresetButton('Pagi', () {
                controller.setTimeOfDay(TimeOfDay.morning);
                onUpdate();
              }),
              _buildPresetButton('Siang', () {
                controller.setTimeOfDay(TimeOfDay.noon);
                onUpdate();
              }),
              _buildPresetButton('Sore', () {
                controller.setTimeOfDay(TimeOfDay.afternoon);
                onUpdate();
              }),
              _buildPresetButton('Petang', () {
                controller.setTimeOfDay(TimeOfDay.evening);
                onUpdate();
              }),
              _buildPresetButton('Malam', () {
                controller.setTimeOfDay(TimeOfDay.night);
                onUpdate();
              }),
              _buildPresetButton('Tengah Malam', () {
                controller.setTimeOfDay(TimeOfDay.midnight);
                onUpdate();
              }),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Hour adjustment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAdjustButton(
                icon: Icons.remove_circle_outline,
                label: '-1 Jam',
                onPressed: () {
                  controller.addHours(-1);
                  onUpdate();
                },
              ),
              _buildAdjustButton(
                icon: Icons.today,
                label: 'Hari Ini',
                onPressed: () {
                  controller.setRealTime();
                  onUpdate();
                },
              ),
              _buildAdjustButton(
                icon: Icons.add_circle_outline,
                label: '+1 Jam',
                onPressed: () {
                  controller.addHours(1);
                  onUpdate();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Day adjustment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAdjustButton(
                icon: Icons.keyboard_double_arrow_left,
                label: '-1 Hari',
                onPressed: () {
                  controller.addDays(-1);
                  onUpdate();
                },
              ),
              _buildAdjustButton(
                icon: Icons.calendar_today,
                label: 'Pilih Tanggal',
                onPressed: () => _showDatePicker(context),
              ),
              _buildAdjustButton(
                icon: Icons.keyboard_double_arrow_right,
                label: '+1 Hari',
                onPressed: () {
                  controller.addDays(1);
                  onUpdate();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPresetButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan.withOpacity(0.2),
        foregroundColor: Colors.cyan,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.cyan),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
  
  Widget _buildAdjustButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white30),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.currentTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      controller.setDate(picked);
      onUpdate();
    }
  }
}