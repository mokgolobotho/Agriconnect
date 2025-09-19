import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorDetailPage extends StatefulWidget {
  final String sensorName;

  const SensorDetailPage({required this.sensorName, Key? key})
      : super(key: key);

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  String selectedFilter = "Day";

  final List<String> metrics = [
    "Soil Moisture",
    "Nutrients",
    "Temperature",
    "Humidity"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sensorName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sensor Data",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // Filter dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Filter: "),
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
            SizedBox(height: 20),

            // Generate a chart card for each metric
            ...metrics.map((metric) {
              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(metric,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                            _generateDummyChartData(metric, selectedFilter)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Generate dummy data for each metric depending on the filter
  LineChartData _generateDummyChartData(String metric, String filter) {
    List<FlSpot> spots = [];
    double interval = 1;

    // Different dummy ranges per metric
    double minValue, maxValue;
    switch (metric) {
      case "Soil Moisture":
        minValue = 20;
        maxValue = 40;
        break;
      case "Nutrients":
        minValue = 50;
        maxValue = 80;
        break;
      case "Temperature":
        minValue = 20;
        maxValue = 30;
        break;
      case "Humidity":
        minValue = 50;
        maxValue = 70;
        break;
      default:
        minValue = 0;
        maxValue = 100;
    }

    if (filter.toLowerCase() == "hour") {
      spots = List.generate(8, (i) => FlSpot(i * 3.0, minValue + i));
      interval = 3;
    } else if (filter.toLowerCase() == "day") {
      spots = List.generate(7, (i) => FlSpot(i.toDouble(), minValue + i));
      interval = 1;
    } else if (filter.toLowerCase() == "week") {
      spots = List.generate(4, (i) => FlSpot(i.toDouble(), minValue + i * 2));
      interval = 1;
    } else if (filter.toLowerCase() == "monthly") {
      spots = List.generate(6, (i) => FlSpot(i.toDouble(), minValue + i * 3));
      interval = 1;
    }

    return LineChartData(
      minY: 0,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) =>
                Text(value.toInt().toString(), style: TextStyle(fontSize: 12)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: interval,
            getTitlesWidget: (value, meta) {
              String label = "";
              if (filter.toLowerCase() == "hour") {
                label = "${(value.toInt()).toString().padLeft(2, '0')}:00";
              } else if (filter.toLowerCase() == "day") {
                const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                if (value.toInt() < days.length) label = days[value.toInt()];
              } else if (filter.toLowerCase() == "week") {
                label = "W${value.toInt() + 1}";
              } else if (filter.toLowerCase() == "monthly") {
                const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
                if (value.toInt() < months.length) label = months[value.toInt()];
              }
              return Text(label, style: TextStyle(fontSize: 12));
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.2),
          ),
          spots: spots,
        ),
      ],
    );
  }
}
