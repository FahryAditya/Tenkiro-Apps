import 'package:flutter/material.dart';
import '../models/constellation.dart';

/// Constellation lines painter
/// Draws connecting lines between stars to form constellations
class ConstellationLinesPainter extends CustomPainter {
  final List<PositionedConstellationLine> lines;
  final bool showLabels;
  final double opacity;
  final Color lineColor;
  final double lineWidth;
  
  const ConstellationLinesPainter({
    required this.lines,
    this.showLabels = true,
    this.opacity = 0.5,
    this.lineColor = Colors.cyan,
    this.lineWidth = 1.5,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (lines.isEmpty) return;
    
    // Group lines by constellation
    final Map<String, List<PositionedConstellationLine>> groupedLines = {};
    for (final line in lines) {
      if (line.isVisible) {
        groupedLines.putIfAbsent(line.constellationId, () => []).add(line);
      }
    }
    
    // Draw each constellation's lines
    for (final entry in groupedLines.entries) {
      _drawConstellationLines(canvas, entry.value, entry.key);
    }
  }
  
  void _drawConstellationLines(
    Canvas canvas,
    List<PositionedConstellationLine> constellationLines,
    String constellationId,
  ) {
    // Draw lines
    final linePaint = Paint()
      ..color = lineColor.withOpacity(opacity)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    for (final line in constellationLines) {
      if (line.point1 != null && line.point2 != null) {
        canvas.drawLine(line.point1!, line.point2!, linePaint);
        
        // Optional: Draw glow effect
        if (opacity > 0.3) {
          final glowPaint = Paint()
            ..color = lineColor.withOpacity(opacity * 0.3)
            ..strokeWidth = lineWidth + 2
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
          
          canvas.drawLine(line.point1!, line.point2!, glowPaint);
        }
      }
    }
    
    // Draw label if enabled
    if (showLabels && constellationLines.isNotEmpty) {
      _drawLabel(canvas, constellationLines, constellationId);
    }
  }
  
  void _drawLabel(
    Canvas canvas,
    List<PositionedConstellationLine> lines,
    String constellationId,
  ) {
    // Calculate center point of constellation
    final points = <Offset>[];
    for (final line in lines) {
      if (line.point1 != null) points.add(line.point1!);
      if (line.point2 != null) points.add(line.point2!);
    }
    
    if (points.isEmpty) return;
    
    final centerX = points.map((p) => p.dx).reduce((a, b) => a + b) / points.length;
    final centerY = points.map((p) => p.dy).reduce((a, b) => a + b) / points.length;
    final center = Offset(centerX, centerY);
    
    // Draw constellation name
    final textPainter = TextPainter(
      text: TextSpan(
        text: _formatConstellationName(constellationId),
        style: TextStyle(
          color: lineColor.withOpacity(opacity * 1.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final labelPosition = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, labelPosition);
  }
  
  String _formatConstellationName(String id) {
    // Convert snake_case to Title Case
    return id
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
  
  @override
  bool shouldRepaint(ConstellationLinesPainter oldDelegate) {
    return lines.length != oldDelegate.lines.length ||
           opacity != oldDelegate.opacity ||
           showLabels != oldDelegate.showLabels;
  }
}

/// Simple widget wrapper for constellation lines
class ConstellationLinesWidget extends StatelessWidget {
  final List<PositionedConstellationLine> lines;
  final bool showLabels;
  final double opacity;
  final Color lineColor;
  
  const ConstellationLinesWidget({
    super.key,
    required this.lines,
    this.showLabels = true,
    this.opacity = 0.5,
    this.lineColor = Colors.cyan,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConstellationLinesPainter(
        lines: lines,
        showLabels: showLabels,
        opacity: opacity,
        lineColor: lineColor,
      ),
      child: Container(),
    );
  }
}