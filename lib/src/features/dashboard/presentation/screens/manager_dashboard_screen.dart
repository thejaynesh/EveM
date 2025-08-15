import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../attendee/data/registration_service.dart';
import '../screens/calendar_view.dart';
import '../screens/events_overview.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manager Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.go('/manager/settings');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.event), text: 'Events'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardOverview(),
            EventsOverview(),
            CalendarView(),
          ],
        ),
      ),
    );
  }
}

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Registrations (Last 7 Days)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const SizedBox(
            height: 300,
            child: DailyRegistrationsChart(),
          ),
        ],
      ),
    );
  }
}

class DailyRegistrationsChart extends StatelessWidget {
  const DailyRegistrationsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final registrationService = Provider.of<RegistrationService>(context);

    return StreamBuilder<Map<DateTime, int>>(
      stream: registrationService.getDailyRegistrations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No registration data available.'));
        }

        // 1. Aggregate data by day for the last 7 days
        final dailyData = snapshot.data!;
        final aggregatedData = <DateTime, int>{};
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Initialize the last 7 days with 0 registrations
        for (int i = 6; i >= 0; i--) {
          final date = today.subtract(Duration(days: i));
          aggregatedData[date] = 0;
        }

        // Sum up registrations for each day
        dailyData.forEach((dateTime, count) {
          final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
          if (aggregatedData.containsKey(day)) {
            aggregatedData[day] = aggregatedData[day]! + count;
          }
        });

        final sortedData = aggregatedData.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        final chartData = sortedData
            .map(
              (entry) => FlSpot(
                entry.key.millisecondsSinceEpoch.toDouble(),
                entry.value.toDouble(),
              ),
            )
            .toList();

        // Find the max Y value for setting chart bounds and interval
        final maxYValue = sortedData
            .map((d) => d.value)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

        // Calculate a dynamic interval for the Y-axis to avoid cluttered labels
        double yInterval = (maxYValue / 5).ceilToDouble();
        if (yInterval == 0) {
          yInterval = 1;
        }

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  // 2. Set interval to 1 day to prevent duplicate date labels
                  interval: const Duration(days: 1).inMilliseconds.toDouble(),
                  getTitlesWidget: (value, meta) {
                    final date =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(DateFormat.E().format(date)),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  // 3. Set a whole number interval for the Y-axis
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    // Don't show the label at the very top (max value)
                    if (value >= meta.max) {
                      return Container();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(value.toInt().toString()),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
            ),
            minX: chartData.first.x,
            maxX: chartData.last.x,
            minY: 0,
            // Add some padding to the top of the chart
            maxY: maxYValue == 0 ? 5 : maxYValue * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: chartData,
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: false,
                  color: Theme.of(context).primaryColor.withAlpha(50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
