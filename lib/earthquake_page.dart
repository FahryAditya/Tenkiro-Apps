import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/earthquake.dart';
import 'providers/earthquake_providers_fixed.dart';
import 'widgets/hero_earthquake_card.dart';
import 'widgets/earthquake_list_item.dart';
import 'widgets/earthquake_map.dart';
import 'widgets/earthquake_stats.dart';

class EarthquakePage extends ConsumerStatefulWidget {
  const EarthquakePage({super.key});

  @override
  ConsumerState<EarthquakePage> createState() => _EarthquakePageState();
}

class _EarthquakePageState extends ConsumerState<EarthquakePage> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    
    // Request notification permissions on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  Future<void> _initializeServices() async {
    try {
      // Request notification permissions
      await ref.read(notificationServiceProvider).requestPermissions();
      
      // Start polling
      ref.read(earthquakeServiceProvider).startPolling();
      
      print('✅ Earthquake services initialized');
    } catch (e) {
      print('❌ Error initializing services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final latestQuakeAsync = ref.watch(latestEarthquakeProvider);
    final recentQuakesAsync = ref.watch(recentEarthquakesProvider);
    final isLive = ref.watch(isLiveProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: RefreshIndicator(
        onRefresh: () async {
          print('🔄 Manual refresh triggered');
          final refresh = ref.read(manualRefreshProvider);
          refresh();
          await Future.delayed(const Duration(milliseconds: 1500));
        },
        color: Colors.white,
        backgroundColor: const Color(0xFF1E1E1E),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildHeader(isLive),
            
            // Latest earthquake hero card
            latestQuakeAsync.when(
              data: (quake) {
                if (quake == null) {
                  return _buildNoDataCard('Belum ada data gempa terbaru');
                }
                
                if (quake.isSignificant) {
                  return SliverToBoxAdapter(
                    child: HeroEarthquakeCard(
                      earthquake: quake,
                      onTap: () => _showEarthquakeDetails(quake),
                    ),
                  );
                }
                
                // Show even non-significant earthquakes
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: quake.alertColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: quake.alertColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'M${quake.magnitude.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: quake.alertColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gempa Terbaru',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    quake.region,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          quake.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => _buildLoadingCard('Memuat data gempa terbaru...'),
              error: (error, stack) => _buildErrorCard(
                'Gagal Memuat Data Gempa Terbaru',
                error.toString(),
              ),
            ),
            
            // Statistics
            recentQuakesAsync.when(
              data: (quakes) {
                if (quakes.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: EarthquakeStats(earthquakes: quakes),
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            
            // Map section with OpenStreetMap
            latestQuakeAsync.when(
              data: (quake) {
                if (quake != null) {
                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.map,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Lokasi Episentrum',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        EarthquakeMap(earthquake: quake),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: Colors.white.withOpacity(0.5),
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
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            
            // History section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Riwayat Gempa 24 Jam',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // History list
            recentQuakesAsync.when(
              data: (quakes) {
                if (quakes.isEmpty) {
                  return _buildEmptyState();
                }
                
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quake = quakes[index];
                      return EarthquakeListItem(
                        earthquake: quake,
                        onTap: () => _showEarthquakeDetails(quake),
                      );
                    },
                    childCount: quakes.length,
                  ),
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
            
            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSettings(context),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.settings),
        label: const Text('Pengaturan'),
      ),
    );
  }

  Widget _buildHeader(bool isLive) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.public, size: 28, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'Gempa Bumi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLive ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isLive ? 'ONLINE' : 'LOADING',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => _showSettings(context),
        ),
      ],
    );
  }

  Widget _buildNoDataCard(String message) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.blue.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String title, String error) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan koneksi internet aktif',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.read(manualRefreshProvider)(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.public_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Data Gempa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk memuat ulang',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Memuat data gempa dari BMKG...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan koneksi internet aktif',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(manualRefreshProvider)(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEarthquakeDetails(Earthquake earthquake) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EarthquakeDetailsSheet(earthquake: earthquake),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EarthquakeSettingsPage(),
      ),
    );
  }
}

// Details sheet and Settings page from previous implementation
class EarthquakeDetailsSheet extends StatelessWidget {
  final Earthquake earthquake;

  const EarthquakeDetailsSheet({
    super.key,
    required this.earthquake,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: earthquake.alertColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: earthquake.alertColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Detail Gempa Bumi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Magnitude', 'M${earthquake.magnitude.toStringAsFixed(1)} Mw'),
                  _buildDetailRow('Kategori', earthquake.alertLevel),
                  _buildDetailRow('Waktu', '${earthquake.localTime.day}/${earthquake.localTime.month}/${earthquake.localTime.year} ${earthquake.localTime.hour}:${earthquake.localTime.minute.toString().padLeft(2, '0')} WIB'),
                  _buildDetailRow('Lokasi', earthquake.region),
                  _buildDetailRow('Kedalaman', '${earthquake.depth.toStringAsFixed(0)} km (${earthquake.depthCategory})'),
                  _buildDetailRow('Koordinat', '${earthquake.epicenter.latitude.toStringAsFixed(4)}°, ${earthquake.epicenter.longitude.toStringAsFixed(4)}°'),
                  if (earthquake.mmi != null)
                    _buildDetailRow('Intensitas MMI', 'Skala ${earthquake.mmi}'),
                  if (earthquake.distanceFromUser != null)
                    _buildDetailRow('Jarak dari Anda', '${earthquake.distanceFromUser!.toStringAsFixed(1)} km'),
                  _buildDetailRow('Potensi Tsunami', earthquake.tsunami.label),
                  _buildDetailRow('Sumber', earthquake.source),
                  if (earthquake.affectedAreas != null && earthquake.affectedAreas!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Wilayah yang Merasakan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...earthquake.affectedAreas!.map((area) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              area,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Data bersumber dari BMKG dan diperbarui secara otomatis setiap 2 menit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
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
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EarthquakeSettingsPage extends ConsumerWidget {
  const EarthquakeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(earthquakeSettingsProvider);
    final settingsNotifier = ref.read(earthquakeSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Aktifkan Notifikasi', style: TextStyle(color: Colors.white)),
            subtitle: Text('Terima peringatan gempa bumi', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            value: settings.notificationsEnabled,
            onChanged: settingsNotifier.setNotificationsEnabled,
            activeColor: const Color(0xFF2196F3),
          ),
          const Divider(),
          ListTile(
            title: const Text('Magnitude Minimum', style: TextStyle(color: Colors.white)),
            subtitle: Text('M${settings.minimumMagnitude.toStringAsFixed(1)}', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () => _showMagnitudeDialog(context, settingsNotifier, settings.minimumMagnitude),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Hanya Peringatan Tsunami', style: TextStyle(color: Colors.white)),
            subtitle: Text('Notifikasi hanya untuk gempa berpotensi tsunami', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            value: settings.tsunamiAlertsOnly,
            onChanged: settingsNotifier.setTsunamiAlertsOnly,
            activeColor: const Color(0xFF2196F3),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Getar', style: TextStyle(color: Colors.white)),
            value: settings.vibrate,
            onChanged: settingsNotifier.setVibrate,
            activeColor: const Color(0xFF2196F3),
          ),
          SwitchListTile(
            title: const Text('Suara', style: TextStyle(color: Colors.white)),
            value: settings.sound,
            onChanged: settingsNotifier.setSound,
            activeColor: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  void _showMagnitudeDialog(BuildContext context, settingsNotifier, double current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Magnitude Minimum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3.0, 4.0, 5.0, 6.0, 7.0].map((mag) => RadioListTile<double>(
            title: Text('M$mag'),
            value: mag,
            groupValue: current,
            onChanged: (value) {
              if (value != null) {
                settingsNotifier.setMinimumMagnitude(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }
}