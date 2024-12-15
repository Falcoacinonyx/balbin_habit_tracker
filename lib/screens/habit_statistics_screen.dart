import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HabitStatisticsScreen extends StatelessWidget {
  static const String id = 'habit_statistics_screen';

  final String habit;

  HabitStatisticsScreen({required this.habit});

  Future<List<BarChartGroupData>> _getHabitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('${habit}_logs') ?? [];
    Map<String, int> dataMap = {};

    logs.forEach((log) {
      DateTime date = DateTime.parse(log.split(' - ')[1]);
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      if (dataMap.containsKey(formattedDate)) {
        dataMap[formattedDate] = dataMap[formattedDate]! + 1;
      } else {
        dataMap[formattedDate] = 1;
      }
    });

    return dataMap.entries.map((entry) {
      return BarChartGroupData(
        x: int.parse(entry.key.replaceAll('-', '')),
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: entry.value.toDouble(),
            color: Colors.blue,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Statistics for $habit'),
      ),
      body: FutureBuilder(
        future: _getHabitData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else {
            List<BarChartGroupData> data = snapshot.data as List<BarChartGroupData>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: data,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
