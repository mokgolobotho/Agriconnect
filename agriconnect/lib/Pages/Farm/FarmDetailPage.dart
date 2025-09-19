import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../Widgets/AppDrawer.dart';
import 'SensorDetailPage.dart';

class FarmDetailPage extends StatefulWidget {
  final String name;
  final String location;

  const FarmDetailPage({required this.name, required this.location, Key? key})
      : super(key: key);

  @override
  State<FarmDetailPage> createState() => _FarmDetailPageState();
}

class _FarmDetailPageState extends State<FarmDetailPage> {
  String selectedFilter = "Day"; // default filter

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Home", "icon": Icons.home, "route": "/home"},
    {"title": "Crop list", "icon": Icons.grass, "route": "/crops"},
    {"title": "Resource list", "icon": Icons.list_alt, "route": "/resources"},
    {"title": "Give Feedback", "icon": Icons.feedback, "route": "/feedback"},
    {"title": "Logout", "icon": Icons.logout, "route": "/login"},
  ];

  final List<Map<String, dynamic>> sensors = [
    {
      "id": 1,
      "name": "Sensor A",
      "location": "North Field",
      "data": {"Soil Moisture": "35%", "Nutrients": "High", "Temp": "24°C", "Humidity": "60%"}
    },
    {
      "id": 2,
      "name": "Sensor B",
      "location": "South Field",
      "data": {"Soil Moisture": "40%", "Nutrients": "Medium", "Temp": "26°C", "Humidity": "55%"}
    },
    {
      "id": 3,
      "name": "Sensor C",
      "location": "East Field",
      "data": {"Soil Moisture": "30%", "Nutrients": "Low", "Temp": "22°C", "Humidity": "65%"}
    },
    {
      "id": 4,
      "name": "Sensor D",
      "location": "West Field",
      "data": {"Soil Moisture": "38%", "Nutrients": "High", "Temp": "25°C", "Humidity": "58%"}
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name), centerTitle: true),
      drawer: AppDrawer(menuItems: menuItems, currentPage: "farmDetail"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: ${widget.location}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 20),

            // Weather Graph with filter
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Weather Data",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
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
                    SizedBox(
                      height: 200,
                      child: LineChart(sampleWeatherData(selectedFilter.toLowerCase())),
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // List of sensors
            Text("Sensors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.sensors, color: Colors.green, size: 32),
                    title: Text(sensor["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Location: ${sensor["location"]}"),
                        SizedBox(height: 4),
                        Text("🌱 Soil Moisture: ${sensor["data"]["Soil Moisture"]}"),
                        Text("🧪 Nutrients: ${sensor["data"]["Nutrients"]}"),
                        Text("🌡 Temp: ${sensor["data"]["Temp"]}"),
                        Text("💧 Humidity: ${sensor["data"]["Humidity"]}"),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SensorDetailPage(
                            sensorName: sensor["name"],
                            //sensorData: sensor["data"].toString(), // pass readings
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  // Dummy weather data
  LineChartData sampleWeatherData(String filter) {
    List<FlSpot> spots = [];
    double interval = 1; // x-axis interval for labels

    if (filter == "hour") {
      // Every 3 hours (realistic variation)
      spots = [
        FlSpot(0, 18),  // 00:00
        FlSpot(3, 20),  // 03:00
        FlSpot(6, 24),  // 06:00
        FlSpot(9, 27),  // 09:00
        FlSpot(12, 30), // 12:00
        FlSpot(15, 29), // 15:00
        FlSpot(18, 26), // 18:00
        FlSpot(21, 22), // 21:00
      ];
      interval = 3;

    } else if (filter == "day") {
      // Past 7 days
      spots = [
        FlSpot(0, 26), // Mon
        FlSpot(1, 28), // Tue
        FlSpot(2, 29), // Wed
        FlSpot(3, 27), // Thu
        FlSpot(4, 25), // Fri
        FlSpot(5, 24), // Sat
        FlSpot(6, 26), // Sun
      ];
      interval = 1;

    } else if (filter == "week") {
      // Past 4 weeks (avg temps)
      spots = [
        FlSpot(0, 27), // Week 1
        FlSpot(1, 29), // Week 2
        FlSpot(2, 28), // Week 3
        FlSpot(3, 26), // Week 4
      ];
      interval = 1;

    } else if (filter == "monthly") {
      // Past 6 months
      spots = [
        FlSpot(0, 25), // Jan
        FlSpot(1, 26), // Feb
        FlSpot(2, 28), // Mar
        FlSpot(3, 30), // Apr
        FlSpot(4, 29), // May
        FlSpot(5, 27), // Jun
      ];
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
            getTitlesWidget: (value, meta) {
              return Text("${value.toInt()}°C",
                  style: TextStyle(fontSize: 12));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: interval,
            getTitlesWidget: (value, meta) {
              String label = "";
              if (filter == "hour") {
                int hour = value.toInt();
                label = "${hour.toString().padLeft(2, '0')}:00"; // 00:00, 03:00
              } else if (filter == "day") {
                const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                if (value.toInt() < days.length) label = days[value.toInt()];
              } else if (filter == "week") {
                label = "W${value.toInt() + 1}";
              } else if (filter == "monthly") {
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

