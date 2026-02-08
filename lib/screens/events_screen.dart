import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              _buildHeader(context),
              
              const SizedBox(height: 24),
              
              // Info card
              _buildInfoCard(),
              
              const SizedBox(height: 24),
              
              // Upcoming events for 2026
              _buildUpcomingEvents(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Astronomical Events',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Calendar 2026',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Astronomical Calendar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mark your calendar for these celestial events',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    final events = [
      AstronomicalEvent(
        title: 'Total Solar Eclipse',
        date: DateTime(2026, 8, 12),
        type: EventType.eclipse,
        description: 'Total solar eclipse visible from parts of Europe, Greenland, and North America',
        icon: '🌑',
      ),
      AstronomicalEvent(
        title: 'Perseid Meteor Shower Peak',
        date: DateTime(2026, 8, 12, 13),
        type: EventType.meteorShower,
        description: 'One of the best meteor showers of the year with up to 100 meteors per hour',
        icon: '☄️',
      ),
      AstronomicalEvent(
        title: 'March Equinox',
        date: DateTime(2026, 3, 20),
        type: EventType.equinox,
        description: 'Equal day and night across the globe. Start of spring in Northern Hemisphere',
        icon: '🌸',
      ),
      AstronomicalEvent(
        title: 'June Solstice',
        date: DateTime(2026, 6, 21),
        type: EventType.solstice,
        description: 'Longest day in Northern Hemisphere, shortest in Southern Hemisphere',
        icon: '☀️',
      ),
      AstronomicalEvent(
        title: 'September Equinox',
        date: DateTime(2026, 9, 23),
        type: EventType.equinox,
        description: 'Equal day and night. Start of autumn in Northern Hemisphere',
        icon: '🍂',
      ),
      AstronomicalEvent(
        title: 'December Solstice',
        date: DateTime(2026, 12, 21),
        type: EventType.solstice,
        description: 'Shortest day in Northern Hemisphere, longest in Southern Hemisphere',
        icon: '❄️',
      ),
      AstronomicalEvent(
        title: 'Geminids Meteor Shower',
        date: DateTime(2026, 12, 14),
        type: EventType.meteorShower,
        description: 'Best meteor shower of the year with up to 120 meteors per hour',
        icon: '⭐',
      ),
    ];

    // Sort by date
    events.sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...events.map((event) => _buildEventCard(event)).toList(),
      ],
    );
  }

  Widget _buildEventCard(AstronomicalEvent event) {
    final isPast = event.date.isBefore(DateTime.now());
    final daysUntil = event.date.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPast
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPast
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                event.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d MMMM yyyy', 'id_ID').format(event.date),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isPast)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(event.type).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getEventTypeColor(event.type),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    daysUntil == 0
                        ? 'TODAY'
                        : daysUntil == 1
                            ? '1 day'
                            : '$daysUntil days',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getEventTypeColor(event.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getEventTypeLabel(event.type),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getEventTypeColor(event.type),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.eclipse:
        return Colors.deepOrange;
      case EventType.meteorShower:
        return Colors.cyan;
      case EventType.equinox:
        return Colors.green;
      case EventType.solstice:
        return Colors.amber;
      case EventType.supermoon:
        return Colors.yellow;
    }
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.eclipse:
        return 'ECLIPSE';
      case EventType.meteorShower:
        return 'METEOR SHOWER';
      case EventType.equinox:
        return 'EQUINOX';
      case EventType.solstice:
        return 'SOLSTICE';
      case EventType.supermoon:
        return 'SUPERMOON';
    }
  }
}

enum EventType {
  eclipse,
  meteorShower,
  equinox,
  solstice,
  supermoon,
}

class AstronomicalEvent {
  final String title;
  final DateTime date;
  final EventType type;
  final String description;
  final String icon;

  AstronomicalEvent({
    required this.title,
    required this.date,
    required this.type,
    required this.description,
    required this.icon,
  });
}