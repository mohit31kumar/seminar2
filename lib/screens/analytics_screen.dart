import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../providers/app_state.dart';
import '../data/static_data.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.currentUser?.role != 'admin') {
      return const Center(child: Text('Access Denied.'));
    }
    
    final theme = Theme.of(context);
    final bookings = appState.allBookings;
    
    final bookingsByHall = groupBy(bookings, (b) => b.hall);
    final hallChartData = seminarHalls.map((hall) {
      final count = bookingsByHall[hall]?.length ?? 0;
      return BarChartGroupData(x: seminarHalls.indexOf(hall), barRods: [
        BarChartRodData(toY: count.toDouble(), color: theme.primaryColor, width: 12, borderRadius: BorderRadius.circular(4))
      ]);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 300,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Bookings per Hall", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        barGroups: hallChartData,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(seminarHalls[v.toInt()].substring(0,3), style: const TextStyle(fontSize: 10)), reservedSize: 20)),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}