import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/earthquake.dart';
import '../providers/earthquake_providers.dart';
import '../widgets/hero_earthquake_card.dart';
import '../widgets/earthquake_list_item.dart';
import '../widgets/earthquake_map.dart';
import '../widgets/earthquake_stats.dart';

class ObjectVisibilityScreen extends ConsumerStatefulWidget {
  const ObjectVisibilityScreen({super.key});

  @override
  ConsumerState<ObjectVisibilityScreen> createState() =>
      _ObjectVisibilityScreenState();
}

class _ObjectVisibilityScreenState
    extends ConsumerState<ObjectVisibilityScreen> {
  @override
  Widget build(BuildContext context) {
    final latestQuake = ref.watch(latestEarthquakeProvider);
    final recentQuakes = ref.watch(recentEarthquakesProvider);
    final isLive = ref.watch(isLiveProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(latestEarthquakeProvider);
          ref.invalidate(recentEarthquakesProvider);
        },
        color: Colors.white,
        backgroundColor: const Color(0xFF1E1E1E),
        child: CustomScrollView(
          slivers: [
            _buildHeader(isLive),
            latestQuake.when(
              data: (quake) {
                if (quake != null && quake.isSignificant) {
                  return SliverToBoxAdapter(
                    child: HeroEarthquakeCard(
                      earthquake: quake,
                      onTap: () => _showEarthquakeDetails(quake),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            recentQuakes.when(
              data: (quakes) => SliverToBoxAdapter(
                child: EarthquakeStats(earthquakes: quakes),
              ),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            latestQuake.when(
              data: (quake) {
                if (quake != null) {
                  return SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Text(
                            'Lokasi Episentrum',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        EarthquakeMap(earthquake: quake),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  'Riwayat Gempa 24 Jam',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            recentQuakes.when(
              data: (quakes) {
                if (quakes.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.public_off,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data gempa',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
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
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat data',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.invalidate(recentEarthquakesProvider);
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSettings(context),
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.settings),
      ),
    );
  }

  Widget _buildHeader(bool isLive) {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.public, size: 28),
          SizedBox(width: 12),
          Text(
            'Gempa Bumi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLive ? Colors.red : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isLive ? 'LIVE' : 'OFFLINE',
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
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showSettings(context),
        ),
      ],
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
                  Text(
                    'Detail Gempa',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Magnitude',
                      'M${earthquake.magnitude.toStringAsFixed(1)} Mw'),
                  _buildDetailRow('Waktu', earthquake.localTime.toString()),
                  _buildDetailRow('Lokasi', earthquake.region),
                  _buildDetailRow('Kedalaman',
                      '${earthquake.depth.toStringAsFixed(0)} km (${earthquake.depthCategory})'),
                  _buildDetailRow('Koordinat',
                      '${earthquake.epicenter.latitude.toStringAsFixed(4)}°, ${earthquake.epicenter.longitude.toStringAsFixed(4)}°'),
                  if (earthquake.mmi != null)
                    _buildDetailRow('MMI', earthquake.mmi.toString()),
                  if (earthquake.distanceFromUser != null)
                    _buildDetailRow('Jarak dari Anda',
                        '${earthquake.distanceFromUser!.toStringAsFixed(1)} km'),
                  _buildDetailRow('Tsunami', earthquake.tsunami.label),
                  _buildDetailRow('Sumber', earthquake.source),
                  if (earthquake.affectedAreas != null &&
                      earthquake.affectedAreas!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Wilayah Terdampak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...earthquake.affectedAreas!.map((area) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '• $area',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        )),
                  ],
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
            title: const Text('Aktifkan Notifikasi',
                style: TextStyle(color: Colors.white)),
            subtitle: Text('Terima peringatan gempa bumi',
                style: TextStyle(color: Colors.white.withOpacity(0.6))),
            value: settings.notificationsEnabled,
            onChanged: settingsNotifier.setNotificationsEnabled,
            activeColor: const Color(0xFF2196F3),
          ),
          const Divider(),
          ListTile(
            title: const Text('Magnitude Minimum',
                style: TextStyle(color: Colors.white)),
            subtitle: Text('M${settings.minimumMagnitude.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.white.withOpacity(0.6))),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () => _showMagnitudeDialog(
                context, settingsNotifier, settings.minimumMagnitude),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Hanya Peringatan Tsunami',
                style: TextStyle(color: Colors.white)),
            subtitle: Text('Notifikasi hanya untuk gempa berpotensi tsunami',
                style: TextStyle(color: Colors.white.withOpacity(0.6))),
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

  void _showMagnitudeDialog(
      BuildContext context, settingsNotifier, double current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Magnitude Minimum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3.0, 4.0, 5.0, 6.0, 7.0]
              .map((mag) => RadioListTile<double>(
                    title: Text('M$mag'),
                    value: mag,
                    groupValue: current,
                    onChanged: (value) {
                      if (value != null) {
                        settingsNotifier.setMinimumMagnitude(value);
                        Navigator.pop(context);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
