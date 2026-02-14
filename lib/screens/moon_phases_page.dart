import 'package:flutter/material.dart';
import '../widgets/moon_phase_widget.dart';

class MoonPhasesPage extends StatelessWidget {
  const MoonPhasesPage({super.ke chy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Current Moon Phase',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MoonPhaseWidget(currentTime: DateTime.now()),
      ),
    );
  }
}
