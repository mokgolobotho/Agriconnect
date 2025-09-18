import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../Widgets/AppDrawer.dart';

class FarmDetailPage extends StatelessWidget {
  final String name;
  final String location;

   FarmDetailPage({required this.name, required this.location, Key? key})
      : super(key: key);

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Home", "icon": Icons.home, "route": "/home"},
    {"title": "Crop list", "icon": Icons.grass, "route": "/crops"},
    {"title": "Resource list", "icon": Icons.list_alt, "route": "/resources"},
    {"title": "Give Feedback", "icon": Icons.feedback, "route": "/feedback"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      drawer: AppDrawer(menuItems: menuItems, currentPage: "farmDetail"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: $location",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 20),

            // Sensor data graph
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sensor Data (Past Days)",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: LineChart(sampleSensorData())),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Weather data graph
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Weather (Past Days)",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 200, child: LineChart(sampleWeatherData())),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dummy sensor data
  LineChartData sampleSensorData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(show: true),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: Colors.green,
          barWidth: 3,
          belowBarData:
          BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
          spots: [
            FlSpot(0, 2),
            FlSpot(1, 3),
            FlSpot(2, 2.5),
            FlSpot(3, 4),
            FlSpot(4, 3.2),
          ],
        ),
      ],
    );
  }

  // Dummy weather data
  LineChartData sampleWeatherData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(show: true),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          belowBarData:
          BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
          spots: [
            FlSpot(0, 25),
            FlSpot(1, 28),
            FlSpot(2, 22),
            FlSpot(3, 26),
            FlSpot(4, 24),
          ],
        ),
      ],
    );
  }
}
