import 'package:flutter/material.dart';
import '../../Services/api_service.dart';

class FarmAlertsPage extends StatefulWidget {
  final int farmId;
  final String farmName;

  const FarmAlertsPage({
    Key? key,
    required this.farmId,
    required this.farmName,
  }) : super(key: key);

  @override
  State<FarmAlertsPage> createState() => _FarmAlertsPageState();
}

class _FarmAlertsPageState extends State<FarmAlertsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> alerts = [];

  @override
  void initState() {
    super.initState();
    _fetchFarmAlerts();
  }

  Future<void> _fetchFarmAlerts() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.getFarmAlerts(farmId: widget.farmId);

      if (response['success'] == true && response['alerts'] != null) {
        setState(() {
          alerts = List<Map<String, dynamic>>.from(response['alerts']);
          isLoading = false;
        });
      } else {
        throw Exception(response['error'] ?? 'Failed to load alerts');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching alerts: $e')),
        );
      }
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.farmName} Alerts"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : alerts.isEmpty
          ? const Center(
        child: Text(
          "✅ No low fertility alerts in the last 3 days.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchFarmAlerts,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];

            final recommendations = alert['recommendations'] as List<dynamic>?;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.warning, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            alert['crop_name'] ?? 'Unknown Crop',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fertility Level: ${alert['fertility_level'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    if (recommendations != null && recommendations.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recommendations:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            ...recommendations.map((rec) => Text("• $rec")),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      "📅 ${_formatDate(alert['created_at'])}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
