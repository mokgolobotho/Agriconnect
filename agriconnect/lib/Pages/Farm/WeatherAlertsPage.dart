import 'package:flutter/material.dart';
import '../../Services/api_service.dart';

class WeatherAlertsPage extends StatefulWidget {
  final int farmId;
  final String farmName;

  const WeatherAlertsPage({
    super.key,
    required this.farmId,
    required this.farmName,
  });

  @override
  State<WeatherAlertsPage> createState() => _WeatherAlertsPageState();
}

class _WeatherAlertsPageState extends State<WeatherAlertsPage> {
  bool isLoading = true;
  List<dynamic> alerts = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherAlerts();
  }

  Future<void> fetchWeatherAlerts() async {
    setState(() => isLoading = true);
    final response = await ApiService.getWeatherAlerts(farmId: widget.farmId);

    if (response["success"]) {
      setState(() {
        alerts = response["data"]["alerts"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response["message"])));
    }
  }

  Color getSeverityColor(String severity) {
    if (severity == "extreme") return Colors.red.shade700;
    if (severity == "high") return Colors.orange.shade700;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Alerts - ${widget.farmName}"),
        backgroundColor: Colors.green.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
          ? const Center(
        child: Text(
          "No weather alerts in the last hour.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getSeverityColor(alert["severity"]),
                child: const Icon(Icons.warning, color: Colors.white),
              ),
              title: Text(
                alert["alert_title"],
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(alert["recommendation"]),
              trailing: Text(
                alert["severity"],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getSeverityColor(alert["severity"])),
              ),
            ),
          );
        },
      ),
    );
  }
}
