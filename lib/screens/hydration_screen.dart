import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:permission_handler/permission_handler.dart';

import '../models/hydration_schedule.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  State<HydrationPage> createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage>
    with WidgetsBindingObserver {
  final _notificationService = NotificationService();
  final _schedule = HydrationSchedule.defaultSchedule;

  bool _reminderEnabled = false;
  double _userTargetLiters = 2.0;
  HydrationProgress _progress = HydrationProgress(
    date: DateTime.now(),
    targetLiters: 2.0, // Will be updated in _loadData
  );
  bool _loading = true;
  bool _notificationsAllowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Periksa ulang izin saat pengguna kembali ke aplikasi
    if (state == AppLifecycleState.resumed) {
      _checkPermissionsAndUpdate();
    }
  }

  Future<void> _checkPermissionsAndUpdate() async {
    final isAllowed = await _notificationService.areNotificationsEnabled();
    if (mounted && isAllowed != _notificationsAllowed) {
      setState(() {
        _notificationsAllowed = isAllowed;
        // Nonaktifkan pengingat jika izin dicabut
        if (!isAllowed) {
          _reminderEnabled = false;
          _saveData();
        }
      });
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final areEnabled = await _notificationService.areNotificationsEnabled();
    final reminderEnabledPref =
        prefs.getBool('hydration_reminder_enabled') ?? false;

    // Load user target
    _userTargetLiters = prefs.getDouble('hydration_target_liters') ?? 2.0;

    setState(() {
      _notificationsAllowed = areEnabled;
      // Pengingat hanya bisa aktif jika diizinkan sistem & disimpan di preferensi
      _reminderEnabled = reminderEnabledPref && areEnabled;

      final progressJson = prefs.getString('hydration_progress');
      if (progressJson != null) {
        try {
          final data = json.decode(progressJson);
          final savedProgress = HydrationProgress.fromJson(data);

          if (!_isSameDay(savedProgress.date, DateTime.now())) {
            _progress = HydrationProgress(
              date: DateTime.now(),
              targetLiters: _userTargetLiters,
            );
          } else {
            // Update target if user changed it mid-day
            _progress = savedProgress.copyWith(targetLiters: _userTargetLiters);
          }
        } catch (e) {
          _resetProgress();
        }
      }

      _loading = false;
    });

    // Sinkronkan status jika izin dicabut saat aplikasi ditutup
    if (reminderEnabledPref && !areEnabled) {
      await _saveData();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hydration_reminder_enabled', _reminderEnabled);
    await prefs.setString(
        'hydration_progress', json.encode(_progress.toJson()));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      // Mencoba mengaktifkan
      await _notificationService.requestPermissions();
      final isAllowed = await _notificationService.areNotificationsEnabled();

      if (isAllowed) {
        setState(() {
          _reminderEnabled = true;
          _notificationsAllowed = true;
        });
        await _notificationService.scheduleHydrationReminders(_schedule);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Pengingat diaktifkan')),
          );
        }
      } else {
        // Izin ditolak, switch akan kembali ke 'off' secara otomatis
        setState(() => _notificationsAllowed = false);
        if (mounted) _showPermissionDialog();
        return; // Jangan simpan data karena status tidak berubah
      }
    } else {
      // Menonaktifkan
      setState(() => _reminderEnabled = false);
      await _notificationService.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Pengingat dinonaktifkan')),
        );
      }
    }

    await _saveData();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Notifikasi Diperlukan'),
        content: const Text(
            'Untuk mengaktifkan pengingat, izinkan notifikasi untuk aplikasi ini di pengaturan perangkat.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Nanti')),
          TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Buka Pengaturan')),
        ],
      ),
    );
  }

  Future<void> _testNotification() async {
    await _notificationService.sendTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '🔔 Notifikasi tes dikirim! : Aplikasi Sedang Di Kembangkan'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addWater() async {
    final currentHour = DateTime.now().hour;

    setState(() {
      if (_progress.litersConsumed < _progress.targetLiters) {
        _progress = _progress.copyWith(
          litersConsumed: _progress.litersConsumed + 0.25,
          completedHours: [
            ..._progress.completedHours,
            if (!_progress.completedHours.contains(currentHour)) currentHour,
          ],
        );
      }
    });

    await _saveData();
  }

  Future<void> _resetProgress() async {
    setState(() {
      _progress = HydrationProgress(
        date: DateTime.now(),
        targetLiters: _userTargetLiters,
      );
    });
    await _saveData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildProgressCard(),
              const SizedBox(height: 16),
              _buildScheduleCard(),
              const SizedBox(height: 16),
              _buildControlsCard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.water_drop, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'Water Care',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Jaga hidrasi tubuhmu setiap hari',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Hari Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1976D2),
                ),
              ),
              if (_progress.litersConsumed > 0)
                TextButton.icon(
                  onPressed: _resetProgress,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress visual
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_progress.litersConsumed.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '/ ${_progress.targetLiters.toStringAsFixed(1)} L',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black54,
                    ),
                  ),
                  const Text(
                    'liter',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress.percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.blue.shade50,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progress.isGoalAchieved
                    ? Colors.green
                    : const Color(0xFF1976D2),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _progress.isGoalAchieved
                ? '🎉 Target tercapai! Pertahankan!'
                : 'Masih ${_progress.remainingLiters.toStringAsFixed(2)} L lagi!',
            style: TextStyle(
              fontSize: 14,
              color: _progress.isGoalAchieved ? Colors.green : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          // Add water button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _progress.litersConsumed < _progress.targetLiters
                  ? _addWater
                  : null,
              icon: const Icon(Icons.add),
              label: const Text('Tambah 0.25 L'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    final now = DateTime.now();
    final currentHour = now.hour;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Minum',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 16),
          ...(_schedule.hours.map((hour) {
            final isPast = hour < currentHour;
            final isCurrent = hour == currentHour;
            final isCompleted = _progress.completedHours.contains(hour);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? const Color(0xFF1976D2)
                              : isPast
                                  ? Colors.grey.shade300
                                  : Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.water_drop_outlined,
                      color: isCompleted || isCurrent
                          ? Colors.white
                          : Colors.blue.shade300,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCompleted || isCurrent
                            ? Colors.black
                            : Colors.black54,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    const Text(
                      '✓ Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (isCurrent)
                    const Text(
                      '← Sekarang',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            );
          }).toList()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notifikasi tidak aktif jam 21:00 - 05:59',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengingat Aktif',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _reminderEnabled ? 'Notifikasi menyala' : 'Notifikasi mati',
                    style: TextStyle(
                      fontSize: 12,
                      color: _reminderEnabled ? Colors.green : Colors.black45,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _reminderEnabled,
                onChanged: _toggleReminder,
                activeColor: Colors.green,
              ),
            ],
          ),

          // Tampilkan peringatan jika notifikasi diblokir sistem
          if (!_notificationsAllowed)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Notifikasi diblokir oleh sistem.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Pengaturan Target'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2),
                side: const BorderSide(color: Color(0xFF1976D2)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _testNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Time To Drink Water'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2),
                side: const BorderSide(color: Color(0xFF1976D2)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
