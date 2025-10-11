import 'package:flutter/material.dart';

// 3rd Party Packages
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

// Project Files
// ignore: unused_import
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    // --- Security check ---
    if (appState.currentUser?.role != 'admin') {
      return const Scaffold(
        body: Center(child: Text('Access Denied.')),
      );
    }

    final approvedBookings =
        appState.bookings.where((b) => b.status == 'Approved').toList();
    final halls = appState.halls;

    // --- Chart 1: Bookings per Hall ---
    final bookingsByHall = groupBy(approvedBookings, (b) => b.hall);
    final hallChartData = halls.mapIndexed((index, hall) {
      final count = bookingsByHall[hall.name]?.length ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: theme.colorScheme.primary,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    // --- Chart 2: Requests by Department ---
    final bookingsByDept = groupBy(appState.bookings, (b) => b.department);
    final deptChartData = bookingsByDept.entries.map((entry) {
      return {'name': entry.key, 'count': entry.value.length};
    }).toList();

    deptChartData
        .sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: approvedBookings.isEmpty
          ? const Center(
              child: Text('No booking data available to generate analytics.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildChartCard(
                  context: context,
                  title: "Approved Bookings per Hall",
                  chart: BarChart(
                    BarChartData(
                      barGroups: hallChartData,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= halls.length ||
                                  index < 0 ||
                                  halls.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  halls[index].name.length > 3
                                      ? halls[index].name.substring(0, 3)
                                      : halls[index].name,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                            reservedSize: 32,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 28),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      alignment: BarChartAlignment.spaceAround,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  context: context,
                  title: "All Requests by Department",
                  chart: BarChart(
                    BarChartData(
                      barGroups: deptChartData
                          .mapIndexed(
                            (index, data) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (data['count'] as int).toDouble(),
                                  color: theme.colorScheme.secondary,
                                  width: 14,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= deptChartData.length ||
                                  index < 0 ||
                                  deptChartData.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  deptChartData[index]['name'] as String,
                                  style: const TextStyle(fontSize: 9),
                                ),
                              );
                            },
                            reservedSize: 40,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 28),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      alignment: BarChartAlignment.spaceAround,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildChartCard({
    required BuildContext context,
    required String title,
    required Widget chart,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }
}
