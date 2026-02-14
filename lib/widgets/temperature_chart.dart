import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../utils/color_utils.dart';

class TemperatureChart extends StatefulWidget {
  const TemperatureChart({super.key});

  @override
  State<TemperatureChart> createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.weather == null) {
          return const SizedBox.shrink();
        }

        final weather = provider.weather!;
        final hourly = weather.hourly;
        final currentTime = DateTime.parse(weather.current.time);
        final textColor = ColorUtils.getTextColor(currentTime);
        final cardColor = ColorUtils.getCardColor(currentTime);

        // Get next 24 hours
        final now = DateTime.parse(weather.current.time);
        final currentHourIndex = hourly.time.indexWhere((time) {
          final hourTime = DateTime.parse(time);
          return hourTime.isAfter(now) || hourTime.isAtSameMomentAs(now);
        });

        if (currentHourIndex == -1) return const SizedBox.shrink();

        final next24Hours = List.generate(
          24,
          (index) => currentHourIndex + index,
        ).where((i) => i < hourly.time.length).cast<int>().toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Grafik Suhu 24 Jam',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: textColor.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 3,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= next24Hours.length) {
                              return const SizedBox.shrink();
                            }
                            final index = next24Hours[value.toInt()];
                            final time = DateTime.parse(hourly.time[index]);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('HH:mm').format(time),
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}°',
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (next24Hours.length - 1).toDouble(),
                    minY: _getMinTemp(next24Hours, hourly.temperature,
                            hourly.apparentTemperature) -
                        2,
                    maxY: _getMaxTemp(next24Hours, hourly.temperature,
                            hourly.apparentTemperature) +
                        2,
                    lineBarsData: [
                      // Actual temperature line
                      LineChartBarData(
                        spots: next24Hours.asMap().entries.map((entry) {
                          final index = entry.value;
                          return FlSpot(
                            entry.key.toDouble(),
                            hourly.temperature[index],
                          );
                        }).toList(),
                        isCurved: true,
                        color: ColorUtils.getPrimaryColor(currentTime),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: touchedIndex == index ? 6 : 3,
                              color: ColorUtils.getPrimaryColor(currentTime),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: ColorUtils.getPrimaryColor(currentTime)
                              .withOpacity(0.1),
                        ),
                      ),
                      // Feels-like temperature line
                      LineChartBarData(
                        spots: next24Hours.asMap().entries.map((entry) {
                          final index = entry.value;
                          return FlSpot(
                            entry.key.toDouble(),
                            hourly.apparentTemperature[index],
                          );
                        }).toList(),
                        isCurved: true,
                        color: textColor.withOpacity(0.4),
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchCallback:
                          (FlTouchEvent event, LineTouchResponse? response) {
                        if (response == null || response.lineBarSpots == null) {
                          setState(() {
                            touchedIndex = -1;
                          });
                          return;
                        }
                        setState(() {
                          touchedIndex = response.lineBarSpots!.first.spotIndex;
                        });
                      },
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = next24Hours[spot.spotIndex.toInt()];
                            final time = DateTime.parse(hourly.time[index]);
                            return LineTooltipItem(
                              '${DateFormat('HH:mm').format(time)}\n${spot.y.round()}°',
                              TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend('Suhu Aktual',
                      ColorUtils.getPrimaryColor(currentTime), textColor),
                  const SizedBox(width: 20),
                  _buildLegend(
                      'Terasa Seperti', textColor.withOpacity(0.4), textColor),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(String label, Color color, Color textColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  double _getMinTemp(
      List<int> indices, List<double> temp, List<double> apparent) {
    double min = double.infinity;
    for (var i in indices) {
      if (temp[i] < min) min = temp[i];
      if (apparent[i] < min) min = apparent[i];
    }
    return min;
  }

  double _getMaxTemp(
      List<int> indices, List<double> temp, List<double> apparent) {
    double max = double.negativeInfinity;
    for (var i in indices) {
      if (temp[i] > max) max = temp[i];
      if (apparent[i] > max) max = apparent[i];
    }
    return max;
  }
}
