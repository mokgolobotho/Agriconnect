import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../Services/api_service.dart';
import 'CropAlertsPage.dart';

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
  List<dynamic> sensorData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    try {
      final result = await ApiService.getCropSensorData(widget.cropId);
      if (result["success"] == true) {
        setState(() {
          sensorData = result["records"];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  /// ================= Harvest Crop Functions =================
  Future<void> _confirmHarvest(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Harvest"),
          content: const Text(
            "Are you sure you want to harvest this crop?\n"
                "This action will mark the crop as harvested today.",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Confirm"),
              onPressed: () async {
                Navigator.pop(context); // close dialog
                await _harvestCrop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _harvestCrop() async {
    try {
      final result = await ApiService.harvestCrop(widget.cropId);

      if (result.containsKey("error")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["error"]),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Crop harvested successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // return success to previous page
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  /// ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cropName),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert, color: Colors.red),
            tooltip: "View Farm Alerts",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropAlertsPage(
                    cropId: widget.cropId,
                    cropName: widget.cropName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sensorData.isEmpty
          ? const Center(child: Text("No sensor data available."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🌿 Crop Monitoring Dashboard",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Crop ID: ${widget.cropId}"),
            const SizedBox(height: 20),

            /// 📟 Sensor Graphs
            const Text(
              "📟 Sensor Readings",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildGraphCard(
              title: "Temperature (°C)",
              color: Colors.red,
              fieldName: "temperature",
            ),
            _buildGraphCard(
              title: "Rainfall (mm)",
              color: Colors.blue,
              fieldName: "rainfall",
            ),
            _buildGraphCard(
              title: "Soil pH",
              color: Colors.orange,
              fieldName: "ph",
            ),
            _buildGraphCard(
              title: "Nitrogen (mg/kg)",
              color: Colors.green,
              fieldName: "nitrogen",
            ),
            _buildGraphCard(
              title: "Phosphorus (mg/kg)",
              color: Colors.purple,
              fieldName: "phosphorus",
            ),
            _buildGraphCard(
              title: "Potassium (mg/kg)",
              color: Colors.teal,
              fieldName: "potassium",
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.check),
        label: const Text("Harvest Crop"),
        onPressed: () => _confirmHarvest(context),
      ),
    );
  }

  Widget _buildGraphCard({
    required String title,
    required Color color,
    required String fieldName,
  }) {
    final spots = _generateSpotsFromData(fieldName);
    final timeLabels = _generateTimeLabels(spots);

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
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(_lineChartData(color, spots, timeLabels)),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpotsFromData(String fieldName) {
    List<FlSpot> spots = [];
    for (var record in sensorData) {
      if (record["recorded_at"] != null) {
        final time = DateTime.parse(record["recorded_at"])
            .millisecondsSinceEpoch
            .toDouble();
        final value = double.tryParse(record[fieldName].toString()) ?? 0.0;
        spots.add(FlSpot(time, value));
      }
    }
    return spots;
  }

  Map<double, String> _generateTimeLabels(List<FlSpot> spots) {
    Map<double, String> labels = {};
    for (var spot in spots) {
      final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
      labels[spot.x] = DateFormat('HH:mm').format(date);
    }
    return labels;
  }

  LineChartData _lineChartData(
      Color color, List<FlSpot> spots, Map<double, String> timeLabels) {
    return LineChartData(
      minY: 0,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              final label = timeLabels[value];
              if (label != null) {
                return Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.black87));
              }
              return const SizedBox.shrink();
            },
          ),
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
