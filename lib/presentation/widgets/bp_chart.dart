import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../core/theme/app_theme.dart';

class BpChart extends StatelessWidget {
  final List<BloodPressureReading> readings;

  const BpChart({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sortedReadings = List<BloodPressureReading>.from(readings)
      ..sort((a, b) => a.readingDate.compareTo(b.readingDate));

    final spotsSys = <FlSpot>[];
    final spotsDia = <FlSpot>[];
    
    for (int i = 0; i < sortedReadings.length; i++) {
      spotsSys.add(FlSpot(i.toDouble(), sortedReadings[i].systolic.toDouble()));
      spotsDia.add(FlSpot(i.toDouble(), sortedReadings[i].diastolic.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: sortedReadings.length > 7 ? (sortedReadings.length / 5).ceil().toDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedReadings.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MM/dd').format(sortedReadings[index].readingDate),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (sortedReadings.length - 1).toDouble(),
        minY: 40,
        maxY: 200,
        lineBarsData: [
          // Systolic line
          LineChartBarData(
            spots: spotsSys,
            isCurved: true,
            color: AppTheme.healthHypertension2,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.healthHypertension2,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.healthHypertension2.withValues(alpha: 0.1),
            ),
          ),
          // Diastolic line
          LineChartBarData(
            spots: spotsDia,
            isCurved: true,
            color: AppTheme.healthNormal,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.healthNormal,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.healthNormal.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.grey[800]!,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isSys = spot.barIndex == 0;
                return LineTooltipItem(
                  '${isSys ? "Sys" : "Dia"}: ${spot.y.toInt()} mmHg',
                  TextStyle(
                    color: isSys ? AppTheme.healthHypertension2 : AppTheme.healthNormal,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}