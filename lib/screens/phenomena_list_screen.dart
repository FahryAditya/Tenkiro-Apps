import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/astronomical_phenomenon.dart';
import '../services/astronomy_service.dart';

class PhenomenaListPage extends StatefulWidget {
  const PhenomenaListPage({super.key});

  @override
  State<PhenomenaListPage> createState() => _PhenomenaListPageState();
}

class _PhenomenaListPageState extends State<PhenomenaListPage> {
  final _astronomyService = AstronomyService();
  List<AstronomicalPhenomenon> _phenomena = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhenomena();
  }

  Future<void> _loadPhenomena() async {
    setState(() => _loading = true);
    try {
      final data = await _astronomyService.getUpcomingPhenomena();
      setState(() {
        _phenomena = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fenomena Langit'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF8E24AA),
            ],
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _phenomena.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadPhenomena,
                    backgroundColor: Colors.white,
                    color: const Color(0xFF6A1B9A),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _phenomena.length,
                      itemBuilder: (context, index) {
                        return _buildPhenomenonCard(_phenomena[index]);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada fenomena mendatang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Periksa lagi nanti',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhenomenonCard(AstronomicalPhenomenon phenomenon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: phenomenon.isActive
              ? Colors.green
              : phenomenon.isUpcoming
                  ? Colors.orange
                  : Colors.white.withOpacity(0.3),
          width: phenomenon.isActive ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                phenomenon.typeEmoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phenomenon.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMMM yyyy', 'id_ID').format(phenomenon.startDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (phenomenon.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'AKTIF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (phenomenon.daysUntil >= 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: phenomenon.isUpcoming ? Colors.orange : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${phenomenon.daysUntil} hari',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            phenomenon.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
          if (phenomenon.endDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Periode: ${DateFormat('d MMM', 'id_ID').format(phenomenon.startDate)} - ${DateFormat('d MMM yyyy', 'id_ID').format(phenomenon.endDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}