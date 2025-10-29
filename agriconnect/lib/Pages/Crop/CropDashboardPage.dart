import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CropDashboardPage extends StatefulWidget {
  final int cropId;
  final String cropName;

  const CropDashboardPage({
    Key? key,
    required this.cropId,
    required this.cropName,
  }) : super(key: key);

  @override
  State<CropDashboardPage> createState() => _CropDashboardPageState();
}

class _CropDashboardPageState extends State<CropDashboardPage> {
  String selectedFilter = "Day";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cropName),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "🌿 Crop Monitoring Dashboard",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Crop ID: ${widget.cropId}"),

            const SizedBox(height: 20),

            // Filter dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("View by:",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: ["Hour", "Day", "Week", "Monthly"]
                      .map((filter) => DropdownMenuItem(
                    value: filter,
                    child: Text(filter),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🌡 Sensor Graphs Section
            Text(
              "📟 Sensor Readings",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildGraphCard(
              title: "Soil Moisture (%)",
              color: Colors.blue,
              spots: _generateSpots(selectedFilter, 40, 65),
            ),
            _buildGraphCard(
              title: "Temperature (°C)",
              color: Colors.red,
              spots: _generateSpots(selectedFilter, 20, 35),
            ),
            _buildGraphCard(
              title: "Humidity (%)",
              color: Colors.cyan,
              spots: _generateSpots(selectedFilter, 50, 80),
            ),
            _buildGraphCard(
              title: "NPK Levels (mg/kg)",
              color: Colors.purple,
              spots: _generateSpots(selectedFilter, 20, 45),
            ),

            const SizedBox(height: 30),

            // 🤖 Prediction Graphs Section
            Text(
              "📈 Prediction Graphs",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildGraphCard(
              title: "Predicted Moisture Trend",
              color: Colors.teal,
              spots: _generateSpots(selectedFilter, 45, 70, isPrediction: true),
            ),
            _buildGraphCard(
              title: "Predicted NPK Trend",
              color: Colors.deepPurple,
              spots: _generateSpots(selectedFilter, 25, 50, isPrediction: true),
            ),
            _buildGraphCard(
              title: "Predicted Weather Temperature",
              color: Colors.orange,
              spots: _generateSpots(selectedFilter, 18, 33, isPrediction: true),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable graph card
  Widget _buildGraphCard({
    required String title,
    required Color color,
    required List<FlSpot> spots,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(_lineChartData(color, spots)),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Generate sample or prediction data points
  List<FlSpot> _generateSpots(String filter, double min, double max,
      {bool isPrediction = false}) {
    final randomOffsets = [0, 1, 2, 3, 4, 5, 6];
    List<FlSpot> spots = [];

    for (var x in randomOffsets) {
      double y = min + (max - min) * (0.5 + (x % 3) * 0.1);
      if (isPrediction) y += 2; // simulate predicted increase
      spots.add(FlSpot(x.toDouble(), y));
    }

    return spots;
  }

  /// 🔹 Create chart style
  LineChartData _lineChartData(Color color, List<FlSpot> spots) {
    return LineChartData(
      minY: 0,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: FlDotData(show: false),
          belowBarData:
          BarAreaData(show: true, color: color.withOpacity(0.2)),
          spots: spots,
        ),
      ],
    );
  }
}
