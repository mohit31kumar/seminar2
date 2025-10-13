import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    // Security check
    if (appState.currentUser?.role != 'admin') {
      return const Scaffold(
        body: Center(child: Text('Access Denied.')),
      );
    }
    
    final allBookings = appState.bookings;
    final approvedBookings = allBookings.where((b) => b.status == 'Approved').toList();
    final halls = appState.halls;

    if (allBookings.isEmpty) {
       return Scaffold(
        appBar: AppBar(title: const Text('Analytics Dashboard')),
        body: const Center(child: Text('No booking data available to generate analytics.'))
       );
    }

    // --- Chart 1 Data: Bookings per Hall ---
    final bookingsByHall = groupBy(approvedBookings, (b) => b.hall);
    final hallChartData = halls.mapIndexed((index, hall) {
      final count = bookingsByHall[hall.name]?.length ?? 0;
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(toY: count.toDouble(), color: theme.colorScheme.primary, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))
      ]);
    }).toList();

    // --- Chart 2 Data: Booking Trends by Month ---
    final bookingsByMonth = groupBy(allBookings, (booking) {
      return DateFormat('MMM').format(DateTime.parse(booking.date));
    });
    final monthOrder = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final lineChartSpots = monthOrder.mapIndexed((index, month) {
      final count = bookingsByMonth[month]?.length ?? 0;
      return FlSpot(index.toDouble(), count.toDouble());
    }).toList();

    // --- Chart 3 Data: Requests by Department ---
    final bookingsByDept = groupBy(allBookings, (b) => b.department);
    final deptChartData = bookingsByDept.entries.map((entry) {
      return {'name': entry.key, 'count': entry.value.length};
    }).toList();
    deptChartData.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));


    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildChartCard(
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
                              if (index >= halls.length) return const SizedBox.shrink();
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(halls[index].name.substring(0, 3)),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(value.toInt().toString())))),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      alignment: BarChartAlignment.spaceAround,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: "Booking Trends by Month",
                  chart: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                               final index = value.toInt();
                               if (index >= monthOrder.length) return const SizedBox.shrink();
                               return SideTitleWidget(axisSide: meta.axisSide, child: Text(monthOrder[index]));
                            },
                            reservedSize: 30,
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(value.toInt().toString())))),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: lineChartSpots,
                          isCurved: true,
                          color: Colors.amber,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: true, color: Colors.amber.withOpacity(0.3)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: "All Requests by Department",
                  chart: BarChart(
                    BarChartData(
                       barGroups: deptChartData.mapIndexed((index, data) => BarChartGroupData(x: index, barRods: [
                         BarChartRodData(toY: (data['count'] as int).toDouble(), color: Colors.teal, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))
                       ])).toList(),
                       titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                             sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                   final index = value.toInt();
                                   if (index >= deptChartData.length) return const SizedBox.shrink();
                                   return SideTitleWidget(
                                      angle: -0.5, // Rotate labels for better fit
                                      axisSide: meta.axisSide,
                                      child: Text(deptChartData[index]['name'] as String, style: const TextStyle(fontSize: 10)),
                                   );
                                },
                                reservedSize: 40,
                             ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (value, meta) => SideTitleWidget(axisSide: meta.axisSide, child: Text(value.toInt().toString())))),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }
}
